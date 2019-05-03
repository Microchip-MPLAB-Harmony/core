/*******************************************************************************
  Command Processor System Service Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    sys_command.c

  Summary:
    Command Processor System Service Implementation.

  Description:
    This file contains the source code for the Command Processor System
    Service.  It provides a way to interact with the Command Processor subsystem
    to manage the ASCII command requests from the user supported by the system.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/
//DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include "configuration.h"
#include "system/command/sys_command.h"
#include "system/console/sys_console.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

typedef struct _tagHistCmdNode
{
    struct _tagHistCmdNode* next;
    struct _tagHistCmdNode* prev;
    char    cmdBuff[SYS_CMD_MAX_LENGTH + 1];  // command itself
}histCmdNode;   // simple command history

typedef struct
{
    histCmdNode*    head;
    histCmdNode*    tail;
}histCmdList;     // doubly linked history command list

#define                 ESC_SEQ_SIZE    2               // standard VT100 escape sequences

// descriptor of the command I/O node
typedef struct SYS_CMD_IO_DCPT
{
    SYS_CMD_DEVICE_NODE devNode;
    // internally maintained data
    struct SYS_CMD_IO_DCPT* next;   // linked list node
    int             seqChars;   // # of characters from the escape sequence
    char            seqBuff[ESC_SEQ_SIZE + 2];     // 0x1b + escape sequence + \0
    char*           cmdPnt; // current pointer
    char*           cmdEnd; // command end
    char*           cmdMax; // pointer past cmdEnd, if more was entered (and was \b- ed)
    char            cmdBuff[SYS_CMD_MAX_LENGTH + 1];   // buffer holding the command
    // history
    histCmdList     histList;                           // arranged as list
    histCmdNode*    currHistN;      // current history node
    histCmdNode     histArray[COMMAND_HISTORY_DEPTH];   // array of history commands
} SYS_CMD_IO_DCPT;



// Defines the list structure to store a list of command instances.
typedef struct
{
    SYS_CMD_IO_DCPT* head;
    SYS_CMD_IO_DCPT* tail;

} SYS_CMD_DEVICE_LIST;


// Defines the command table structure for the Command Processor System Service.
typedef struct
{
    int                         nCmds;          // number of commands available in the table
    const SYS_CMD_DESCRIPTOR*   pCmd;      // pointer to an array of command descriptors
    const char*                 cmdGroupName;   // name identifying the commands
    const char*                 cmdMenuStr;     // help string

} SYS_CMD_DESCRIPTOR_TABLE;                 // table containing the supported commands

// *****************************************************************************
// *****************************************************************************
// Section: Global Variable Definitions
// *****************************************************************************
// *****************************************************************************

static SYS_CMD_DEVICE_LIST cmdIODevList = {0, 0};

static char printBuff[SYS_CMD_PRINT_BUFFER_SIZE] SYS_CMD_BUFFER_DMA_READY;
static int printBuffPtr = 0;

typedef struct
{
    char*       startBuff;  // buffer to store the ready console data
    char*       endBuff;    // buffer to store the ready console data
    char*       rdPtr;  // pointer to read the ready buffer
    char*       wrPtr;  // pointer to write into the ready buffer
    void        (*cback)(void*);    // notification with the console
    uint32_t    ovflowCnt;      // overflow counter
}SYS_CMD_CONSOLE_RD;    // fake descriptor for the console

static char consoleReadyBuff[SYS_CMD_READ_BUFFER_SIZE]; // buffer to store the ready console data
static char consoleSchedBuff[10];                       // buffer to be scheduled for console operations...
static SYS_CMD_CONSOLE_RD  sys_console_rd;

// VT100 ASCII terminal sequences
#define         LINE_TERM       "\r\n"          // line terminator

#define         _promptStr      ">"             // prompt string

static SYS_CMD_INIT _cmdInitData;       // data the command processor has been initialized with

static SYS_CMD_DESCRIPTOR_TABLE   _usrCmdTbl[MAX_CMD_GROUP] = { {0} };    // current command table

static const char       _seqUpArrow[ESC_SEQ_SIZE] = "[A";
static const char       _seqDownArrow[ESC_SEQ_SIZE] = "[B";
static const char       _seqRightArrow[ESC_SEQ_SIZE] = "[C";
static const char       _seqLeftArrow[ESC_SEQ_SIZE] = "[D";  // standard VT100 escape sequences

// prototypes

static void     CommandReset(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv);
static void     CommandQuit(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv);              // command quit
static void     CommandHelp(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv);              // help

static int      StringToArgs(char *pRawString, char *argv[]); // Convert string to argc & argv[]
static bool     ParseCmdBuffer(SYS_CMD_IO_DCPT* pCmdIO);      // parse the command buffer

static void     ProcessEscSequence(SYS_CMD_IO_DCPT* pCmdIO, const char* escSeq);       // process an escape sequence
static void     DisplayNodeMsg(SYS_CMD_IO_DCPT* pCmdIO, histCmdNode* pNext);

static void     CmdAddHead(histCmdList* pL, histCmdNode* pN);
static histCmdNode* CmdRemoveTail(histCmdList* pL);

static void     CmdAdjustPointers(SYS_CMD_IO_DCPT* pCmdIO);

static void SendCommandMessage(const void* cmdIoParam, const char* str);
static void SendCommandPrint(const void* cmdIoParam, const char* format, ...);
static void SendCommandCharacter(const void* cmdIoParam, char c);
static int IsCommandReady(const void* cmdIoParam);
static char GetCommandCharacter(const void* cmdIoParam);
static void CommandReadCback(void* pBuffer);
static void RunCmdTask(SYS_CMD_IO_DCPT* pCmdIO);

const SYS_CMD_API sysConsoleApi =
{
    .msg = SendCommandMessage,
    .print = SendCommandPrint,
    .putc = SendCommandCharacter,
    .isRdy = IsCommandReady,
    .getc = GetCommandCharacter,
};

// built-in command table
static const SYS_CMD_DESCRIPTOR    _builtinCmdTbl[]=
{
    {"reset",   CommandReset,   ": Reset host"},
    {"q",       CommandQuit,    ": quit command processor"},
    {"help",    CommandHelp,    ": help"},
};

// *****************************************************************************
// *****************************************************************************
// Section: SYS CMD Operation Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    bool SYS_CMD_Initialize( const SYS_MODULE_INIT * const init  )

  Summary:
    Initializes data for the instance of the Command Processor module.

  Description:
    This function initializes the Command Processor module.
    It also initializes any internal data structures.

  Precondition:
    None.

  Parameters:
    init            - Pointer to a data structure containing any data necessary
                      to initialize the sys command. This pointer may be null if no
                      data is required because static overrides have been
                      provided.

  Returns:
    If successful, returns true.
    If there is an error, returns false.

  Remarks:
    This routine should only be called once during system initialization.
*/
bool SYS_CMD_Initialize(const SYS_MODULE_INIT * const init )
{
    SYS_CMD_INIT *initConfig = (SYS_CMD_INIT*)init;

    if (initConfig == 0)
    {
        return false;
    }

    _cmdInitData = *initConfig; // save a copy of the initialization data


    cmdIODevList.head = cmdIODevList.tail = 0;

    SYS_CMDIO_ADD(&sysConsoleApi, &initConfig->consoleCmdIOParam, initConfig->consoleCmdIOParam);

    _cmdInitData.consoleIndex = initConfig->consoleIndex;

    sys_console_rd.startBuff = consoleReadyBuff;
    sys_console_rd.endBuff = consoleReadyBuff + sizeof(consoleReadyBuff);
    sys_console_rd.rdPtr = sys_console_rd.wrPtr = sys_console_rd.startBuff;
    sys_console_rd.cback = 0;
    sys_console_rd.ovflowCnt = 0;

    return true;
}


bool SYS_CMD_READY_TO_READ(void)
{
    return true;
}

// add new command group
bool  SYS_CMD_ADDGRP(const SYS_CMD_DESCRIPTOR* pCmdTbl, int nCmds, const char* groupName, const char* menuStr)
{
    int i, groupIx = -1, emptyIx = -1;
    int insertIx;

    // Check if there is space for new command group; If this table already added, also simply update.
    for (i=0; i<MAX_CMD_GROUP; i++)
    {
        if(_usrCmdTbl[i].pCmd == 0)
        {   // empty slot
            emptyIx = i;
        }
        else if(_usrCmdTbl[i].pCmd == pCmdTbl)
        {   // already have this group; sanity check against the group name
            if(strcmp(groupName, _usrCmdTbl[i].cmdGroupName) != 0)
            {   // name mismatch
                return false;
            }

            groupIx = i;
            break;
        }
    }

    // reference the command group
    if (groupIx != -1)
    {
        insertIx = groupIx;
    }
    else if(emptyIx != -1)
    {
        insertIx = emptyIx;
    }
    else
    {
        return false;
    }

    _usrCmdTbl[insertIx].pCmd = pCmdTbl;
    _usrCmdTbl[insertIx].nCmds = nCmds;
    _usrCmdTbl[insertIx].cmdGroupName = groupName;
    _usrCmdTbl[insertIx].cmdMenuStr = menuStr;
    return true;

}

// Maintains the Command Processor System Service's internal state machine.
bool SYS_CMD_Tasks(void)
{
    SYS_CMD_IO_DCPT* pCmdIO;
    for(pCmdIO = cmdIODevList.head; pCmdIO != 0; pCmdIO = pCmdIO->next)
    {
        RunCmdTask(pCmdIO);
    }

    return true;
}

static void RunCmdTask(SYS_CMD_IO_DCPT* pCmdIO)
{
    char newCh;
    char echoBuff[2];

    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    // Check if there's characters available
    if(!(*pCmdApi->isRdy)(cmdIoParam))
    {
        return;
    }

    // read the character
    newCh = (*pCmdApi->getc)(cmdIoParam); /* Read data from console. */

    if(pCmdIO->seqChars != 0)
    {   // in the middle of escape sequence
        pCmdIO->seqBuff[pCmdIO->seqChars] = newCh;
        pCmdIO->seqChars++;
        if(pCmdIO->seqChars == ESC_SEQ_SIZE + 1)
        {   // we're done
            ProcessEscSequence(pCmdIO, pCmdIO->seqBuff);
            pCmdIO->seqChars = 0;
            return;
        }
    }
    else if((newCh == '\r') || (newCh == '\n'))
    {   // new command assembled
        if(pCmdIO->cmdEnd ==  pCmdIO->cmdBuff)
        {   // just an extra \n or \r
            (*pCmdApi->msg)(cmdIoParam, LINE_TERM _promptStr);
            return;
        }
        (*pCmdApi->msg)(cmdIoParam, LINE_TERM);
        *pCmdIO->cmdEnd = 0;
        pCmdIO->cmdPnt = pCmdIO->cmdEnd = pCmdIO->cmdMax = pCmdIO->cmdBuff;

        ParseCmdBuffer(pCmdIO);
        (*pCmdApi->msg)(cmdIoParam, _promptStr);
    }
    else if(newCh == '\b')
    {
        if(pCmdIO->cmdPnt > pCmdIO->cmdBuff)
        {
            if(pCmdIO->cmdEnd > pCmdIO->cmdPnt)
            {
                int ix, len;
                char* pSrc = pCmdIO->cmdPnt; // current
                char* pDst = pCmdIO->cmdPnt - 1;
                len = pCmdIO->cmdEnd - pSrc;
                for(ix = 0; ix < len; ix++)
                {
                    *pDst++ = *pSrc++;
                }
                pCmdIO->cmdPnt--; pCmdIO->cmdEnd--;
                if(pCmdIO->cmdEnd > pCmdIO->cmdBuff)
                {
                    char mirrorBuff[100];
                    len = pCmdIO->cmdEnd - pCmdIO->cmdPnt;
                    mirrorBuff[0] = '\b';
                    memcpy(mirrorBuff + 1, pCmdIO->cmdPnt, len);
                    mirrorBuff[len + 1] = ' ';
                    memset(mirrorBuff + (len + 2), '\b', len + 1);
                    mirrorBuff[len + len + 3] = 0;
                    (*pCmdApi->msg)(cmdIoParam, mirrorBuff);
                }
            }
            else
            {   // delete char under cursor
                (*pCmdApi->msg)(cmdIoParam, "\b \b");
                pCmdIO->cmdPnt--; pCmdIO->cmdEnd--;
            }
        }
    }
    else if(newCh == 0x1b)
    {   // start escape sequence... wait for complete sequence
        pCmdIO->seqBuff[0] = newCh;
        pCmdIO->seqChars = 1;
    }
    else if(pCmdIO->cmdEnd - pCmdIO->cmdBuff < SYS_CMD_MAX_LENGTH)
    {   // echo it back
        echoBuff[0] = newCh;
        echoBuff[1] = 0;
        (*pCmdApi->msg)(cmdIoParam, echoBuff);
        *pCmdIO->cmdPnt++ = newCh;
        CmdAdjustPointers(pCmdIO);
    }
    else
    {
        (*pCmdApi->msg)(cmdIoParam, " *** Command Processor buffer exceeded. Retry. ***" LINE_TERM);
        pCmdIO->cmdPnt = pCmdIO->cmdEnd = pCmdIO->cmdBuff;
        (*pCmdApi->msg)(cmdIoParam, _promptStr);
    }
}

// *****************************************************************************
/* Function:
    void SYS_CMD_MESSAGE (const char* message)

  Summary:
    Outputs a message to the Command Processor System Service console.

  Description:
    This function outputs a message to the Command Processor System Service
    console.
.
  Precondition:
    SYS_CMD_Initialize was successfully run once.

  Parameters:
    None.

  Returns:
    None.

  Remarks:
    None.
*/
void SYS_CMD_MESSAGE(const char* message)
{
    SendCommandMessage(NULL, message);
}

// *****************************************************************************
/* Function:
    void SYS_CMD_PRINT(const char *format, ...)

  Summary:
    Outputs a printout to the Command Processor System Service console.

  Description:
    This function outputs a printout to the Command Processor System Service
    console.
.
  Precondition:
    SYS_CMD_Initialize was successfully run once.

  Parameters:
    None.

  Returns:
    None.

  Remarks:
    None.
*/
void SYS_CMD_PRINT(const char* format, ...)
{
    char tmpBuf[SYS_CMD_PRINT_BUFFER_SIZE];
    size_t len = 0;
    size_t padding = 0;
    va_list args = (va_list){0};
    va_start( args, format );

    len = vsnprintf(tmpBuf, SYS_CMD_PRINT_BUFFER_SIZE, format, args);

    va_end( args );

    if (len > 0 && len < SYS_CMD_PRINT_BUFFER_SIZE)
    {
        tmpBuf[len] = '\0';

        if (len + printBuffPtr >= SYS_CMD_PRINT_BUFFER_SIZE)
        {
            printBuffPtr = 0;
        }

        strcpy(&printBuff[printBuffPtr], tmpBuf);
        SendCommandMessage(NULL, &printBuff[printBuffPtr]);

        padding = len % 4;

        if (padding > 0)
        {
            padding = 4 - padding;
        }

        printBuffPtr += len + padding;
    }
}

SYS_CMD_DEVICE_NODE* SYS_CMDIO_GET_HANDLE(short num)
{
    SYS_CMD_IO_DCPT* pNode = cmdIODevList.head;

    while(num && pNode)
    {
        pNode = pNode->next;
        num--;
    }

    return pNode == 0 ? 0 : &pNode->devNode;
}

SYS_CMD_DEVICE_NODE* SYS_CMDIO_ADD(const SYS_CMD_API* opApi, const void* cmdIoParam, int unused)
{
    int ix;

    // Create new node
    SYS_CMD_IO_DCPT* pNewIo;

    pNewIo = (SYS_CMD_IO_DCPT*)calloc(1, sizeof(*pNewIo));
    if (!pNewIo)
    {
        return 0;
    }
    pNewIo->devNode.pCmdApi = opApi;
    pNewIo->devNode.cmdIoParam = cmdIoParam;
    pNewIo->cmdPnt = pNewIo->cmdEnd = pNewIo->cmdMax = pNewIo->cmdBuff;

    // construct the command history list
    for(ix = 0; ix < sizeof(pNewIo->histArray) / sizeof(*pNewIo->histArray); ix++)
    {
        CmdAddHead(&pNewIo->histList, pNewIo->histArray + ix);
    }

    // Insert node at end
    pNewIo->next = 0;
    if(cmdIODevList.head == 0)
    {
        cmdIODevList.head = pNewIo;
        cmdIODevList.tail = pNewIo;
    }
    else
    {
        cmdIODevList.tail->next = pNewIo;
        cmdIODevList.tail = pNewIo;
    }

    return &pNewIo->devNode;
}


bool SYS_CMD_DELETE(SYS_CMD_DEVICE_NODE* pDeviceNode)
{
    SYS_CMD_IO_DCPT* p_listnode = cmdIODevList.head;
    SYS_CMD_IO_DCPT* pre_listnode;
    SYS_CMD_IO_DCPT* pDevNode = (SYS_CMD_IO_DCPT*)pDeviceNode;

    // root list is empty or null node to be deleted
    if((p_listnode == NULL) || (pDevNode == NULL))
    {
        return false;
    }

    if(p_listnode == pDevNode)
    {   // delete the head
        //Root list has only one node
        if(cmdIODevList.tail == pDevNode)
        {
            cmdIODevList.head = NULL;
            cmdIODevList.tail = NULL;
        }
        else
        {
            cmdIODevList.head = p_listnode->next;
        }
        free(pDevNode);
        return true;
    }

    // delete mid node
    pre_listnode = p_listnode;
    while (p_listnode)
    {
        if(p_listnode == pDevNode)
        {
            pre_listnode->next = p_listnode->next;
            // Deleted node is tail
            if (cmdIODevList.tail==pDevNode) {
                cmdIODevList.tail = pre_listnode;
            }
            free(pDevNode);
            return true;
        }
        pre_listnode = p_listnode;
        p_listnode   = p_listnode->next;
    }


    return false;
}

// ignore the console handle for now, we support a single system console
static void SendCommandMessage(const void* cmdIoParam, const char* message)
{
    SYS_CONSOLE_Write(_cmdInitData.consoleIndex, STDOUT_FILENO, message, strlen(message));
}

static void SendCommandPrint(const void* cmdIoParam, const char* format, ...)
{
    char tmpBuf[SYS_CMD_PRINT_BUFFER_SIZE];
    size_t len = 0;
    size_t padding = 0;
    va_list args = (va_list){0};
    va_start( args, format );

    len = vsnprintf(tmpBuf, SYS_CMD_PRINT_BUFFER_SIZE, format, args);

    va_end( args );


    if (len > 0 && len < SYS_CMD_PRINT_BUFFER_SIZE)
    {
        tmpBuf[len] = '\0';

        if (len + printBuffPtr >= SYS_CMD_PRINT_BUFFER_SIZE)
        {
            printBuffPtr = 0;
        }

        strcpy(&printBuff[printBuffPtr], tmpBuf);
        SendCommandMessage(NULL, &printBuff[printBuffPtr]);

        padding = len % 4;

        if (padding > 0)
        {
            padding = 4 - padding;
        }

        printBuffPtr += len + padding;
    }
}

static void SendCommandCharacter(const void* cmdIoParam, char c)
{
    if (SYS_CONSOLE_Status((SYS_MODULE_OBJ)_cmdInitData.consoleIndex) == SYS_STATUS_READY)
    {
        SYS_CONSOLE_Write(_cmdInitData.consoleIndex, STDOUT_FILENO, (const char*)&c, 1);
    }
}


static int IsCommandReady(const void* cmdIoParam)
{
    int n_bytes = sys_console_rd.wrPtr - sys_console_rd.rdPtr;
    if(n_bytes < 0)
    {
        n_bytes += sys_console_rd.endBuff - sys_console_rd.startBuff;
    }

    if(sys_console_rd.cback == 0)
    {   // 1st time we're called
        SYS_CONSOLE_RegisterCallback(_cmdInitData.consoleIndex, CommandReadCback, SYS_CONSOLE_EVENT_READ_COMPLETE);
        // schedule the next read
        if (SYS_CONSOLE_Status((SYS_MODULE_OBJ)_cmdInitData.consoleIndex) == SYS_STATUS_READY)
        {
            SYS_CONSOLE_Read(_cmdInitData.consoleIndex, 0, consoleSchedBuff, 1);
            sys_console_rd.cback = CommandReadCback;
        }
    }

    return n_bytes;
}

// notification called when the read is complete
// push another ready character
static void CommandReadCback(void* pBuffer)
{
    char* wrPtr = sys_console_rd.wrPtr + 1;
    if(wrPtr == sys_console_rd.endBuff)
    {
        wrPtr = sys_console_rd.startBuff;
    }

    if(wrPtr == sys_console_rd.rdPtr)
    {   // overflow
        sys_console_rd.ovflowCnt++;
    }
    else
    {
        *wrPtr = *(char*)pBuffer;
        sys_console_rd.wrPtr = wrPtr;
    }
    // start another transfer
    SYS_CONSOLE_Read(_cmdInitData.consoleIndex, 0, consoleSchedBuff, 1);
}

static char GetCommandCharacter(const void* cmdIoParam)
{
    char* rdPtr = sys_console_rd.rdPtr;
    if(rdPtr == sys_console_rd.wrPtr)
    {   // empty
        return -1;
    }

    rdPtr++;
    if(rdPtr == sys_console_rd.endBuff)
    {
        rdPtr = sys_console_rd.startBuff;
    }

    char new_c = *(rdPtr);

    sys_console_rd.rdPtr = rdPtr;

    return new_c;
}

// implementation
static void CommandReset(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv)
{
    const void* cmdIoParam = pCmdIO->cmdIoParam;
    (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** System Reboot ***\r\n" );

}

// quit
static void CommandQuit(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv)
{
    SYS_CMD_IO_DCPT* pCmdIoNode;
    const void* cmdIoParam = pCmdIO->cmdIoParam;

    (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** Quitting the Command Processor. Bye ***\r\n" );

    memset(_usrCmdTbl, 0x0, sizeof(_usrCmdTbl));

    while((pCmdIoNode = cmdIODevList.head) != NULL)
    {
        free(pCmdIoNode);
    }
}

static void CommandHelp(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv)
{
    int ix, groupIx;
    const SYS_CMD_DESCRIPTOR*  pDcpt;
    const SYS_CMD_DESCRIPTOR_TABLE* pTbl, *pDTbl;
    const void* cmdIoParam = pCmdIO->cmdIoParam;

    if(argc == 1)
    {   // no params help; display basic info
        bool hadHeader = false;
        pTbl = _usrCmdTbl;
        for (groupIx=0; groupIx < MAX_CMD_GROUP; groupIx++)
        {
            if (pTbl->pCmd)
            {
                if(!hadHeader)
                {
                    (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM "------- Supported command groups ------");
                    hadHeader = true;
                }
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** ");
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pTbl->cmdGroupName);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pTbl->cmdMenuStr);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, " ***");
            }
            pTbl++;
        }

        // display the basic commands
        (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM "---------- Built in commands ----------");
        for(ix = 0, pDcpt = _builtinCmdTbl; ix < sizeof(_builtinCmdTbl)/sizeof(*_builtinCmdTbl); ix++, pDcpt++)
        {
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** ");
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdStr);
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdDescr);
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, " ***");
        }

        (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM);
    }
    else
    {   // we have a command group name
        pDTbl = 0;
        pTbl = _usrCmdTbl;
        for (groupIx=0; groupIx < MAX_CMD_GROUP; groupIx++)
        {
            if (pTbl->pCmd)
            {
                if(strcmp(pTbl->cmdGroupName, argv[1]) == 0)
                {   // match
                    pDTbl = pTbl;
                    break;
                }
            }
            pTbl++;
        }

        if(pDTbl)
        {
            for(ix = 0, pDcpt = pDTbl->pCmd; ix < pDTbl->nCmds; ix++, pDcpt++)
            {
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** ");
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdStr);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdDescr);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, " ***");
            }

            (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM);
        }
        else
        {
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM "Unknown command group. Try help" LINE_TERM );
        }
    }

}

static bool ParseCmdBuffer(SYS_CMD_IO_DCPT* pCmdIO)
{
    int  argc = 0;
    char *argv[MAX_CMD_ARGS + 1] = {0};
    static char saveCmd[SYS_CMD_MAX_LENGTH+1];
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    int            ix, grp_ix;
    const SYS_CMD_DESCRIPTOR* pDcpt;

    strncpy(saveCmd, pCmdIO->cmdBuff, sizeof(saveCmd));     // make a copy of the command

    // parse a command string to *argv[]
    argc = StringToArgs(saveCmd, argv);

    if(argc != 0)
    {   // ok, there's smth here

        // add it to the history list
        histCmdNode* pN = CmdRemoveTail(&pCmdIO->histList);
        strncpy(pN->cmdBuff, pCmdIO->cmdBuff, sizeof(saveCmd)); // Need save non-parsed string
        CmdAddHead(&pCmdIO->histList, pN);
        pCmdIO->currHistN = 0;

        // try built-in commands first
        for(ix = 0, pDcpt = _builtinCmdTbl; ix < sizeof(_builtinCmdTbl)/sizeof(*_builtinCmdTbl); ix++, pDcpt++)
        {
            if(!strcmp(argv[0], pDcpt->cmdStr))
            {   // command found
                (*pDcpt->cmdFnc)(&pCmdIO->devNode, argc, argv);     // call command handler
                return true;
            }
        }
        // search user commands
        for (grp_ix=0; grp_ix < MAX_CMD_GROUP; grp_ix++)
        {
            if (_usrCmdTbl[grp_ix].pCmd == 0)
            {
               continue;
            }

            for(ix = 0, pDcpt = _usrCmdTbl[grp_ix].pCmd; ix < _usrCmdTbl[grp_ix].nCmds; ix++, pDcpt++)
            {
                if(!strcmp(argv[0], pDcpt->cmdStr))
                {
                    // command found
                    (*pDcpt->cmdFnc)(&pCmdIO->devNode, argc, argv);
                    return true;
                }
            }
        }

        // command not found
        (*pCmdIO->devNode.pCmdApi->msg)(cmdIoParam, " *** Command Processor: unknown command. ***\r\n");
    }
    else
    {
        (*pCmdIO->devNode.pCmdApi->msg)(cmdIoParam, " *** Command Processor: Please type in a command***" LINE_TERM);
    }

    return false;
}

/*
  parse a tring into '*argv[]', delimitor is space or tab
  param pRawString, the whole line of command string
  param argv, parsed argument string array
  return number of parsed argument
*/
static int StringToArgs(char *pRawString, char *argv[]) {
  int argc = 0, i = 0, strsize = 0;

  if(pRawString == NULL)
    return 0;

  strsize = strlen(pRawString);

  while(argc < MAX_CMD_ARGS) {

    // skip white space characters of string head
    while ((*pRawString == ' ') || (*pRawString == '\t')) {
      ++pRawString;
      if (++i >= strsize) {
        return (argc);
      }
    }

    if (*pRawString == '\0') {
      argv[argc] = NULL;
      return (argc);
    }

    argv[argc++] = pRawString;

    // find end of string
    while (*pRawString && (*pRawString != ' ') && (*pRawString != '\t')) {
      ++pRawString;
    }

    if (*pRawString == '\0') {
    argv[argc] = NULL;
    return (argc);
    }

    *pRawString++ = '\0';
  }

  SYS_PRINT("\n\r Too many arguments. Maximum argus supported is %d!\r\n", MAX_CMD_ARGS);

  return (0);
}

// escSeq is the whole sequence, starting with 0x1b
static void ProcessEscSequence(SYS_CMD_IO_DCPT* pCmdIO, const char* escSeq)
{
    histCmdNode *pNext;
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    if(!strcmp(escSeq + 1, _seqUpArrow))
    { // up arrow
        if(pCmdIO->currHistN)
        {
            pNext = pCmdIO->currHistN->next;
            if(pNext == pCmdIO->histList.head)
            {
                return; // reached the end of list
            }
        }
        else
        {
            pNext = pCmdIO->histList.head;
        }

        DisplayNodeMsg(pCmdIO, pNext);
    }
    else if(!strcmp(escSeq + 1, _seqDownArrow))
    { // down arrow
        if(pCmdIO->currHistN)
        {
            pNext = pCmdIO->currHistN->prev;
            if(pNext != pCmdIO->histList.tail)
            {
                DisplayNodeMsg(pCmdIO, pNext);
            }
        }
    }
    else if(!strcmp(escSeq + 1, _seqRightArrow))
    { // right arrow
        if(pCmdIO->cmdPnt < pCmdIO->cmdEnd)
        {   // just advance
            (*pCmdApi->msg)(cmdIoParam, escSeq);
            pCmdIO->cmdPnt++;
        }
        else if(pCmdIO->cmdEnd < pCmdIO->cmdMax)
        {   // extra characters typed
            char oldCh[2];
            oldCh[0] = *(pCmdIO->cmdEnd);
            oldCh[1] = '\0';
            (*pCmdApi->msg)(cmdIoParam, oldCh);
            pCmdIO->cmdPnt++;
            CmdAdjustPointers(pCmdIO);
        }
    }
    else if(!strcmp(escSeq + 1, _seqLeftArrow))
    { // left arrow
        if(pCmdIO->cmdPnt > pCmdIO->cmdBuff)
        {
            pCmdIO->cmdPnt--;
            (*pCmdApi->msg)(cmdIoParam, escSeq);
        }
    }
    else
    {
        (*pCmdApi->msg)(cmdIoParam, " *** Command Processor: unknown command. ***" LINE_TERM);
        (*pCmdApi->msg)(cmdIoParam, _promptStr);
    }

}

static void DisplayNodeMsg(SYS_CMD_IO_DCPT* pCmdIO, histCmdNode* pNext)
{
    int oCmdLen, nCmdLen;
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    if((nCmdLen = strlen(pNext->cmdBuff)))
    {   // something there
        oCmdLen = pCmdIO->cmdEnd - pCmdIO->cmdBuff;
        while(oCmdLen > nCmdLen)
        {
            (*pCmdApi->msg)(cmdIoParam, "\b \b");     // clear the old command
            oCmdLen--;
        }
        while(oCmdLen--)
        {
            (*pCmdApi->msg)(cmdIoParam, "\b");
        }
        strcpy(pCmdIO->cmdBuff, pNext->cmdBuff);
        (*pCmdApi->msg)(cmdIoParam, "\r\n>");
        (*pCmdApi->msg)(cmdIoParam, pCmdIO->cmdBuff);
        pCmdIO->cmdPnt = pCmdIO->cmdEnd = pCmdIO->cmdBuff + nCmdLen;
        pCmdIO->currHistN = pNext;
    }
}


static void CmdAddHead(histCmdList* pL, histCmdNode* pN)
{
    if(pL->head == 0)
    { // empty list, first node
        pL->head = pL->tail = pN;
        pN->next = pN->prev = pN;
    }
    else
    {
        pN->next = pL->head;
        pN->prev = pL->tail;
        pL->tail->next = pN;
        pL->head->prev = pN;
        pL->head = pN;
    }
}


static histCmdNode* CmdRemoveTail(histCmdList* pL)
{
    histCmdNode* pN;
    if(pL->head == pL->tail)
    {
        pN = pL->head;
        pL->head = pL->tail = 0;
    }
    else
    {
        pN = pL->tail;
        pL->tail = pN->prev;
        pL->tail->next = pL->head;
        pL->head->prev = pL->tail;
    }
    return pN;
}

static void CmdAdjustPointers(SYS_CMD_IO_DCPT* pCmdIO)
{
    if(pCmdIO->cmdPnt > pCmdIO->cmdEnd)
    {
        pCmdIO->cmdEnd = pCmdIO->cmdPnt;
    }
    if(pCmdIO->cmdPnt > pCmdIO->cmdMax)
    {
        pCmdIO->cmdMax = pCmdIO->cmdPnt;
    }

}

