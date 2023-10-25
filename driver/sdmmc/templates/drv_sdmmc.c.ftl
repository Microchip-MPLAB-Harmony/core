/*******************************************************************************
  SD Host Controller Device Driver Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdmmc.c

  Summary:
    SD Host Controller Device Driver Implementation

  Description:
    The SD Host Controller device driver provides a simple interface to manage the
    SD Host Controller modules on Microchip microcontrollers.  This file Implements
    the core interface routines for the SD Host Controller driver.

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
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "configuration.h"
#include "driver/sdmmc/drv_sdmmc.h"
#include "driver/sdmmc/src/drv_sdmmc_local.h"
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
#include "system/cache/sys_cache.h"
</#if>
#include <string.h>
<#if drv_sdmmc.DRV_SDMMC_COMMON_FS_ENABLE == true>
#include "driver/sdmmc/src/drv_sdmmc_file_system.h"
</#if>

static DRV_SDMMC_OBJ gDrvSDMMCObj[DRV_SDMMC_INSTANCES_NUMBER];

<#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
static uint8_t __COHERENT __ALIGNED(32) gScrBuffer[DRV_SDMMC_INSTANCES_NUMBER][DRV_SDMMC_SCR_BUFFER_LEN];
static uint8_t __COHERENT __ALIGNED(32) gSwitchStatusBuffer[DRV_SDMMC_INSTANCES_NUMBER][DRV_SDMMC_SWITCH_STATUS_BUFFER_LEN];
static uint8_t __COHERENT __ALIGNED(32) gExtCSDBuffer[DRV_SDMMC_INSTANCES_NUMBER][DRV_SDMMC_EXT_CSD_RESP_SIZE];
</#if>

static inline uint32_t  lDRV_SDMMC_MAKE_HANDLE(uint16_t token, uint8_t drvIndex, uint8_t index)
{
    return (((uint32_t)token << 16) | ((uint32_t)drvIndex << 8) | index);
}

static inline uint16_t lDRV_SDMMC_UPDATE_TOKEN(uint16_t token)
{
    token++;

    if (token >= DRV_SDMMC_TOKEN_MAX)
    {
        token = 1;
    }

    return token;
}

static DRV_SDMMC_CLIENT_OBJ* lDRV_SDMMC_DriverHandleValidate(DRV_HANDLE handle)
{
    /* This function returns the pointer to the client object that is
       associated with this handle if the handle is valid. Returns NULL
       otherwise. */

    uint32_t drvInstance = 0;
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;

    if((handle != DRV_HANDLE_INVALID) && (handle != 0U))
    {
        /* Extract the drvInstance value from the handle */
        drvInstance = ((handle & DRV_SDMMC_INSTANCE_MASK) >> 8);

        if (drvInstance >= DRV_SDMMC_INSTANCES_NUMBER)
        {
            return NULL;
        }

        if ((handle & DRV_SDMMC_INDEX_MASK) >= gDrvSDMMCObj[drvInstance].nClientsMax)
        {
            return NULL;
        }

        /* Extract the client index and obtain the client object */
        clientObj = &((DRV_SDMMC_CLIENT_OBJ *)gDrvSDMMCObj[drvInstance].clientObjPool)[handle & DRV_SDMMC_INDEX_MASK];

        if ((clientObj->clientHandle != handle) || (clientObj->inUse == false))
        {
            return NULL;
        }

        /* Check if the driver is ready for operation */
        dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];
        if (dObj->status != SYS_STATUS_READY)
        {
            return NULL;
        }
    }

    return(clientObj);
}

static DRV_SDMMC_BUFFER_OBJ* lDRV_SDMMC_FreeBufferObjectGet(DRV_SDMMC_CLIENT_OBJ* clientObj)
{
    uint32_t index;
    DRV_SDMMC_OBJ* dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];
    DRV_SDMMC_BUFFER_OBJ* pBufferObj = (DRV_SDMMC_BUFFER_OBJ*)dObj->bufferObjPool;

    for (index = 0; index < dObj->bufferObjPoolSize; index++)
    {
        if (pBufferObj[index].inUse == false)
        {
            pBufferObj[index].inUse = true;
            pBufferObj[index].next = NULL;

            /* Generate a unique buffer handle consisting of an incrementing
             * token counter, driver index and the buffer index.
             */
            pBufferObj[index].commandHandle = (DRV_SDMMC_COMMAND_HANDLE)lDRV_SDMMC_MAKE_HANDLE(
                dObj->sdmmcTokenCount, (uint8_t)clientObj->drvIndex, (uint8_t)index);

            /* Update the token for next time */
            dObj->sdmmcTokenCount = lDRV_SDMMC_UPDATE_TOKEN(dObj->sdmmcTokenCount);

            return &pBufferObj[index];
        }
    }
    return NULL;
}
/* MISRA C-2012 Rule 11.3 deviated:12 Deviation record ID -  H3_MISRAC_2012_R_11_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:12 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1"
</#if>

static bool lDRV_SDMMC_BufferObjectAddToList(
    DRV_SDMMC_OBJ* dObj,
    DRV_SDMMC_BUFFER_OBJ* bufferObj
)
{
    DRV_SDMMC_BUFFER_OBJ** pBufferObjList;
    bool isFirstBufferInList = false;

    pBufferObjList = (DRV_SDMMC_BUFFER_OBJ**)&(dObj->bufferObjList);

    // Is the buffer object list empty?
    if (*pBufferObjList == NULL)
    {
        *pBufferObjList = bufferObj;
        isFirstBufferInList = true;
    }
    else
    {
        // List is not empty. Iterate to the end of the buffer object list.
        while (*pBufferObjList != NULL)
        {
            if ((*pBufferObjList)->next == NULL)
            {
                // End of the list reached, add the buffer here.
                (*pBufferObjList)->next = bufferObj;
                break;
            }
            else
            {
                pBufferObjList = (DRV_SDMMC_BUFFER_OBJ**)&((*pBufferObjList)->next);
            }
        }
    }

    return isFirstBufferInList;
}

static DRV_SDMMC_BUFFER_OBJ* lDRV_SDMMC_BufferListGet(
    DRV_SDMMC_OBJ* dObj
)
{
    DRV_SDMMC_BUFFER_OBJ* pBufferObj = NULL;

    // Return the element at the head of the linked list
    pBufferObj = (DRV_SDMMC_BUFFER_OBJ*)dObj->bufferObjList;

    return pBufferObj;
}

static void lDRV_SDMMC_RemoveBufferObjFromList(
    DRV_SDMMC_OBJ* dObj
)
{
    DRV_SDMMC_BUFFER_OBJ** pBufferObjList;

    pBufferObjList = (DRV_SDMMC_BUFFER_OBJ**)&(dObj->bufferObjList);

    // Remove the element at the head of the linked list
    if (*pBufferObjList != NULL)
    {
        /* Save the buffer object to be removed. Set the next buffer object as
         * the new head of the linked list. Reset the removed buffer object. */

        DRV_SDMMC_BUFFER_OBJ* temp = *pBufferObjList;
        *pBufferObjList = (*pBufferObjList)->next;
        temp->next = NULL;
        temp->inUse = false;
    }
}

static void lDRV_SDMMC_RemoveClientBuffersFromList(
    DRV_SDMMC_OBJ* dObj,
    DRV_SDMMC_CLIENT_OBJ* clientObj
)
{
    DRV_SDMMC_BUFFER_OBJ** pBufferObjList;
    DRV_SDMMC_BUFFER_OBJ* delBufferObj = NULL;

    pBufferObjList = (DRV_SDMMC_BUFFER_OBJ**)&(dObj->bufferObjList);

    while (*pBufferObjList != NULL)
    {
        // Do not remove the buffer object that is already in process

        if (((*pBufferObjList)->clientHandle == clientObj->clientHandle) &&
                ((*pBufferObjList)->status == DRV_SDMMC_COMMAND_QUEUED))
        {
            // Save the node to be deleted off the list
            delBufferObj = *pBufferObjList;

            // Update the current node to point to the deleted node's next
            *pBufferObjList = (DRV_SDMMC_BUFFER_OBJ*)(*pBufferObjList)->next;

            if (clientObj->eventHandler != NULL)
            {
                /* Call the event handler */
                clientObj->eventHandler((SYS_MEDIA_BLOCK_EVENT)DRV_SDMMC_EVENT_COMMAND_ERROR, delBufferObj->commandHandle, clientObj->context);
            }

            // Reset the deleted node
            delBufferObj->status = DRV_SDMMC_COMMAND_COMPLETED;
            delBufferObj->next = NULL;
            delBufferObj->inUse = false;
        }
        else
        {
            // Move to the next node
            pBufferObjList = (DRV_SDMMC_BUFFER_OBJ**)&((*pBufferObjList)->next);
        }
    }
}

static void lDRV_SDMMC_RemoveBufferObjects (
    DRV_SDMMC_OBJ* dObj
)
{
    DRV_SDMMC_BUFFER_OBJ** pBufferObjList;
    DRV_SDMMC_BUFFER_OBJ* delBufferObj = NULL;
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;

    pBufferObjList = (DRV_SDMMC_BUFFER_OBJ**)&(dObj->bufferObjList);

    while (*pBufferObjList != NULL)
    {
        // Save the node to be deleted off the list
        delBufferObj = *pBufferObjList;

        // Update the current node to point to the deleted node's next
        *pBufferObjList = (DRV_SDMMC_BUFFER_OBJ*)(*pBufferObjList)->next;

        /* Get the client object that owns this buffer */
        clientObj = &((DRV_SDMMC_CLIENT_OBJ *)dObj->clientObjPool)[delBufferObj->clientHandle & DRV_SDMMC_INDEX_MASK];

        if (clientObj->eventHandler != NULL)
        {
            /* Call the event handler */
            clientObj->eventHandler((SYS_MEDIA_BLOCK_EVENT)DRV_SDMMC_EVENT_COMMAND_ERROR, delBufferObj->commandHandle, clientObj->context);
        }

        // Reset the deleted node
        delBufferObj->next = NULL;
        delBufferObj->inUse = false;
    }
}

static void lDRV_SDMMC_UpdateGeometry( DRV_SDMMC_OBJ* dObj )
{
    uint8_t i = 0;

    /* Update the Media Geometry Table */
    for (i = 0; i <= GEOMETRY_TABLE_ERASE_ENTRY; i++)
    {
        dObj->mediaGeometryTable[i].blockSize = 512;
        dObj->mediaGeometryTable[i].numBlocks = dObj->cardCtxt.discCapacity;
    }

    /* Update the Media Geometry Main Structure */
    /* Number of read, write and erase entries in the table */
    dObj->mediaGeometryObj.numReadRegions = 1;
    dObj->mediaGeometryObj.numWriteRegions = 1;
    dObj->mediaGeometryObj.numEraseRegions = 1;
    dObj->mediaGeometryObj.geometryTable = (SYS_MEDIA_REGION_GEOMETRY *)dObj->mediaGeometryTable;
}

<#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
static void lDRV_SDMMC_SetClock (
    DRV_SDMMC_OBJ* dObj,
    uint32_t clockFrequency
)
{
    switch (dObj->clockState)
    {
        case DRV_SDMMC_CLOCK_SET_COMPLETE:
        case DRV_SDMMC_CLOCK_SET_DIVIDER:

            (void)dObj->sdmmcPlib->sdhostSetClock(clockFrequency);
            dObj->tmrHandle = SYS_TIME_HANDLE_INVALID;
            if (SYS_TIME_DelayMS(5, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
            {
                dObj->clockState = DRV_SDMMC_CLOCK_PRE_ENABLE_DELAY;
            }
            break;

        case DRV_SDMMC_CLOCK_PRE_ENABLE_DELAY:

            if (SYS_TIME_DelayIsComplete(dObj->tmrHandle) == true)
            {
                /* Delay has elapsed. */
                if (dObj->sdmmcPlib->sdhostClockEnable != NULL)
                {
                    dObj->clockState = DRV_SDMMC_CLOCK_ENABLE;
                }
                else
                {
                    dObj->clockState = DRV_SDMMC_CLOCK_SET_COMPLETE;
                }
            }
            break;

        case DRV_SDMMC_CLOCK_ENABLE:

            dObj->sdmmcPlib->sdhostClockEnable ();
            dObj->tmrHandle = SYS_TIME_HANDLE_INVALID;
            if ( SYS_TIME_DelayMS(5, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
            {
                dObj->clockState = DRV_SDMMC_CLOCK_POST_ENABLE_DELAY;
            }
            break;

        case DRV_SDMMC_CLOCK_POST_ENABLE_DELAY:

            if (SYS_TIME_DelayIsComplete(dObj->tmrHandle) == true)
            {
                /* Delay has elapsed. */
                dObj->clockState = DRV_SDMMC_CLOCK_SET_COMPLETE;
            }
            break;

        default:
            /* No action to take */
            break;
    }
}
</#if>

static void lDRV_SDMMC_PlibCallbackHandler(
    DRV_SDMMC_XFER_STATUS xferStatus,
    uintptr_t contextHandle
)
{
    DRV_SDMMC_OBJ* dObj = (DRV_SDMMC_OBJ*)contextHandle;

    if (((uint32_t)xferStatus & (uint32_t)DRV_SDMMC_XFER_STATUS_CARD_REMOVED) != 0U)
    {
        dObj->cardCtxt.isCommandCompleted = true;
        dObj->cardCtxt.isDataCompleted = true;
        dObj->cardCtxt.errorFlag |= DRV_SDMMC_CARD_REMOVAL_ERROR;
    }
    if (((uint32_t)xferStatus & (uint32_t)DRV_SDMMC_XFER_STATUS_COMMAND_COMPLETED) != 0U)
    {
        dObj->cardCtxt.isCommandCompleted = true;
        dObj->cardCtxt.errorFlag |= dObj->sdmmcPlib->sdhostGetCommandError();
    }
    if (((uint32_t)xferStatus & (uint32_t)DRV_SDMMC_XFER_STATUS_DATA_COMPLETED) != 0U)
    {
        dObj->cardCtxt.isDataCompleted = true;
        dObj->cardCtxt.errorFlag |= dObj->sdmmcPlib->sdhostGetDataError();
    }
}

static void lDRV_SDMMC_TimerCallback (
    uintptr_t context
)
{
    volatile bool* timeoutFlag = (bool* ) context;
    *timeoutFlag = true;
}

/* MISRA C-2012 Rule 14.3 deviated:2 Deviation record ID -  H3_MISRAC_2012_R_14_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:2 "MISRA C-2012 Rule 14.3" "H3_MISRAC_2012_R_14_3_DR_1"
</#if>
static void lDRV_SDMMC_InitCardContext ( uint32_t drvIndex, DRV_SDHOST_CARD_CTXT* cardCtxt )
{
    cardCtxt->isAttached            = false;
    cardCtxt->busWidth              = DRV_SDMMC_BUS_WIDTH_1_BIT;
    cardCtxt->cmd6Mode              = 0;
    cardCtxt->voltWindow            = 0;
    cardCtxt->rca                   = 0;
    cardCtxt->cardVer               = 0;
    /* HC or Standard card. */
    cardCtxt->cardType              = DRV_SDMMC_CARD_TYPE_UNKNOWN;
    /* Capacity of the card in number of blocks. */
    cardCtxt->discCapacity          = 0;
    /* Variables to track the command/data status. */
    cardCtxt->isDataCompleted       = false;
    cardCtxt->isCommandCompleted    = false;
    cardCtxt->isWriteProtected      = false;
    cardCtxt->isLocked              = false;
    cardCtxt->errorFlag             = 0;
    cardCtxt->currentFn             = 0;
    cardCtxt->nf                    = 0;
    cardCtxt->mp                    = 0;
    cardCtxt->blockSize             = 0;

<#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
    cardCtxt->scrBuffer             = &gScrBuffer[drvIndex][0];
    cardCtxt->switchStatusBuffer    = &gSwitchStatusBuffer[drvIndex][0];
    cardCtxt->extCSDBuffer          = &gExtCSDBuffer[drvIndex][0];
</#if>

    (void) memset (cardCtxt->cidBuffer, 0, DRV_SDMMC_CID_BUFFER_LEN);
    (void) memset (cardCtxt->csdBuffer, 0, DRV_SDMMC_CSD_BUFFER_LEN);
    (void) memset (cardCtxt->scrBuffer, 0, DRV_SDMMC_SCR_BUFFER_LEN);
    (void) memset (cardCtxt->switchStatusBuffer, 0, DRV_SDMMC_SWITCH_STATUS_BUFFER_LEN);
}

static void lDRV_SDMMC_ParseCSD (
    uint8_t* csdPtr,
    DRV_SDHOST_CARD_CTXT* cardCtxt,
    DRV_SDMMC_PROTOCOL protocol
)
{
    static const uint32_t TRAN_SPEED_UNIT_TABLE[] = {100000, 1000000, 10000000,
                                                     100000000, 0, 0, 0, 0};

    static const uint32_t TRAN_SPEED_MULT_TABLE[] = {0, 10, 12, 13,
                                                     15, 20, 26, 30,
                                                     35, 40, 45, 52,
                                                     55, 60, 70, 80};
    uint8_t cSizeMultiplier = 0;
    uint16_t blockLength = 0;
    uint32_t cSize = 0;
    uint32_t mult = 0;

    /* NOTE: As per JEDEC/SDMMC standard, Response to CMD9 recieved in R2 should be
   128 bit in size (16 bytes index from 0 to 15). Host controller does not
   include the last byte(CRC byte) in the response data structure. Hence
   effective response length is 15 bytes(indexed from 0 to 14) */

    if(protocol == DRV_SDMMC_PROTOCOL_SD)
    {
        cardCtxt->defaultSpeed = DRV_SDMMC_CLOCK_FREQ_DS_25_MHZ;

        /* Note: The structure format depends on if it is a CSD V1 or V2 device.
           Therefore, need to first determine version of the specs that the card
           is designed for, before interpreting the individual fields.
        */

        /* Bits 127:126 */
        if (((csdPtr[14] >> 6) & 0x03U) == 0x01U)
        {
            /* CSD Version 2.0 */

            /* C_SIZE Bits 69:48 (22-bit) */
            cSize = ((uint32_t)csdPtr[7] & 0x3FU) << 16;
            cSize |= (uint32_t)csdPtr[6] << 8;
            cSize |= csdPtr[5];

            cardCtxt->discCapacity = ((uint32_t)(cSize + 1U) * (uint32_t)(1024));
        }
        else
        {
            /* CSD Version 1.0 */

            /* Memory capacity = BLOCKNR * BLOCK_LEN
             * BLOCKNR = (C_SIZE + 1) * MULT
             * MULT = 2 POW(C_SIZE_MULT + 2)
             * BLOCK_LEN = 2 POW(READ_BL_LEN)
             */

            /* READ_BL_LEN Bits 83:80 (4-bit) */
            blockLength = (uint16_t)csdPtr[9] & 0x0FU;
            blockLength = (uint16_t)1UL << (blockLength - 9U);

            /* CSIZE Bits 73:62 (12-bit) */
            cSize = ((uint32_t)csdPtr[8] & 0x03U) << 10;
            cSize |= (uint32_t)csdPtr[7] << 2;
            cSize |= (uint32_t)csdPtr[6] >> 6;

            /* C_SIZE_MULT Bits 49:47 (3-bit) */
            cSizeMultiplier = (csdPtr[5] & 0x03U) << 1;
            cSizeMultiplier |= csdPtr[4] >> 7;

            mult = 1UL << (cSizeMultiplier + 2U);
            cardCtxt->discCapacity = (((uint32_t)(cSize + 1U) * mult) * blockLength);
        }
    }
    else
    {
        /* Get maximum supported speed (non HS mode) */
        cardCtxt->defaultSpeed = (TRAN_SPEED_MULT_TABLE[DRV_SDMMC_TRAN_SPEED_MULT_VAL(csdPtr[11])]
                  * TRAN_SPEED_UNIT_TABLE[DRV_SDMMC_TRAN_SPEED_UNIT_VAL(csdPtr[11])])
                     / 10U;

        /* Get card capacity ( size is stored in units of 512 byte pages ) */
        uint32_t readBlockLength = ((uint32_t)csdPtr[9] & 0x0FU);
        uint32_t cSizeVal =  (((uint32_t)csdPtr[8] & 0x03U) << 10) | ((uint32_t)csdPtr[7] << 2) | (((uint32_t)csdPtr[6] & 0xC0U) >> 6);
        uint32_t cSizeMult = (((uint32_t)csdPtr[5] & 0x03U) << 1) | (((uint32_t)csdPtr[4] & 0x80U) >> 7);
        cardCtxt->discCapacity = ((cSizeVal + 1U) * (1UL << (cSizeMult + 2U)) * (1UL << readBlockLength)) / 512U;
    }
}
/* MISRA C-2012 Rule 16.1, 16.3 and 16.5 deviated below.
  Deviation record ID -  H3_MISRAC_2012_R_16_1_DR_1, H3_MISRAC_2012_R_16_3_DR_1 & H3_MISRAC_2012_R_16_5_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block \
(deviate:3 "MISRA C-2012 Rule 16.1" "H3_MISRAC_2012_R_16_1_DR_1" )\
(deviate:4 "MISRA C-2012 Rule 16.3" "H3_MISRAC_2012_R_16_3_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 16.5" "H3_MISRAC_2012_R_16_1_DR_5" )
</#if>


static void lDRV_SDMMC_CommandSend (
    DRV_SDMMC_OBJ* dObj,
    uint8_t opCode,
    uint32_t argument,
    uint8_t respType,
    DRV_SDMMC_DataTransferFlags* dataTransferFlags
)
{
    switch (dObj->cmdState)
    {
        case DRV_SDMMC_CMD_EXEC_IS_COMPLETE:
        default:
            dObj->isCmdTimerExpired = false;
            dObj->cmdTimerHandle = SYS_TIME_CallbackRegisterMS (lDRV_SDMMC_TimerCallback, (uintptr_t)&dObj->isCmdTimerExpired, 2000, SYS_TIME_SINGLE);
            if(dObj->cmdTimerHandle == SYS_TIME_HANDLE_INVALID)
            {
                break;
            }
            dObj->cmdState = DRV_SDMMC_CMD_LINE_STATE_CHECK;
            /* Fall through to the next state. */

        case DRV_SDMMC_CMD_LINE_STATE_CHECK:
            if (dObj->sdmmcPlib->sdhostIsCmdLineBusy () == true)
            {
                /* Command line is busy. Wait for the line to become free. */
                if (dObj->sdmmcPlib->sdhostResetError != NULL)
                {
                    dObj->sdmmcPlib->sdhostResetError (DRV_SDMMC_RESET_CMD);
                }

                if (dObj->isCmdTimerExpired == true)
                {
                    /* Timer has expired. */
                    dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR;
                    dObj->cmdState = DRV_SDMMC_CMD_EXEC_IS_COMPLETE;
                }
                break;
            }

            if (dObj->sdmmcPlib->sdhostIsDatLineBusy() == true)
            {
                /* This command requires the use of the DAT line, but the
                 * DAT lines are busy. Wait for the lines to become free. */
                if (dObj->isCmdTimerExpired == true)
                {
                    /* Timer has expired. */
                    if (dObj->sdmmcPlib->sdhostResetError != NULL)
                    {
                        dObj->sdmmcPlib->sdhostResetError (DRV_SDMMC_RESET_DAT);
                    }
                    dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR;
                    dObj->cmdState = DRV_SDMMC_CMD_EXEC_IS_COMPLETE;
                }
                break;
            }

            //Command and data lines are available, now send the command
            dObj->cmdState = DRV_SDMMC_CMD_FRAME_AND_SEND_CMD;
            /* Fall through to the next case. */

        case DRV_SDMMC_CMD_FRAME_AND_SEND_CMD:

            dObj->cardCtxt.isCommandCompleted = false;
            dObj->cardCtxt.isDataCompleted = false;
            dObj->cardCtxt.errorFlag = 0;
            dObj->sdmmcPlib->sdhostSendCommand (opCode, argument, respType, *dataTransferFlags);
            dObj->cmdState = DRV_SDMMC_CMD_CHECK_TRANSFER_COMPLETE;
            break;

        case DRV_SDMMC_CMD_CHECK_TRANSFER_COMPLETE:

            if (dObj->cardCtxt.isCommandCompleted == true)
            {
                if ((dObj->cardCtxt.errorFlag & DRV_SDMMC_ANY_COMMAND_ERRORS) != 0U)
                {
                    if ((dObj->cardCtxt.errorFlag & DRV_SDMMC_COMMAND_TIMEOUT_ERROR) != 0U)
                    {
                        dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR;
                    }
                    else if ((dObj->cardCtxt.errorFlag & DRV_SDMMC_COMMAND_CRC_ERROR) != 0U)
                    {
                        dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_CRC_ERROR;
                    }
                    else
                    {
                        dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_ERROR;
                    }
                }
                else
                {
                    dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                }

                /* Stop the timer. */
                (void) SYS_TIME_TimerDestroy (dObj->cmdTimerHandle);

                /* Reset the state */
                dObj->cmdState = DRV_SDMMC_CMD_EXEC_IS_COMPLETE;
            }
            else
            {
                if (dObj->isCmdTimerExpired == true)
                {
                    dObj->commandStatus = DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR;
                    /* Reset the state */
                    dObj->cmdState = DRV_SDMMC_CMD_EXEC_IS_COMPLETE;
                    break;
                }
            }
            break;
    }
}


static uint8_t lDRV_SDMMC_SDIO_IO_ReadDirect(
    DRV_SDMMC_OBJ* dObj,
    uint8_t fn,
    uint32_t regAddr,
    uint8_t* outResponseData,
    uint8_t* outResponseFlags
)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR, DRV_SDMMC_CMD52_RD_DATA(fn, regAddr), (uint8_t)DRV_SDMMC_CMD_RESP_R5, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            if (outResponseFlags != NULL)
            {
                *outResponseFlags = DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(response);
            }
            if (outResponseData != NULL)
            {
                *outResponseData = DRV_SDMMC_SDIO_CMD52_RESP_DATA_GET(response);
            }

            if ((DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(response) & DRV_SDMMC_SDIO_CMD52_RESP_ERR_MSK) == 0U)
            {
                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
            else
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SDIO_IO_WriteDirect(
    DRV_SDMMC_OBJ* dObj,
    uint8_t fn,
    uint32_t regAddr,
    uint8_t wrData,
    bool raw,
    uint8_t* outReadData,
    uint8_t* outResponseFlags
)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR, DRV_SDMMC_CMD52_WR_DATA(fn, regAddr, wrData, raw), (uint8_t)DRV_SDMMC_CMD_RESP_R5, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            if (outResponseFlags != NULL)
            {
                *outResponseFlags = DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(response);
            }
            if (raw == true && outReadData != NULL)
            {
                *outReadData = DRV_SDMMC_SDIO_CMD52_RESP_DATA_GET(response);
            }

            if ((DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(response) & DRV_SDMMC_SDIO_CMD52_RESP_ERR_MSK) == 0U)
            {
                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
            else
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SDIO_CISP_Get(
    DRV_SDMMC_OBJ* dObj,
    uint8_t fn,
    uint8_t* cisp
)
{
    static uint32_t sdioAddr = 0;
    static uint8_t nBytesRead = 0;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    if (nBytesRead == 0)
    {
        sdioAddr = DRV_SDMMC_FBR_OFFSET(fn) + DRV_SDMMC_CCCR_ADDR_CSIP;
    }

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR, DRV_SDMMC_CMD52_RD_DATA(DRV_SDMMC_FN0, (sdioAddr + nBytesRead)), (uint8_t)DRV_SDMMC_CMD_RESP_R5, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            cisp[nBytesRead] = DRV_SDMMC_SDIO_CMD52_RESP_DATA_GET(response);

            nBytesRead++;

            if (nBytesRead == 3)
            {
                nBytesRead = 0;
                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
        }
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        /* Re-init all required static variables to their default state */
        nBytesRead = 0;
    }

    return status;
}

#define DRV_SDMMC_TUPLE_CODE    0
#define DRV_SDMMC_TUPLE_LINK    1
#define DRV_SDMMC_TUPLE_DATA    2

static uint8_t lDRV_SDMMC_SDIO_CIS_Tuple_Rd(
    DRV_SDMMC_OBJ* dObj,
    uint32_t cisp,
    uint8_t code,
    uint8_t* pTupleData,
    uint8_t inTupleDataBuffLen,
    uint8_t* outNumTupleDataBytes
)
{
    static uint32_t addr = 0;
    static uint8_t nTupleData = 0;
    static uint8_t tupleCode = 0;
    static uint8_t type = DRV_SDMMC_TUPLE_CODE;
    static uint8_t nTupleDataRead = 0;
    uint8_t data;
    uint32_t response;

    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    if (addr == 0)
    {
        addr = cisp;
        *outNumTupleDataBytes = 0;
    }

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR, DRV_SDMMC_CMD52_RD_DATA(DRV_SDMMC_FN0, addr), (uint8_t)DRV_SDMMC_CMD_RESP_R5, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            data = DRV_SDMMC_SDIO_CMD52_RESP_DATA_GET(response);

            switch(type)
            {
                case DRV_SDMMC_TUPLE_CODE:
                    if (data == DRV_SDMMC_SDIO_CODE_CISPTL_END)
                    {
                        /* We reached end of tuple chain */
                        status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                    }
                    else if (data == DRV_SDMMC_SDIO_CODE_CISPTL_NULL)
                    {
                        /* This tuple does not have any further bytes, continue the search */
                    }
                    else
                    {
                        /* Next byte read will contain link to next tuple in chain */
                        type = DRV_SDMMC_TUPLE_LINK;
                    }

                    tupleCode = data;

                    /* Read the next byte in the tuple chain */
                    addr++;

                break;

                case DRV_SDMMC_TUPLE_LINK:
                    nTupleData = data;

                    if (tupleCode == code)
                    {
                        /* Found the touple we are looking for. Read the tuple data. */
                        addr++;
                        type = DRV_SDMMC_TUPLE_DATA;
                    }
                    else
                    {
                        /* Skip to the next tuple in the chain */
                        addr += (nTupleData + 1);
                        type = DRV_SDMMC_TUPLE_CODE;
                    }
                break;

                case DRV_SDMMC_TUPLE_DATA:
                    if (nTupleDataRead < nTupleData)
                    {
                        pTupleData[nTupleDataRead] = data;
                        nTupleDataRead++;
                        addr++;
                    }

                    if ((nTupleDataRead >= inTupleDataBuffLen) || ((addr - cisp) >= 257) || (nTupleDataRead >= nTupleData))
                    {
                        /* Either we reached the end of the input buffer or we read 257 bytes which is the max tuple chain length allowed. */
                        /* In either case, exit. */
                        status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                    }

                break;
            }
        }
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        /* Re-init all required static variables to their default state */
        addr = 0;
        type = DRV_SDMMC_TUPLE_CODE;
        nTupleDataRead = 0;
    }

    return status;
}

static uint8_t lDRV_SDMMC_SDIO_ReadBlkSize(
    DRV_SDMMC_OBJ* dObj,
    uint8_t fn,
    uint32_t* outBlockSize
)
{
    static uint32_t cisp;
    static bool isCispRead = false;
    static uint8_t tupleData[255];
    static uint8_t tupleDataBytesRead = 0;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    if (isCispRead == false)
    {
        if (lDRV_SDMMC_SDIO_CISP_Get(dObj, fn, (uint8_t*)&cisp) == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            isCispRead = true;
        }
    }

    if (isCispRead)
    {
        status = lDRV_SDMMC_SDIO_CIS_Tuple_Rd(
            dObj,
            cisp,
            DRV_SDMMC_SDIO_CODE_CISPTL_FUNCE,
            tupleData,
            255,
            &tupleDataBytesRead);

        if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            if (fn == DRV_SDMMC_FN0)
            {
                *outBlockSize = (tupleData[2] << 8) | tupleData[1];
            }
            else
            {
                *outBlockSize = (tupleData[13] << 8) | tupleData[12];
            }
        }
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        /* Re-init all required static variables to their default state */
        isCispRead = false;
    }

    return status;
}

static uint8_t lDRV_SDMMC_SDIO_SetBlkSize(
    DRV_SDMMC_OBJ* dObj,
    uint8_t fn,
    uint16_t blockSize
)
{
    static uint32_t sdioAddr = 0;
    static uint8_t nBytesWritten = 0;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    if (nBytesWritten == 0)
    {
        dObj->dataTransferFlags.isDataPresent = false;
        sdioAddr = DRV_SDMMC_FBR_OFFSET(fn) + DRV_SDMMC_CCCR_ADDR_FN0_BLK_SZ;
    }

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR, DRV_SDMMC_CMD52_WR_DATA(DRV_SDMMC_FN0, (sdioAddr + nBytesWritten), ((uint8_t*)&blockSize)[nBytesWritten], 0), (uint8_t)DRV_SDMMC_CMD_RESP_R5, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            if ((DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(response) & DRV_SDMMC_SDIO_CMD52_RESP_ERR_MSK) == 0U)
            {
                nBytesWritten++;

                if (nBytesWritten == 2)
                {
                    status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                }
            }
            else
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
         /* Re-init all required static variables to their default state */
        nBytesWritten = 0;
    }

    return status;
}

static uint8_t DRV_SDMMC_SDIO_Enable4BitBusWidth(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status;
    uint8_t readData;

    status = lDRV_SDMMC_SDIO_IO_WriteDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_BIC, DRV_SDMMC_CCCR_BUS_WIDTH_4B, true, &readData, NULL);

    if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
    {
        if ((readData & DRV_SDMMC_CCCR_BUS_WIDTH_MSK) != DRV_SDMMC_CCCR_BUS_WIDTH_4B)
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

#define DRV_SDMMC_SDIO_EN_IO           0
#define DRV_SDMMC_SDIO_EN_RDY_WAIT     1


static uint8_t lDRV_SDMMC_SDIO_IOEnable(DRV_SDMMC_OBJ* dObj)
{
    static uint8_t state = DRV_SDMMC_SDIO_EN_IO;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint8_t readData;
    uint8_t wrData = (((1 << dObj->cardCtxt.nf)-1)<<1);

    switch(state)
    {
        default:
        case DRV_SDMMC_SDIO_EN_IO:

            status = lDRV_SDMMC_SDIO_IO_WriteDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_IO_EN, wrData, true, &readData, NULL);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (readData == wrData)
                {
                    status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
                    state = DRV_SDMMC_SDIO_EN_RDY_WAIT;
                }
            }
            break;
        case DRV_SDMMC_SDIO_EN_RDY_WAIT:

            status = lDRV_SDMMC_SDIO_IO_ReadDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_IO_RDY, &readData, NULL);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (readData != wrData)
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            break;
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        state = DRV_SDMMC_SDIO_EN_IO;
    }

    return status;
}

static uint8_t lDRV_SDMMC_SDIO_EnableHSMode(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status;
    uint8_t readData;

    status = lDRV_SDMMC_SDIO_IO_WriteDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_BUS_SPD_SEL, DRV_SDMMC_CCCR_EHS_MSK, true, &readData, NULL);

    if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
    {
        if ((readData & DRV_SDMMC_CCCR_EHS_MSK) != 0U)
        {
            /*HS (50 MHz) set successfully by the card. Now change the host speed to HS. */

            if (dObj->sdmmcPlib->sdhostSetClock(DRV_SDMMC_CLOCK_FREQ_HS_50_MHZ) == true)
            {
                dObj->cardCtxt.currentSpeed = DRV_SDMMC_CLOCK_FREQ_HS_50_MHZ;

                dObj->sdmmcPlib->sdhostSetSpeedMode (DRV_SDMMC_SPEED_MODE_HIGH);
            }
            else
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SDIO_SendOpCond(
    DRV_SDMMC_OBJ* dObj
)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;
    static bool cmdInit = true;

    dObj->dataTransferFlags.isDataPresent = false;

    if (cmdInit)
    {
        dObj->cardCtxt.voltWindow = 0x00;

        if (SYS_TIME_DelayMS (2000, &dObj->generalTimerHandle) == SYS_TIME_ERROR)
        {
            return DRV_SDMMC_COMMAND_STATUS_ERROR;
        }

        cmdInit = false;
    }

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SDIO_SEND_OP_COND, (dObj->cardCtxt.voltWindow << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R4, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);

            dObj->cardCtxt.nf = (response & DRV_SDMMC_R4_NF_MSK) >> DRV_SDMMC_R4_NF_POS;
            dObj->cardCtxt.mp = (response & DRV_SDMMC_R4_MP_MSK) >> DRV_SDMMC_R4_MP_POS;

            if ((response & 0x3C0000U) == 0U)
            {
                /* Working Voltage (WV) for I/O not within the range of host device. Cannot initialize the IO portion of the card. */
                dObj->cardCtxt.nf = 0;

                (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);

                if (dObj->cardCtxt.mp == 1)
                {
                   status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                }
                else
                {
                    /* mp = 0 and nf =0, it is an unusable card */
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            else
            {
                /* IO OCR valid. Check if IO portion of the card is ready. */

                if ((response & DRV_SDMMC_R4_C_MSK) != 0U)
                {
                    /* Card ready. Destroy the timeout timer */
                    (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);

                    if (dObj->cardCtxt.mp == 1 || dObj->cardCtxt.nf > 0)
                    {
                       status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                    }
                    else
                    {
                        /* mp = 0 and nf =0, it is an unusable card */
                        status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                    }

                }
                else
                {
                    /* Card not ready yet. Check if we timed out */
                    if (SYS_TIME_DelayIsComplete(dObj->generalTimerHandle) == true)
                    {
                        /* The IO portion of the card did not initialize with 1 second. Hence set the nf to 0.*/
                        dObj->cardCtxt.nf = 0;

                        if (dObj->cardCtxt.mp == 1)
                        {
                           status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                        }
                        else
                        {
                            /* mp = 0 and nf =0, it is an unusable card */
                            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                        }
                    }
                    else
                    {
                        /* Continue checking card status by sending CMD5, but now with a non-zero value for WV */
                        dObj->cardCtxt.voltWindow = 0x3C;
                    }
                }
            }
        }
        else
        {
            dObj->cardCtxt.nf = 0;
            dObj->cardCtxt.mp = 0;

            if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR)
            {
                /* No response. Possibly, not an SDIO card. Continue with memory initialization. */
                (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);

                status = DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR;
            }
            else
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        /* Before leaving, make sure next time the preconditions for the command are executed. */
        cmdInit = true;
    }
    return status;
}

static uint8_t lDRV_SDMMC_SendCID_CMD2(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_ALL_SEND_CID, 0x00, (uint8_t)DRV_SDMMC_CMD_RESP_R2, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_ALL, (uint32_t *)&dObj->cardCtxt.cidBuffer[0]);

            status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}


static uint8_t lDRV_SDMMC_GetRelativeAddr_CMD3(DRV_SDMMC_OBJ* dObj)
{
    //CMD3 - Ask the SD Card to publish a relative card address (RCA)

    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SEND_RCA, 0x00, (uint8_t)DRV_SDMMC_CMD_RESP_R6, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            if ((response & 0xE000U) != 0U)
            {
                /* Status bits 23, 22 and 19. Command CRC error,
                 * illegal command and error respectively.  */

                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
            else
            {
                dObj->cardCtxt.rca = (uint16_t)((response >> 16) & 0xFFFFU);

                if (dObj->cardCtxt.rca == 0U)
                {
                    /* Repeat this command until the card publishes a non-zero RCA. */

                    status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
                }
                else
                {
                    /* Non-zero RCA published by the card */
                    status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                }
            }
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SetRelativeAddr_CMD3(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    dObj->dataTransferFlags.isDataPresent = false;

    /* Assign relative address to the device (CMD3) */
    lDRV_SDMMC_CommandSend (
        dObj,
        (uint8_t)DRV_SDMMC_CMD_SEND_RCA,
        DRV_SDMMC_SEND_RCA_ARG,
        (uint8_t)DRV_SDMMC_CMD_RESP_R1,
        &dObj->dataTransferFlags
    );

    /* Command execution is complete */
    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        /* Command execution is successful */
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
             /* Read command response */
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

            /* Check for possible errors */
            if ((response & DRV_SDMMC_SET_RELATIVE_ADDR_ERROR) != 0U)
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
            else
            {
                /* Update the local buffer and move on to next state */
                dObj->cardCtxt.rca = (uint16_t)DRV_SDMMC_EMMC_RCA;
                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

#define DRV_SDMMC_EXT_CSD_INIT          0
#define DRV_SDMMC_EXT_CSD_CMD           1
#define DRV_SDMMC_EXT_CSD_DATA          2

static uint8_t lDRV_SDMMC_ExtendedCSDRead(DRV_SDMMC_OBJ* dObj)
{
    static uint8_t state = DRV_SDMMC_EXT_CSD_INIT;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    switch(state)
    {
        default:
        case DRV_SDMMC_EXT_CSD_INIT:
            dObj->dataTransferFlags.isDataPresent = true;
            dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_READ;
            dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SINGLE;

            dObj->sdmmcPlib->sdhostSetBlockCount (0);
            dObj->sdmmcPlib->sdhostSetBlockSize(DRV_SDMMC_EXT_CSD_RESP_SIZE);

            <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
            /* Invalidate the cache to force the CPU to read the latest data from the main memory */
              SYS_CACHE_InvalidateDCache_by_Addr(dObj->cardCtxt.extCSDBuffer, (int32_t)DRV_SDMMC_EXT_CSD_RESP_SIZE);
            </#if>

            dObj->sdmmcPlib->sdhostSetupDma(
                dObj->cardCtxt.extCSDBuffer,
                DRV_SDMMC_EXT_CSD_RESP_SIZE,
                DRV_SDMMC_DATA_XFER_DIR_RD
            );

            state = DRV_SDMMC_EXT_CSD_CMD;

            break;
        case DRV_SDMMC_EXT_CSD_CMD:

            lDRV_SDMMC_CommandSend (
                dObj,
                (uint8_t)DRV_SDMMC_CMD_SEND_EXT_CSD,
                DRV_SDMMC_CMD_ARG_NULL,
                (uint8_t)DRV_SDMMC_CMD_RESP_R1,
                &dObj->dataTransferFlags
            );

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                dObj->dataTransferFlags.isDataPresent = false;

                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    state = DRV_SDMMC_EXT_CSD_DATA;
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }

            break;

        case DRV_SDMMC_EXT_CSD_DATA:
            if (dObj->cardCtxt.isDataCompleted == true)
            {
                dObj->cardCtxt.discCapacity = DRV_SDMMC_EXT_CSD_GET_SEC_COUNT((uint32_t)dObj->cardCtxt.extCSDBuffer);
                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
            break;
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        state = DRV_SDMMC_EXT_CSD_INIT;
    }

    return status;
}

static uint8_t lDRV_SDMMC_SendCSD_CMD9(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj,
        (uint8_t)DRV_SDMMC_CMD_SEND_CSD,
        DRV_SDMMC_DEVICE_RCA_VAL((uint32_t)dObj->cardCtxt.rca),
        (uint8_t)DRV_SDMMC_CMD_RESP_R2,
        &dObj->dataTransferFlags
    );

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_ALL, (uint32_t *)&dObj->cardCtxt.csdBuffer[0]);

            lDRV_SDMMC_ParseCSD (&dObj->cardCtxt.csdBuffer[0], &dObj->cardCtxt, dObj->protocol);

            status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SendAppCmd_CMD55(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    dObj->dataTransferFlags.isDataPresent = false;

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_APP_CMD, ((uint32_t)dObj->cardCtxt.rca << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SendIFCond_CMD8(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    dObj->dataTransferFlags.isDataPresent = false;

    /* VHS = 2.7-3.3V, Check Pattern = 0xAA */

    lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SEND_IF_COND, 0x1AA, (uint8_t)DRV_SDMMC_CMD_RESP_R7, &dObj->dataTransferFlags);

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);

            if ((response & 0x1FFU) == 0x1AAU)
            {
                /* Card responded to CMD8, hence, the Card version is 2.0 or higher. */
                dObj->cardCtxt.cardVer = 1;

                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
            else
            {
                /* Cannot initialize this card. */
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
        else
        {
            if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR)
            {
                /* The card doesn't support CMD8. Either voltage mismatch Or Ver1.X SD Memory card Or Not a SD Card. */
                /* However, this is not a protocol error. */

                dObj->cardCtxt.cardVer = 0;

                status = DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR;
            }
            else
            {
                /* Cannot initialize this card. */
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
    }

    return status;
}

#define DRV_SDMMC_INIT_CMD1             0
#define DRV_SDMMC_SEND_CMD1             1

static uint8_t lDRV_SDMMC_SendOPCond_CMD1(DRV_SDMMC_OBJ* dObj)
{
    static uint8_t state = DRV_SDMMC_INIT_CMD1;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    switch (state)
    {
        default:
        case DRV_SDMMC_INIT_CMD1:
            if (SYS_TIME_DelayMS (2000, &dObj->generalTimerHandle) == SYS_TIME_ERROR)
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                break;
            }
            else
            {
                state = DRV_SDMMC_SEND_CMD1;
            }
            /* fall through */

        case DRV_SDMMC_SEND_CMD1:
            /* Ask devices to send its operating conditions (CMD1)*/
            lDRV_SDMMC_CommandSend (
                dObj,
                (uint8_t)DRV_SDMMC_CMD_SEND_OP_COND,
                DRV_SDMMC_SUPPORTED_OP_COND,
                (uint8_t)DRV_SDMMC_CMD_RESP_R3,
                &dObj->dataTransferFlags
            );

            /* Command execution is complete */
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                /* Command executed successfully */
                if(dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    /* Read command response */
                    dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, (uint32_t *)&response);

                    /* Device is not busy */
                    if ((response & DRV_SDMMC_OCR_NBUSY) != 0U)
                    {
                        /* If card supports sector access, card is of high capacity */

                        dObj->cardCtxt.cardType = \
                        ((response & DRV_SDMMC_OCR_ACCESS_MODE) == DRV_SDMMC_OCR_ACCESS_SECTOR) ? \
                        DRV_SDMMC_CARD_TYPE_HC : DRV_SDMMC_CARD_TYPE_STANDARD;

                        status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                    }
                    else
                    {
                        /* Check if we timedout waiting for the card's internal state machine to get initialized*/
                        if (SYS_TIME_DelayIsComplete(dObj->generalTimerHandle) == true)
                        {
                            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                        }
                    }
                }
            }

            break;
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        state = DRV_SDMMC_INIT_CMD1;
    }

    return status;
}

#define DRV_SDMMC_INIT_ACMD41           0
#define DRV_SDMMC_SEND_APP_CMD55        1
#define DRV_SDMMC_SEND_ACMD41           2

static uint8_t lDRV_SDMMC_SendOpCond_ACMD41(DRV_SDMMC_OBJ* dObj)
{
    //ACMD41
    /* BIT30=> HCS (Host Capacity Support): 0 = SDSC, 1 = SDMMC/SDXC
     * For cards that respond to CMD8, host specifies the HCS bit as
     * either 0 or 1. For cards that do not respond to CMD8, the HCS bit
     * is ignored by the SD cards. Specify voltage range of 3.0 to 3.4V.
     */

    static uint8_t state = DRV_SDMMC_INIT_ACMD41;

    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    switch(state)
    {
        default:
        case DRV_SDMMC_INIT_ACMD41:
            dObj->cardCtxt.voltWindow = 0x00;

            if (SYS_TIME_DelayMS (2000, &dObj->generalTimerHandle) == SYS_TIME_ERROR)
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                break;
            }
            else
            {
                state = DRV_SDMMC_SEND_APP_CMD55;
            }
            /* fall through */
        case DRV_SDMMC_SEND_APP_CMD55:
            status = lDRV_SDMMC_SendAppCmd_CMD55(dObj);

            if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
            {
                if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    /* Change the status to in progress for ACMD41 command */
                    status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
                    state = DRV_SDMMC_SEND_ACMD41;
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            break;
        case DRV_SDMMC_SEND_ACMD41:
            dObj->dataTransferFlags.isDataPresent = false;

            lDRV_SDMMC_CommandSend(dObj, (uint8_t)DRV_SDMMC_CMD_SD_SEND_OP_COND, ((uint32_t)dObj->cardCtxt.cardVer << 30) | ((uint32_t)dObj->cardCtxt.voltWindow << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R3, &dObj->dataTransferFlags);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);

                    /* Check if the card has set any one of the supported voltage range bits. */
                    if ((response & 0x3C0000U) == 0U)
                    {
                        /* Cannot initialize the card. Destroy the timer before leaving. */

                        (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);

                        status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                    }
                    else
                    {
                        /* Check if cards internal initialization is complete. */
                        if ((response & (1UL << 31)) != 0U)
                        {
                            /* Check card capacity - CCS bit */
                            if ((response & (1UL << 30)) != 0U)
                            {
                                dObj->cardCtxt.cardType = DRV_SDMMC_CARD_TYPE_HC;
                            }
                            else
                            {
                                /* Byte addressing */
                                dObj->cardCtxt.cardType = DRV_SDMMC_CARD_TYPE_STANDARD;
                            }

                            /* Destroy the timer before leaving */
                            (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);

                            status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                        }
                        else
                        {
                            /* Check if we timedout waiting for the card's internal state machine to get initialized*/
                            if (SYS_TIME_DelayIsComplete(dObj->generalTimerHandle) == true)
                            {
                                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                            }
                            else
                            {
                                /* Voltage window - 3.0V to 3.4V */
                                dObj->cardCtxt.voltWindow = 0x3C;

                                /* Repeat the APPCMD and the ACMD41 until the
                                 * card sets the ready bit or until timeout. */

                                state = DRV_SDMMC_SEND_APP_CMD55;
                            }
                        }
                    }
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            break;
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        /* Re-init the required static variables */
        state = DRV_SDMMC_INIT_ACMD41;
    }

    return status;
}

static uint8_t lDRV_SDMMC_SetBusWidth_CMD6(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    lDRV_SDMMC_CommandSend (
        dObj,
        (uint8_t)DRV_SDMMC_CMD_SWITCH,
        DRV_SDMMC_SWITCH_BUS_WIDTH_ARGU((uint32_t)dObj->busWidth),
        (uint8_t)DRV_SDMMC_CMD_RESP_R1B,
        &dObj->dataTransferFlags
    );

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}

static uint8_t lDRV_SDMMC_SetBusWidth_ACMD6(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    static bool isCmd55Sent = false;

    if (isCmd55Sent == false)
    {
        status = lDRV_SDMMC_SendAppCmd_CMD55(dObj);

        if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            isCmd55Sent = true;

            status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
        }
    }
    else
    {
        lDRV_SDMMC_CommandSend (
                dObj,
                (uint8_t)DRV_SDMMC_CMD_SET_BUS_WIDTH,
                0x02,
                (uint8_t)DRV_SDMMC_CMD_RESP_R1,
                &dObj->dataTransferFlags
        );

        if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
        {
            if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
            }
            else
            {
                status = DRV_SDMMC_COMMAND_STATUS_ERROR;
            }
        }
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        isCmd55Sent = false;
    }

    return status;
}

#define ACMD51_ISSUE_APP_CMD         0
#define ACMD51_CHK_RESPONSE          1
#define ACMD51_READ_SCR              2
#define ACMD51_PARSE_SCR             3

static uint8_t lDRV_SDMMC_SendSCR_ACMD51(DRV_SDMMC_OBJ* dObj, uint8_t* scrBuffer)
{
    /* 1-bit and 4-bit bus width support is given in the SCR register. SCR register is read by issuing ACMD51.*/
    /* ACMD51 can be issued only when the card is in "tran" state */

    static uint8_t state = ACMD51_ISSUE_APP_CMD;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
    uint32_t response;

    switch(state)
    {
        default:
        case ACMD51_ISSUE_APP_CMD:
            status = lDRV_SDMMC_SendAppCmd_CMD55(dObj);
            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (SYS_TIME_DelayMS(5, &(dObj->generalTimerHandle)) == SYS_TIME_SUCCESS)
                {
                    status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
                    state = ACMD51_CHK_RESPONSE;
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            break;

        case ACMD51_CHK_RESPONSE:
            if (SYS_TIME_DelayIsComplete(dObj->generalTimerHandle) == true)
            {
                dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);

                if ((response & (1UL << 25)) != 0U)
                {
                    /* Card is locked, ACMD51 cannot be issued if the card is locked, return error. */
                    dObj->cardCtxt.isLocked = true;

                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
                else
                {
                    dObj->cardCtxt.isLocked = false;

                    /* Check if the card is in the transfer state. If not, then fail the card init. */
                    if ((response & 0x800U) == 0U)
                    {
                        /* Not in "tran" state, mark as error */
                        status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                    }
                    else
                    {
                        /* SCR response is 64-bits (or 8 bytes). Set the block length to 8 bytes */

                        dObj->sdmmcPlib->sdhostSetBlockSize(8);

                        dObj->dataTransferFlags.isDataPresent = true;
                        dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_READ;
                        dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SINGLE;

                        <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                        /* Invalidate the cache to force the CPU to read the latest data
                         * from the main memory. */
                        uint32_t readBufferLen = DRV_SDMMC_SCR_BUFFER_LEN;
                        SYS_CACHE_InvalidateDCache_by_Addr(scrBuffer, (int32_t)readBufferLen);
                        </#if>

                        /* Set up the DMA for the data transfer. */
                        dObj->sdmmcPlib->sdhostSetupDma (scrBuffer, 8, DRV_SDMMC_DATA_XFER_DIR_RD);

                        status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;
                        state = ACMD51_READ_SCR;
                    }
                }
            }
            break;

        case ACMD51_READ_SCR:
            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_READ_SCR, 0x00, (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                dObj->dataTransferFlags.isDataPresent = false;

                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    state = ACMD51_PARSE_SCR;
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            break;

        case ACMD51_PARSE_SCR:

            /* Wait for the data phase to be completed. */

            if (dObj->cardCtxt.isDataCompleted == true)
            {
                /* Check if there are any data errors. */
                if ((dObj->cardCtxt.errorFlag & DRV_SDMMC_ANY_DATA_ERRORS) != 0U)
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
                }
            }
            break;
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        state = ACMD51_ISSUE_APP_CMD;
    }

    return status;
}

static uint8_t lDRV_SDMMC_EMMC_SwitchHS_CMD6(DRV_SDMMC_OBJ* dObj)
{
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    lDRV_SDMMC_CommandSend (
        dObj,
        (uint8_t)DRV_SDMMC_CMD_SWITCH,
        DRV_SDMMC_SWITCH_HS_ARGU,
        (uint8_t)DRV_SDMMC_CMD_RESP_R1B,
        &dObj->dataTransferFlags
    );

    if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
    {
        if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
        {
            status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;
        }
        else
        {
            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
        }
    }

    return status;
}



#define DRV_SDMMC_CMD6_SETUP      1
#define DRV_SDMMC_CMD6_ISSUE      2
#define DRV_SDMMC_CMD6_STATUS     3

static uint8_t lDRV_SDMMC_CheckSwitchHS_CMD6(DRV_SDMMC_OBJ* dObj, uint8_t mode, bool* outIsSupported)
{
    static uint8_t state = DRV_SDMMC_CMD6_SETUP;
    uint8_t status = DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS;

    switch(state)
    {
        default:
        case DRV_SDMMC_CMD6_SETUP:
            //Response to CMD6 is 512 bits (64 bytes)
            //mode 0 - To query if the card supports a specific function
            //mode 1 - To switch to the specific function

            /* Set the block length to 64 bytes. */
            dObj->sdmmcPlib->sdhostSetBlockSize (64);

            dObj->dataTransferFlags.isDataPresent = true;
            dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_READ;
            dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SINGLE;

            <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
            /* Invalidate the cache to force the CPU to read the latest data
             * from the main memory. */
            SYS_CACHE_InvalidateDCache_by_Addr(dObj->cardCtxt.switchStatusBuffer, (int32_t)DRV_SDMMC_SWITCH_STATUS_BUFFER_LEN);
            </#if>

            /* Set up the DMA for the data transfer. */
            dObj->sdmmcPlib->sdhostSetupDma (&dObj->cardCtxt.switchStatusBuffer[0], 64, DRV_SDMMC_DATA_XFER_DIR_RD);
            state = DRV_SDMMC_CMD6_ISSUE;

            /* Fall through to the next case. */

        case DRV_SDMMC_CMD6_ISSUE:
            //Mode[31]=> 0 = Check, 1 = Switch
            //[3:0] => Function Group 1 for Access Mode - Select function (0-0xF) in Function Group 1

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SWITCH_FUNCTION, (0x00FFFF01U) | ((uint32_t)mode << 31), (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                dObj->dataTransferFlags.isDataPresent = false;

                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    /* Now wait for the data from the card. */
                    state = DRV_SDMMC_CMD6_STATUS;
                }
                else
                {
                    /* Command execution failed. */
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
            }
            break;

        case DRV_SDMMC_CMD6_STATUS:
            if (dObj->cardCtxt.isDataCompleted == true)
            {
                /* Check if there are any data errors. */
                if ((dObj->cardCtxt.errorFlag & DRV_SDMMC_ANY_DATA_ERRORS) != 0U)
                {
                    status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                }
                else
                {
                    status = DRV_SDMMC_COMMAND_STATUS_SUCCESS;

                    /* Wait for the data transfer to complete. */
                    if (mode == 1U)
                    {
                        /* Bits 379:376 should be set to 1 if the switch was successful. */
                        if ((dObj->cardCtxt.switchStatusBuffer[16] & 0x0FU) != 0x01U)
                        {
                            status = DRV_SDMMC_COMMAND_STATUS_ERROR;
                        }
                    }
                    else
                    {
                        /* Bit 401 should be set indicating HS support. */
                        if ((dObj->cardCtxt.switchStatusBuffer[13] & 0x02U) != 0U)
                        {
                            /* The card supports switching to HS mode of operation */

                            *outIsSupported = true;
                        }
                    }
                }
            }
            break;
    }

    if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
    {
        state = DRV_SDMMC_CMD6_SETUP;
    }

    return status;
}

static void lDRV_SDMMC_MediaInitialize (
    DRV_SDMMC_OBJ* dObj
)
{
    uint8_t status = 0;
    uint8_t readData = 0;

    switch (dObj->initState)
    {
        case DRV_SDMMC_INIT_SET_INIT_SPEED:
            if (dObj->cardCtxt.currentSpeed != DRV_SDMMC_CLOCK_FREQ_400_KHZ)
            {
<#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
                lDRV_SDMMC_SetClock (dObj, DRV_SDMMC_CLOCK_FREQ_400_KHZ);
                if (dObj->clockState == DRV_SDMMC_CLOCK_SET_COMPLETE)
<#else>
                if (dObj->sdmmcPlib->sdhostSetClock(DRV_SDMMC_CLOCK_FREQ_400_KHZ) == true)
</#if>
                {
                    dObj->cardCtxt.currentSpeed = DRV_SDMMC_CLOCK_FREQ_400_KHZ;
                }
            }
            else
            {
                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    if (SYS_TIME_DelayMS(dObj->cardDetectionPollingIntervalMs, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
                    {
                        dObj->initState = DRV_SDMMC_INIT_WAIT_POLLING_TIMEOUT;
                        dObj->nextInitState = (dObj->protocol == DRV_SDMMC_PROTOCOL_SD)? DRV_SDMMC_INIT_RESET_IO_CARD : DRV_SDMMC_INIT_RESET_MEM_CARD;
                    }
                    else
                    {
                        dObj->initState = DRV_SDMMC_INIT_ERROR;
                    }
                }
                else
                {
                    dObj->initState = (dObj->protocol == DRV_SDMMC_PROTOCOL_SD)? DRV_SDMMC_INIT_RESET_IO_CARD : DRV_SDMMC_INIT_RESET_MEM_CARD;
                }
            }
            break;

        case DRV_SDMMC_INIT_WAIT_POLLING_TIMEOUT:
            if (SYS_TIME_DelayIsComplete(dObj->tmrHandle) == true)
            {
                /* Delay has elapsed. */
                dObj->initState = dObj->nextInitState;
            }
            break;

        case DRV_SDMMC_INIT_RESET_IO_CARD:
            status = lDRV_SDMMC_SDIO_IO_WriteDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_IO_ABORT, DRV_SDMMC_CCCR_IO_ABORT_RES, false, NULL, NULL);
            if (status != DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS)
            {
                if (SYS_TIME_DelayMS(100, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
                {
                    dObj->initState = DRV_SDMMC_INIT_WAIT_POLLING_TIMEOUT;
                    dObj->nextInitState = DRV_SDMMC_INIT_RESET_MEM_CARD;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            break;

        case DRV_SDMMC_INIT_RESET_MEM_CARD:
            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_GO_IDLE_STATE, 0x0, (uint8_t)DRV_SDMMC_CMD_RESP_NONE, &dObj->dataTransferFlags);

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (SYS_TIME_DelayMS(100, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
                {
                    dObj->initState = DRV_SDMMC_INIT_WAIT_POLLING_TIMEOUT;

                    if(dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
                    {
                        /* For SD check the interface condition */
                        dObj->nextInitState = DRV_SDMMC_INIT_CHK_IFACE_CONDITION;
                    }
                    else
                    {
                        /* For eMMC send the supported op conditions */
                        dObj->nextInitState = DRV_SDMMC_INIT_SEND_OP_COND;
                        dObj->trials = 20;
                    }
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            break;

        case DRV_SDMMC_INIT_CHK_IFACE_CONDITION:

            status = lDRV_SDMMC_SendIFCond_CMD8(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS || status == DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR)
            {
                dObj->sdCardType = 0;

                /* Check if its an SDIO card (IO only or Combo) */
                dObj->initState = DRV_SDMMC_INIT_SDIO_CMD5;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                /* Cannot initialize the SD Card. */
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }

            break;

        case DRV_SDMMC_INIT_SDIO_CMD5:

            status = lDRV_SDMMC_SDIO_SendOpCond(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->cardCtxt.nf > 0)
                {
                    /* IO initialization */
                    dObj->initState = DRV_SDMMC_INIT_GET_RCA;
                    dObj->sdCardType |= CARD_TYPE_SD_IO;
                }
                if (dObj->cardCtxt.mp == 1)
                {
                    /* Memory initialization is done first if it is a combo card */
                    dObj->initState = DRV_SDMMC_INIT_SEND_ACMD41;
                    dObj->sdCardType |= CARD_TYPE_SD_MEM;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR)
            {
                /* Possibly not an SDIO card. Proceed with standard memory card initialization */

                dObj->initState = DRV_SDMMC_INIT_SEND_ACMD41;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                /* Cannot initialize this card. */
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }

            break;

        case DRV_SDMMC_INIT_SEND_ACMD41:

            status = lDRV_SDMMC_SendOpCond_ACMD41(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->sdCardType |= CARD_TYPE_SD_MEM;
                dObj->initState = DRV_SDMMC_INIT_ALL_SEND_CID;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                /* Cannot initialize the SD Card. */
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }

            break;

        case DRV_SDMMC_INIT_SEND_OP_COND:
            /* Ask devices to send its operating conditions (CMD1)*/
            status = lDRV_SDMMC_SendOPCond_CMD1(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_ALL_SEND_CID;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                /* Cannot initialize the SD Card. */
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_ALL_SEND_CID:

            status = lDRV_SDMMC_SendCID_CMD2(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if(dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
                {
                    dObj->initState = DRV_SDMMC_INIT_GET_RCA;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_RELATIVE_ADDR;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                /* Cannot initialize the SD Card. */
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }

            break;

        case DRV_SDMMC_INIT_GET_RCA:

            status = lDRV_SDMMC_GetRelativeAddr_CMD3(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                {
                    dObj->initState = DRV_SDMMC_INIT_READ_CSD;
                }
                else if (dObj->sdCardType & CARD_TYPE_SD_IO)
                {
                    dObj->initState = DRV_SDMMC_INIT_SELECT_CARD;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }

            break;

        case DRV_SDMMC_INIT_SET_RELATIVE_ADDR:
           /* Assign relative address to the device (CMD3) */

            status = lDRV_SDMMC_SetRelativeAddr_CMD3(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_READ_CSD;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_READ_CSD:

            status = lDRV_SDMMC_SendCSD_CMD9(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_SELECT_CARD;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }

            break;

        case DRV_SDMMC_INIT_SELECT_CARD:

            lDRV_SDMMC_CommandSend (
                dObj,
                (uint8_t)DRV_SDMMC_CMD_SELECT_DESELECT_CARD,
                DRV_SDMMC_DEVICE_RCA_VAL((uint32_t)dObj->cardCtxt.rca),
                (uint8_t)DRV_SDMMC_CMD_RESP_R1B,
                &dObj->dataTransferFlags
            );

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    /* Give time for card to transition to Transfer or Command state */
                    if (SYS_TIME_DelayMS(10, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
                    {
                        dObj->initState = DRV_SDMMC_INIT_WAIT_POLLING_TIMEOUT;

                        if(dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
                        {
                            if (dObj->sdCardType & CARD_TYPE_SD_IO)
                            {
                                dObj->nextInitState = DRV_SDMMC_INIT_SDIO_READ_SDIO_CCCR_REV;
                            }
                            else if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                            {
                                dObj->nextInitState = DRV_SDMMC_INIT_SCR_READ;
                            }
                        }
                        else
                        {
                            dObj->nextInitState = DRV_SDMMC_INIT_READ_EXT_CSD;
                        }
                    }
                    else
                    {
                        dObj->initState = DRV_SDMMC_INIT_ERROR;
                    }
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            break;

        case DRV_SDMMC_INIT_SDIO_READ_SDIO_CCCR_REV:

            status = lDRV_SDMMC_SDIO_IO_ReadDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_SDIO_REV, &dObj->cardCtxt.sdioCCCRRev, NULL);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_RD_CARD_CAP_SDIO;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_RD_CARD_CAP_SDIO:

            status = lDRV_SDMMC_SDIO_IO_ReadDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_CARD_CAP, &dObj->cardCtxt.sdioCardCapability, NULL);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                {
                    dObj->initState = DRV_SDMMC_INIT_SCR_READ;
                }
                else if (dObj->sdCardType & CARD_TYPE_SD_IO)
                {
                    dObj->initState = DRV_SDMMC_INIT_DECIDE_BUS_WIDTH;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_SCR_READ:

            status = lDRV_SDMMC_SendSCR_ACMD51(dObj, dObj->cardCtxt.scrBuffer);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_DECIDE_BUS_WIDTH;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                if (dObj->cardCtxt.isLocked == true)
                {
                    /* Mark the initialization as complete. */
                    dObj->initState = DRV_SDMMC_INIT_DONE;
                }
                else
                {
                    /* Cannot initialize the SD Card. */
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            break;

        case DRV_SDMMC_INIT_DECIDE_BUS_WIDTH:

            if (dObj->busWidth == DRV_SDMMC_BUS_WIDTH_4_BIT)
            {
                if(dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
                {
                    bool sdio4B = false;
                    bool sdmem4B = false;

                    if (dObj->sdCardType & CARD_TYPE_SD_IO)
                    {
                        sdio4B = ((dObj->cardCtxt.sdioCardCapability & DRV_SDMMC_CCCR_LSC_MSK) == 0U) ? true : (((dObj->cardCtxt.sdioCardCapability & DRV_SDMMC_CCCR_4BLS_MSK) != 0U) ? true : false);
                    }
                    if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                    {
                        sdmem4B = ((dObj->cardCtxt.scrBuffer[1] & 0x04U) != 0U) ? true : false;
                    }

                    if ((dObj->sdCardType & CARD_TYPE_SDIO_COMBO) == CARD_TYPE_SDIO_COMBO)
                    {
                        dObj->cardCtxt.busWidth = (sdio4B == true && sdmem4B == true)? DRV_SDMMC_BUS_WIDTH_4_BIT: DRV_SDMMC_BUS_WIDTH_1_BIT;
                    }
                    else if (dObj->sdCardType & CARD_TYPE_SD_IO)
                    {
                        dObj->cardCtxt.busWidth = sdio4B == true? DRV_SDMMC_BUS_WIDTH_4_BIT: DRV_SDMMC_BUS_WIDTH_1_BIT;
                    }
                    else if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                    {
                        dObj->cardCtxt.busWidth = sdmem4B == true? DRV_SDMMC_BUS_WIDTH_4_BIT: DRV_SDMMC_BUS_WIDTH_1_BIT;
                    }
                }
            }
            else
            {
                dObj->cardCtxt.busWidth = DRV_SDMMC_BUS_WIDTH_1_BIT;
            }

            if (dObj->cardCtxt.busWidth == DRV_SDMMC_BUS_WIDTH_4_BIT)
            {
                dObj->initState = (dObj->sdCardType & CARD_TYPE_SD_IO) ? DRV_SDMMC_INIT_SET_BUS_WIDTH_SDIO : DRV_SDMMC_INIT_SET_BUS_WIDTH_SDMEM;
            }
            else
            {
                dObj->initState = DRV_SDMMC_INIT_SET_BUS_WIDTH_HOST;
            }
            break;
        case DRV_SDMMC_INIT_SET_BUS_WIDTH_SDIO:

            //Set 4-bit bus mode for SDIO

            status = DRV_SDMMC_SDIO_Enable4BitBusWidth(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_BUS_WIDTH_SDMEM;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_BUS_WIDTH_HOST;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_CHK_HS_SPEED_SUP_SDIO:

            /* Check if HS mode is supported by SDIO*/
            status = lDRV_SDMMC_SDIO_IO_ReadDirect(dObj, DRV_SDMMC_FN0, DRV_SDMMC_CCCR_ADDR_BUS_SPD_SEL, &readData, NULL);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if ((readData & DRV_SDMMC_CCCR_SHS_MSK) != 0U)
                {
                    /* HS (50 MHz) supported */
                    if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                    {
                        if ((dObj->cardCtxt.scrBuffer[0] & 0x0FU) != 0U)
                        {
                            /* Card follows SD Spec version 1.10 or higher */
                            dObj->cardCtxt.cmd6Mode = 0;
                            dObj->initState = DRV_SDMMC_INIT_CHK_HS_SPEED_SUP_SDMEM;
                        }
                        else
                        {
                            dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                        }
                    }
                    else
                    {
                        dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_SDIO;
                    }
                }
                else
                {
                    /* HS not supported, check if block mode is supported */
                    dObj->initState = DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_SET_HS_SPEED_SDIO:

            status = lDRV_SDMMC_SDIO_EnableHSMode(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_SDMEM;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_HOST;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO:
            if (dObj->cardCtxt.sdioCardCapability & DRV_SDMMC_CCCR_SMB_MSK)
            {
                /* Multi-block transfer (CMD53) is supported */
                uint32_t blockSize = 0;
                status = lDRV_SDMMC_SDIO_ReadBlkSize(dObj, dObj->cardCtxt.currentFn, &blockSize);

                if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    if (blockSize >= 512)
                    {
                        dObj->cardCtxt.blockSize = 512;
                        dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDIO;
                    }
                }
                else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            else
            {
                dObj->initState = DRV_SDMMC_INIT_FN_EN_SDIO;
            }
            break;

        case DRV_SDMMC_INIT_SET_BLK_LEN_SDIO:

            status = lDRV_SDMMC_SDIO_SetBlkSize(dObj, dObj->cardCtxt.currentFn, dObj->cardCtxt.blockSize);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->cardCtxt.currentFn < dObj->cardCtxt.nf)
                {
                    dObj->cardCtxt.currentFn++;
                    dObj->initState = DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_FN_EN_SDIO;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->cardCtxt.blockSize = 0;
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_FN_EN_SDIO:
            status = lDRV_SDMMC_SDIO_IOEnable(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if (dObj->sdCardType & CARD_TYPE_SD_MEM)
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_DESELECT_CARD;
                }
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_READ_EXT_CSD:
            status = lDRV_SDMMC_ExtendedCSDRead(dObj);

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_SET_BUS_WIDTH_SDMEM;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_SET_BUS_WIDTH_SDMEM:
            if(dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
            {
                status = lDRV_SDMMC_SetBusWidth_ACMD6(dObj);
            }
            else
            {
                status = lDRV_SDMMC_SetBusWidth_CMD6(dObj);
            }

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                if(dObj->protocol == DRV_SDMMC_PROTOCOL_EMMC)
                {
                    dObj->cardCtxt.busWidth = dObj->busWidth;
                }
                dObj->initState = DRV_SDMMC_INIT_SET_BUS_WIDTH_HOST;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            break;

        case DRV_SDMMC_INIT_SET_BUS_WIDTH_HOST:

            /* Configure the host controller to use 4-bit bus from now on. */
            dObj->sdmmcPlib->sdhostSetBusWidth (dObj->cardCtxt.busWidth);

            if (dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
            {
                if (dObj->sdCardType & CARD_TYPE_SD_IO)
                {
                    if ((dObj->cardCtxt.sdioCardCapability & DRV_SDMMC_CCCR_LSC_MSK) == 0U)
                    {
                        dObj->cardCtxt.defaultSpeed = DRV_SDMMC_CLOCK_FREQ_DS_25_MHZ;
                        dObj->initState = DRV_SDMMC_INIT_SET_DEFAULT_SPEED_HOST;
                    }
                    else
                    {
                        dObj->cardCtxt.defaultSpeed = DRV_SDMMC_CLOCK_FREQ_400_KHZ;
                        dObj->initState = DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO;
                    }
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_SET_DEFAULT_SPEED_HOST;
                }
            }
            else
            {
                dObj->initState = DRV_SDMMC_INIT_SET_DEFAULT_SPEED_HOST;
            }

            break;

        case DRV_SDMMC_INIT_SET_DEFAULT_SPEED_HOST:

            <#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
            lDRV_SDMMC_SetClock (dObj, dObj->cardCtxt.defaultSpeed);
            if (dObj->clockState == DRV_SDMMC_CLOCK_SET_COMPLETE)
            <#else>
            if (dObj->sdmmcPlib->sdhostSetClock(dObj->cardCtxt.defaultSpeed) == true)
            </#if>
            {
                dObj->cardCtxt.currentSpeed = dObj->cardCtxt.defaultSpeed;

                if (dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
                {
                    if (dObj->speedMode == DRV_SDMMC_SPEED_MODE_HIGH)
                    {
                        if (dObj->sdCardType & CARD_TYPE_SD_IO)
                        {
                            dObj->initState = DRV_SDMMC_INIT_CHK_HS_SPEED_SUP_SDIO;
                        }
                        else
                        {
                            if ((dObj->cardCtxt.scrBuffer[0] & 0x0FU) != 0U)
                            {
                                /* Card follows SD Spec version 1.10 or higher */
                                dObj->cardCtxt.cmd6Mode = 0;
                                dObj->initState = DRV_SDMMC_INIT_CHK_HS_SPEED_SUP_SDMEM;
                            }
                            else
                            {
                                dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                            }
                        }
                    }
                    else
                    {
                        dObj->initState = (dObj->sdCardType & CARD_TYPE_SD_IO)? DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO : DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                    }
                }
                else
                {
                    if (dObj->speedMode == DRV_SDMMC_SPEED_MODE_HIGH)
                    {
                        if (DRV_SDMMC_EXT_CSD_GET_HS_SUPPORT(dObj->cardCtxt.extCSDBuffer) == true)
                        {
                            dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_SDMEM;
                        }
                        else
                        {
                            dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                        }
                    }
                    else
                    {
                        dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                    }
                }
            }
            <#if !core.PRODUCT_FAMILY?contains("PIC32MZ")>
            else
            {
                dObj->initState = DRV_SDMMC_INIT_ERROR;
            }
            </#if>
            break;

        case DRV_SDMMC_INIT_CHK_HS_SPEED_SUP_SDMEM:
            {
                bool isSupported;

                status = lDRV_SDMMC_CheckSwitchHS_CMD6(dObj, 0, &isSupported);

                if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    if (isSupported)
                    {
                        if (dObj->sdCardType & CARD_TYPE_SD_IO)
                        {
                            dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_SDIO;
                        }
                        else
                        {
                            dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_SDMEM;
                        }
                    }
                    else
                    {
                        if (dObj->sdCardType & CARD_TYPE_SD_IO)
                        {
                            /* HS not supported, check if block mode is supported */
                            dObj->initState = DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO;
                        }
                        else
                        {
                            dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                        }
                    }
                }
                else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            break;

        case DRV_SDMMC_INIT_SET_HS_SPEED_SDMEM:
            if (dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
            {
                status = lDRV_SDMMC_CheckSwitchHS_CMD6(dObj, 1, NULL);
            }
            else
            {
                status = lDRV_SDMMC_EMMC_SwitchHS_CMD6(dObj);
            }

            if (status == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
            {
                dObj->initState = DRV_SDMMC_INIT_SET_HS_SPEED_HOST;
            }
            else if (status == DRV_SDMMC_COMMAND_STATUS_ERROR)
            {
                dObj->initState = DRV_SDMMC_INIT_DONE;
            }

            break;

        case DRV_SDMMC_INIT_SET_HS_SPEED_HOST:
            {
                uint32_t hs_speed;

                if (dObj->protocol == DRV_SDMMC_PROTOCOL_SD)
                {
                    hs_speed = DRV_SDMMC_CLOCK_FREQ_HS_50_MHZ;
                }
                else
                {
                    hs_speed = DRV_SDMMC_CLOCK_FREQ_HS_52_MHZ;
                }
            <#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
                lDRV_SDMMC_SetClock (dObj, hs_speed);
                if (dObj->clockState == DRV_SDMMC_CLOCK_SET_COMPLETE)
            <#else>
                if (dObj->sdmmcPlib->sdhostSetClock(hs_speed) == true)
            </#if>
                {
                    dObj->cardCtxt.currentSpeed = hs_speed;
                    dObj->sdmmcPlib->sdhostSetSpeedMode (DRV_SDMMC_SPEED_MODE_HIGH);
                    if (dObj->sdCardType & CARD_TYPE_SD_IO)
                    {
                        dObj->initState = DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO;
                    }
                    else
                    {
                        dObj->initState = DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM;
                    }
                }
            <#if !core.PRODUCT_FAMILY?contains("PIC32MZ")>
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            </#if>
            }
            break;

        case DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SET_BLOCKLEN, 512, (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->initState = DRV_SDMMC_INIT_DESELECT_CARD;
                }
                else
                {
                    dObj->initState = DRV_SDMMC_INIT_ERROR;
                }
            }
            break;

        case DRV_SDMMC_INIT_DESELECT_CARD:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SELECT_DESELECT_CARD, 0, (uint8_t)DRV_SDMMC_CMD_RESP_NONE, &dObj->dataTransferFlags);

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                dObj->initState = DRV_SDMMC_INIT_DONE;
            }
            break;

        case DRV_SDMMC_INIT_DONE:
        case DRV_SDMMC_INIT_ERROR:

            (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);

            dObj->cardCtxt.currentFn = 0;
            dObj->initState = DRV_SDMMC_INIT_SET_INIT_SPEED;
            break;

        default:

            dObj->initState = DRV_SDMMC_INIT_SET_INIT_SPEED;
            break;
    }
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 14.3"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */
// *****************************************************************************
// *****************************************************************************
// Section: Driver Interface Function Definitions
// *****************************************************************************
// *****************************************************************************

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block deviate:2 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1"
</#if>
/* MISRA C-2012 Rule 11.8 deviated:2 Deviation record ID -  H3_MISRAC_2012_R_11_8_DR_1 */

SYS_MODULE_OBJ DRV_SDMMC_Initialize (
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT* const init
)
{
    DRV_SDMMC_OBJ* dObj = NULL;
    const DRV_SDMMC_INIT* const sdmmcInit = (DRV_SDMMC_INIT *)init;

    /* Validate the driver index */
    if ((drvIndex >= DRV_SDMMC_INSTANCES_NUMBER) || (sdmmcInit == NULL))
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Is the driver instance already initialized? */
    if(gDrvSDMMCObj[drvIndex].inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj = &gDrvSDMMCObj[drvIndex];

    /* Initialize the driver object's structure members */
    (void) memset (dObj, 0, sizeof(DRV_SDMMC_OBJ));

    if(OSAL_MUTEX_Create(&dObj->mutex) != OSAL_RESULT_SUCCESS)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    if(OSAL_MUTEX_Create(&dObj->mutexClientObjects) != OSAL_RESULT_SUCCESS)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj->inUse                 = true;

    /* Attach to the peripheral SDMMC PLIB driver */
    dObj->sdmmcPlib                         = sdmmcInit->sdmmcPlib;
    dObj->bufferObjPool                     = sdmmcInit->bufferObjPool;
    dObj->bufferObjPoolSize                 = sdmmcInit->bufferObjPoolSize;
    dObj->clientObjPool                     = sdmmcInit->clientObjPool;
    dObj->nClientsMax                       = sdmmcInit->numClients;
    dObj->protocol                          = sdmmcInit->protocol;
    dObj->speedMode                         = sdmmcInit->speedMode;
    dObj->busWidth                          = sdmmcInit->busWidth;
    dObj->cardDetectionMethod               = sdmmcInit->cardDetectionMethod;
    dObj->cardDetectionPollingIntervalMs    = sdmmcInit->cardDetectionPollingIntervalMs;
    dObj->isWriteProtectCheckEnabled        = sdmmcInit->isWriteProtectCheckEnabled;
    dObj->sdmmcTokenCount                   = 1;
    dObj->initState                         = DRV_SDMMC_INIT_SET_INIT_SPEED;
    dObj->taskState                         = DRV_SDMMC_TASK_WAIT_FOR_DEVICE_ATTACH;
    dObj->cmdState                          = DRV_SDMMC_CMD_EXEC_IS_COMPLETE;
    dObj->mediaState                        = SYS_MEDIA_DETACHED;
    dObj->clockState                        = DRV_SDMMC_CLOCK_SET_DIVIDER;
    dObj->bufferObjList                     = 0U;
    dObj->isExclusive                       = false;
    dObj->isCmdTimerExpired                 = false;
    dObj->sleepWhenIdle                     = sdmmcInit->sleepWhenIdle;

    /* Register a callback with the underlying SDMMC PLIB */
    dObj->sdmmcPlib->sdhostCallbackRegister(lDRV_SDMMC_PlibCallbackHandler, (uintptr_t)dObj);

<#if drv_sdmmc.DRV_SDMMC_COMMON_FS_ENABLE == true>
    if (sdmmcInit->isFsEnabled == true)
    {
        DRV_SDMMC_RegisterWithSysFs(drvIndex);
    }
</#if>

    lDRV_SDMMC_InitCardContext((uint32_t)drvIndex, &dObj->cardCtxt);
    dObj->cardCtxt.currentSpeed = DRV_SDMMC_CLOCK_FREQ_400_KHZ;

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ((SYS_MODULE_OBJ)drvIndex);
}

SYS_STATUS DRV_SDMMC_Status (
    SYS_MODULE_OBJ object
)
{
    /* Validate the request */
    if( (object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_SDMMC_INSTANCES_NUMBER) )
    {
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvSDMMCObj[object].status);
}

DRV_HANDLE DRV_SDMMC_Open (
    const SYS_MODULE_INDEX drvIndex,
    const DRV_IO_INTENT ioIntent
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;
    uint8_t iClient;

    /* Validate the driver index */
    if (drvIndex >= DRV_SDMMC_INSTANCES_NUMBER)
    {
        return DRV_HANDLE_INVALID;
    }

    dObj = &gDrvSDMMCObj[drvIndex];

    /* Guard against multiple threads trying to open the driver */
    if (OSAL_MUTEX_Lock(&dObj->mutexClientObjects , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FAIL)
    {
        return DRV_HANDLE_INVALID;
    }

    if ((dObj->status != SYS_STATUS_READY) || (dObj->inUse == false))
    {
        (void) OSAL_MUTEX_Unlock(&dObj->mutexClientObjects);
        return DRV_HANDLE_INVALID;
    }
    /* Flag error if:
     * Driver is already opened by maximum configured clients
     * Driver is already opened with exclusive access
     * Exclusive access is requested while the driver is already opened by other client*/

    if ((dObj->nClients == dObj->nClientsMax) ||
        (dObj->isExclusive == true) ||
        ((dObj->nClients > 0U) && (((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_EXCLUSIVE) != 0U))
    )
    {
        (void) OSAL_MUTEX_Unlock(&(dObj->mutexClientObjects));
        return DRV_HANDLE_INVALID;
    }

    for(iClient = 0; iClient != dObj->nClientsMax; iClient++)
    {
        clientObj = &((DRV_SDMMC_CLIENT_OBJ *)dObj->clientObjPool)[iClient];

        if(clientObj->inUse == false)
        {
            /* This means we have a free client object to use */
            clientObj->inUse = true;
            clientObj->intent = ioIntent;

            if(((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_EXCLUSIVE) != 0U)
            {
                /* Set the driver exclusive flag */
                dObj->isExclusive = true;
            }

            dObj->nClients++;

            /* Generate the client handle */
            clientObj->clientHandle = (DRV_HANDLE)lDRV_SDMMC_MAKE_HANDLE(dObj->sdmmcTokenCount, (uint8_t)drvIndex, iClient);

            /* Increment the instance specific token counter */
            dObj->sdmmcTokenCount = lDRV_SDMMC_UPDATE_TOKEN(dObj->sdmmcTokenCount);

            /* We have found a client object, now release the mutex */
            (void) OSAL_MUTEX_Unlock(&(dObj->mutexClientObjects));

            clientObj->eventHandler  = NULL;
            clientObj->context       = 0U;
            clientObj->drvIndex      = drvIndex;

            return clientObj->clientHandle;
        }
    }

    (void) OSAL_MUTEX_Unlock(&(dObj->mutexClientObjects));

    return DRV_HANDLE_INVALID;
}

void DRV_SDMMC_Close (
    DRV_HANDLE handle
)
{
    DRV_SDMMC_OBJ* dObj = NULL;
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;

    clientObj = lDRV_SDMMC_DriverHandleValidate(handle);
    if (clientObj == NULL)
    {
        return;
    }

    dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

    /* Guard against multiple threads trying to open/close the driver */
    if (OSAL_MUTEX_Lock(&dObj->mutexClientObjects , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FAIL)
    {
        return;
    }

    lDRV_SDMMC_RemoveClientBuffersFromList (dObj, clientObj);

    /* Reduce the number of clients */
    dObj->nClients --;

    /* Reset the exclusive flag */
    dObj->isExclusive = false;

    /* Free the client object */
    clientObj->inUse = false;

    (void) OSAL_MUTEX_Unlock(&dObj->mutexClientObjects);

}

static void DRV_SDMMC_SetupXfer(
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    void* buffer,
    uint32_t blockStart,
    uint32_t nBlocks,
    uint8_t fn,
    bool isAddrInc,
    DRV_SDMMC_OPERATION_TYPE opType
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_BUFFER_OBJ* bufferObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;

    if (commandHandle != NULL)
    {
        *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
    }
    if ((buffer == NULL) || (nBlocks == 0U))
    {
        return;
    }

    clientObj = lDRV_SDMMC_DriverHandleValidate(handle);

    if (clientObj == NULL)
    {
        return;
    }

    dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

    if (dObj->mediaState != SYS_MEDIA_ATTACHED)
    {
        return;
    }

    if (opType == DRV_SDMMC_OPERATION_TYPE_SD_MEM_READ)
    {
        if (((uint32_t)clientObj->intent & (uint32_t)DRV_IO_INTENT_READ) == 0U)
        {
            return;
        }
        if ((((uint64_t)blockStart + nBlocks) > dObj->mediaGeometryTable[GEOMETRY_TABLE_READ_ENTRY].numBlocks))
        {
            return;
        }
    }
    else if (opType == DRV_SDMMC_OPERATION_TYPE_SD_MEM_WRITE)
    {
        if (((uint32_t)clientObj->intent & (uint32_t)DRV_IO_INTENT_WRITE) == 0U)
        {
            return;
        }
        if ((((uint64_t)blockStart + nBlocks) > dObj->mediaGeometryTable[GEOMETRY_TABLE_WRITE_ENTRY].numBlocks))
        {
            return;
        }
    }

    if (OSAL_MUTEX_Lock(&dObj->mutex, OSAL_WAIT_FOREVER) != OSAL_RESULT_SUCCESS)
    {
        return;
    }

    bufferObj = lDRV_SDMMC_FreeBufferObjectGet(clientObj);

    if (bufferObj != NULL)
    {
        bufferObj->clientHandle  = handle;
        bufferObj->buffer        = buffer;
        bufferObj->blockStart    = blockStart;
        bufferObj->nBlocks       = nBlocks;
        bufferObj->opType        = opType;
        bufferObj->status        = DRV_SDMMC_COMMAND_QUEUED;
        bufferObj->fn            = fn;
        bufferObj->isAddrInc     = isAddrInc;

        if (commandHandle != NULL)
        {
            *commandHandle = bufferObj->commandHandle;
        }
        /* Add the buffer object to the linked list */
        (void) lDRV_SDMMC_BufferObjectAddToList (dObj, bufferObj);
    }

    (void) OSAL_MUTEX_Unlock(&dObj->mutex);
}

void DRV_SDMMC_AsyncRead (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlocks
)
{
    DRV_SDMMC_SetupXfer(
        handle,
        commandHandle,
        targetBuffer,
        blockStart,
        nBlocks,
        0,
        false,
        DRV_SDMMC_OPERATION_TYPE_SD_MEM_READ
    );
}

void DRV_SDMMC_AsyncWrite
(
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlocks
)
{
    DRV_SDMMC_SetupXfer(
        handle,
        commandHandle,
        sourceBuffer,
        blockStart,
        nBlocks,
        0,
        false,
        DRV_SDMMC_OPERATION_TYPE_SD_MEM_WRITE
    );
}

void DRV_SDMMC_Async_SDIO_ExtBlockWrite (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    void* wrData,
    uint32_t nBlocks,
    bool isAddrInc
)
{
    if ((nBlocks == 0) || (nBlocks > 511))
    {
        if (commandHandle != NULL)
        {
            *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
        }
    }
    else
    {
        DRV_SDMMC_SetupXfer(
            handle,
            commandHandle,
            wrData,
            regAddr,
            nBlocks,
            fn,
            isAddrInc,
            DRV_SDMMC_OPERATION_TYPE_SDIO_WR_BLK
        );
    }
}

void DRV_SDMMC_Async_SDIO_ExtBlockRead (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    void* rdData,
    uint32_t nBlocks,
    bool isAddrInc
)
{
    if ((nBlocks == 0) || (nBlocks > 511))
    {
        if (commandHandle != NULL)
        {
            *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
        }
    }
    else
    {
        DRV_SDMMC_SetupXfer(
            handle,
            commandHandle,
            rdData,
            regAddr,
            nBlocks,
            fn,
            isAddrInc,
            DRV_SDMMC_OPERATION_TYPE_SDIO_RD_BLK
        );
    }
}

void DRV_SDMMC_Async_SDIO_ExtBytesWrite (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    void* wrData,
    uint32_t nBytes,
    bool isAddrInc
)
{
    if ((nBytes == 0) || (nBytes > 511))
    {
        if (commandHandle != NULL)
        {
            *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
        }
    }
    else
    {
        DRV_SDMMC_SetupXfer(
            handle,
            commandHandle,
            wrData,
            regAddr,
            nBytes,
            fn,
            isAddrInc,
            DRV_SDMMC_OPERATION_TYPE_SDIO_WR_BYTES
        );
    }
}

void DRV_SDMMC_Async_SDIO_ExtBytesRead (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    void* rdData,
    uint32_t nBytes,
    bool isAddrInc
)
{
    if ((nBytes == 0) || (nBytes > 511))
    {
        if (commandHandle != NULL)
        {
            *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
        }
    }
    else
    {
        DRV_SDMMC_SetupXfer(
            handle,
            commandHandle,
            rdData,
            regAddr,
            nBytes,
            fn,
            isAddrInc,
            DRV_SDMMC_OPERATION_TYPE_SDIO_RD_BYTES
        );
    }
}

void DRV_SDMMC_Async_SDIO_DirByteWrite (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    uint8_t* wrData,
    bool raw
)
{
    DRV_SDMMC_SetupXfer(
        handle,
        commandHandle,
        wrData,
        regAddr,
        1,
        fn,
        raw,
        DRV_SDMMC_OPERATION_TYPE_SDIO_WR_DIR
    );
}

void DRV_SDMMC_Async_SDIO_DirByteRead (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    uint8_t* rdData
)
{
    DRV_SDMMC_SetupXfer(
        handle,
        commandHandle,
        rdData,
        regAddr,
        1,
        fn,
        false,
        DRV_SDMMC_OPERATION_TYPE_SDIO_RD_DIR
    );
}

void DRV_SDMMC_Async_SDIO_Read (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    void* rdData,
    uint32_t nBytes,
    bool isAddrInc
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;
    DRV_SDMMC_OPERATION_TYPE opType;
    uint32_t blockSize;
    bool err = false;

    clientObj = lDRV_SDMMC_DriverHandleValidate(handle);

    if (clientObj == NULL)
    {
        return;
    }

    dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

    blockSize = dObj->cardCtxt.blockSize;

    if (nBytes == 0)
    {
        err = true;
    }
    else if (nBytes == 1)
    {
        opType = DRV_SDMMC_OPERATION_TYPE_SDIO_RD_DIR;
    }
    else
    {
        if (nBytes > 511)
        {
            if ((nBytes % blockSize) != 0U)
            {
                /* Driver only supports block transfers which are multiple of 512 bytes */
                err = true;
            }
            else
            {
                nBytes = nBytes/blockSize;
                opType = DRV_SDMMC_OPERATION_TYPE_SDIO_RD_BLK;
            }
        }
        else
        {
            opType = DRV_SDMMC_OPERATION_TYPE_SDIO_RD_BYTES;
        }
    }
    
    if (err == true)
    {
        if (commandHandle != NULL)
        {
            *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
        }
    }
    else
    {
        DRV_SDMMC_SetupXfer(
            handle,
            commandHandle,
            rdData,
            regAddr,
            nBytes,
            fn,
            isAddrInc,
            opType
        );
    }
}

void DRV_SDMMC_Async_SDIO_Write (
    const DRV_HANDLE handle,
    DRV_SDMMC_COMMAND_HANDLE* commandHandle,
    uint8_t fn,
    uint32_t regAddr,
    void* wrData,
    uint32_t nBytes,
    bool isAddrInc
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;
    DRV_SDMMC_OPERATION_TYPE opType;
    uint32_t blockSize;
    bool err = false;


    clientObj = lDRV_SDMMC_DriverHandleValidate(handle);

    if (clientObj == NULL)
    {
        return;
    }

    dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

    blockSize = dObj->cardCtxt.blockSize;

    if (nBytes == 0)
    {
        err = true;
    }
    else if (nBytes == 1)
    {
        opType = DRV_SDMMC_OPERATION_TYPE_SDIO_WR_DIR;
    }
    else
    {
        if (nBytes > 511)
        {
            if ((nBytes % blockSize) != 0U)
            {
                /* Driver only supports block transfers which are multiple of 512 bytes */
                err = true;
            }
            else
            {
                nBytes = nBytes/blockSize;
                opType = DRV_SDMMC_OPERATION_TYPE_SDIO_WR_BLK;
            }
        }
        else
        {
            opType = DRV_SDMMC_OPERATION_TYPE_SDIO_WR_BYTES;
        }
    }
    if (err == true)
    {
        if (commandHandle != NULL)
        {
            *commandHandle = DRV_SDMMC_COMMAND_HANDLE_INVALID;
        }
    }
    else
    {
        DRV_SDMMC_SetupXfer(
            handle,
            commandHandle,
            wrData,
            regAddr,
            nBytes,
            fn,
            isAddrInc,
            opType
        );
    }
}


DRV_SDMMC_COMMAND_STATUS DRV_SDMMC_CommandStatus (
    const DRV_HANDLE handle,
    const DRV_SDMMC_COMMAND_HANDLE commandHandle
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj;
    DRV_SDMMC_BUFFER_OBJ* bufferPool;
    DRV_SDMMC_OBJ* dObj;
    uint32_t bufferIndex;

    clientObj = lDRV_SDMMC_DriverHandleValidate (handle);

    if ((clientObj == NULL) || (commandHandle == DRV_SDMMC_COMMAND_HANDLE_INVALID))
    {
        return DRV_SDMMC_COMMAND_ERROR_UNKNOWN;
    }

    dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

    bufferPool = (DRV_SDMMC_BUFFER_OBJ*)dObj->bufferObjPool;
    bufferIndex = commandHandle & DRV_SDMMC_INDEX_MASK;

    if (bufferIndex >= dObj->bufferObjPoolSize)
    {
        return DRV_SDMMC_COMMAND_ERROR_UNKNOWN;
    }

    /* Check if the buffer object is still valid */
    if (bufferPool[bufferIndex].commandHandle == commandHandle)
    {
        /* Return the last known buffer object status */
        return bufferPool[bufferIndex].status;
    }
    else
    {
        /* This means that object has been re-used by another request. Indicate
         * that the operation is completed.  */
        return (DRV_SDMMC_COMMAND_COMPLETED);
    }
}

SYS_MEDIA_GEOMETRY* DRV_SDMMC_GeometryGet (
    const DRV_HANDLE handle
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;
    SYS_MEDIA_GEOMETRY* mediaGeometryObj = NULL;

    clientObj = lDRV_SDMMC_DriverHandleValidate (handle);

    if (clientObj != NULL)
    {
        dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];
        mediaGeometryObj = &dObj->mediaGeometryObj;
    }

    return mediaGeometryObj;
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block deviate:1 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1"
</#if>
/* MISRA C-2012 Rule 11.1 deviated:1 Deviation record ID -  H3_MISRAC_2012_R_11_1_DR_1 */

void DRV_SDMMC_EventHandlerSet (
    const DRV_HANDLE handle,
    const void* eventHandler,
    const uintptr_t context
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;

    clientObj = lDRV_SDMMC_DriverHandleValidate (handle);

    if (clientObj != NULL)
    {
        dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

        if (OSAL_MUTEX_Lock(&dObj->mutex, OSAL_WAIT_FOREVER) == OSAL_RESULT_SUCCESS)
        {
            /* Set the event handler */
            clientObj->eventHandler = (DRV_SDMMC_EVENT_HANDLER)eventHandler;
            clientObj->context = context;
            (void) OSAL_MUTEX_Unlock(&dObj->mutex);
        }
    }
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
</#if>
/* MISRAC 2012 deviation block end */

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
</#if>
/* MISRAC 2012 deviation block end */

bool DRV_SDMMC_IsAttached (
    const DRV_HANDLE handle
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;
    bool isAttached = false;

    clientObj = lDRV_SDMMC_DriverHandleValidate (handle);

    if (clientObj != NULL)
    {
        dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];

        if (dObj->mediaState == SYS_MEDIA_ATTACHED)
        {
            isAttached = true;
        }
    }

    return isAttached;
}

bool DRV_SDMMC_IsWriteProtected (
    const DRV_HANDLE handle
)
{
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_OBJ* dObj = NULL;
    bool isWriteProtected = false;

    clientObj = lDRV_SDMMC_DriverHandleValidate (handle);
    if (clientObj != NULL)
    {
        dObj = (DRV_SDMMC_OBJ* )&gDrvSDMMCObj[clientObj->drvIndex];
        if (dObj->mediaState == SYS_MEDIA_ATTACHED)
        {
            isWriteProtected = dObj->cardCtxt.isWriteProtected;
        }
    }

    return isWriteProtected;
}

void DRV_SDMMC_Tasks( SYS_MODULE_OBJ object )
{
    DRV_SDMMC_OBJ* dObj = NULL;
    DRV_SDMMC_CLIENT_OBJ* clientObj = NULL;
    DRV_SDMMC_BUFFER_OBJ* currentBufObj = NULL;
    DRV_SDMMC_EVENT evtStatus = DRV_SDMMC_EVENT_COMMAND_COMPLETE;
    uint32_t response = 0;
    static bool cardAttached = true;

    dObj = &gDrvSDMMCObj[object];

    if (OSAL_MUTEX_Lock(&dObj->mutex, OSAL_WAIT_FOREVER) != OSAL_RESULT_SUCCESS)
    {
        SYS_ASSERT(false, "SDMMC Driver: OSAL_MUTEX_Lock failed");
    }

    currentBufObj = lDRV_SDMMC_BufferListGet(dObj);

    switch (dObj->taskState)
    {
        case DRV_SDMMC_TASK_WAIT_FOR_DEVICE_ATTACH:
            /* Using SD protocol and host controller supports card detect line */
            if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_USE_SDCD)
            {
                /* Check the Present state register to see if the card is inserted */
                if (dObj->sdmmcPlib->sdhostIsCardAttached ())
                {
                    /* Start the debounce timer */
                    dObj->taskState = DRV_SDMMC_TASK_START_CD_LINE_DEBOUNCE_TIMER;
                }

            }
            /* Either eMMC protocol or host does not support card detection */
            else
            {
                lDRV_SDMMC_InitCardContext((uint32_t)object, &dObj->cardCtxt);
                dObj->sdmmcPlib->sdhostInitModule();
                dObj->cardCtxt.currentSpeed = DRV_SDMMC_CLOCK_FREQ_400_KHZ;

                /* Attempt media initialization assuming that the media is present */
                dObj->taskState = DRV_SDMMC_TASK_MEDIA_INIT;
            }
            break;

        case DRV_SDMMC_TASK_START_CD_LINE_DEBOUNCE_TIMER:
            if (SYS_TIME_DelayMS(250, &(dObj->tmrHandle)) == SYS_TIME_SUCCESS)
            {
                dObj->taskState = DRV_SDMMC_TASK_WAIT_CD_LINE_DEBOUNCE_TIMEOUT;
            }
            else
            {
                // Keep trying until a valid timer handle is obtained
            }
            break;

        case DRV_SDMMC_TASK_WAIT_CD_LINE_DEBOUNCE_TIMEOUT:
            if (SYS_TIME_DelayIsComplete(dObj->tmrHandle) == true)
            {
                if (dObj->sdmmcPlib->sdhostIsCardAttached ())
                {
                    lDRV_SDMMC_InitCardContext((uint32_t)object, &dObj->cardCtxt);
                    dObj->sdmmcPlib->sdhostInitModule();
                    dObj->cardCtxt.currentSpeed = DRV_SDMMC_CLOCK_FREQ_400_KHZ;

                    /* Debounce delay has elapsed. Kick start initialization. */
                    dObj->taskState = DRV_SDMMC_TASK_MEDIA_INIT;
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_WAIT_FOR_DEVICE_ATTACH;
                }
            }
            break;

        case DRV_SDMMC_TASK_MEDIA_INIT:

            lDRV_SDMMC_MediaInitialize (dObj);
            if (dObj->initState == DRV_SDMMC_INIT_DONE)
            {
                /* Initial state (card in wakeup mode) after media initialization */
                dObj->emmcSleepWakeState = DRV_SDMMC_EMMC_STATE_WAKE;

                /* Check and update the card's write protected status */
                if (dObj->isWriteProtectCheckEnabled == true)
                {
                    if (dObj->sdmmcPlib->sdhostIsWriteProtected != NULL)
                    {
                        dObj->cardCtxt.isWriteProtected = dObj->sdmmcPlib->sdhostIsWriteProtected();
                    }
                    else
                    {
                        /* For HSMCI - Read from the configured GPIO pin */
                    }
                }
                else
                {
                    dObj->cardCtxt.isWriteProtected = false;
                }

                /* Update the Media Geometry structure */
                lDRV_SDMMC_UpdateGeometry (dObj);

                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    dObj->generalTimerHandle = SYS_TIME_HANDLE_INVALID;
                }

                dObj->mediaState = SYS_MEDIA_ATTACHED;
                dObj->taskState = DRV_SDMMC_TASK_PROCESS_QUEUE;
            }
            else if (dObj->initState == DRV_SDMMC_INIT_ERROR)
            {
                <#if DRV_SDMMC_PLIB == "HSMCI">
                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    /* Polling method available on SDHC and HSMCI PLIBs */
                    lDRV_SDMMC_InitCardContext((uint32_t)object, &dObj->cardCtxt);
                }
                <#else>
                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    /* Polling method available on SDHC and HSMCI PLIBs */
                    lDRV_SDMMC_InitCardContext((uint32_t)object, &dObj->cardCtxt);
                }
                else if(dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_USE_SDCD)
                {
                    /* SDCD# pin is available only on SDHC PLIB */
                    if (dObj->sdmmcPlib->sdhostIsCardAttached() == false)
                    {
                        dObj->taskState = DRV_SDMMC_TASK_WAIT_FOR_DEVICE_ATTACH;
                    }
                    else
                    {
                        lDRV_SDMMC_InitCardContext((uint32_t)object, &dObj->cardCtxt);
                    }
                }
                else
                {
                   /* Nothing to do */
                }
                </#if>
            }
            else
            {
                /* Nothing to do */
            }
            break;

        case DRV_SDMMC_TASK_PROCESS_QUEUE:

            currentBufObj = lDRV_SDMMC_BufferListGet(dObj);
            if ((currentBufObj != NULL) && (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE))
            {
                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    (void) SYS_TIME_TimerDestroy(dObj->generalTimerHandle);
                    dObj->generalTimerHandle = SYS_TIME_HANDLE_INVALID;
                }

                if (dObj->cardCtxt.isLocked == true)
                {
                    /* Card is locked. Fail the transaction. */
                    currentBufObj->status = DRV_SDMMC_COMMAND_ERROR_UNKNOWN;
                    dObj->taskState = DRV_SDMMC_TASK_ERROR;
                    break;
                }

                if((dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_USE_SDCD) &&
                   (dObj->sdmmcPlib->sdhostIsCardAttached () == false))
                {
                    /* Card has been removed. */
                    dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                    break;
                }

                currentBufObj->status = DRV_SDMMC_COMMAND_IN_PROGRESS;

                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_NONE)
                {
                    /* For eMMC card, first wakeup and then select the card */
                    if ((dObj->protocol == DRV_SDMMC_PROTOCOL_EMMC) && (dObj->emmcSleepWakeState == DRV_SDMMC_EMMC_STATE_SLEEP))
                    {
                        /* Wake up the eMMC card */
                        dObj->emmcSleepWakeState = DRV_SDMMC_EMMC_STATE_WAKE;
                        dObj->taskState = DRV_SDMMC_TASK_SLEEP_WAKE_CARD;
                    }
                    else
                    {
                        dObj->taskState = DRV_SDMMC_TASK_SELECT_CARD;
                    }
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_SELECT_CARD;
                }
            }
            else
            {
            <#if DRV_SDMMC_PLIB == "HSMCI">
                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_NONE)
                {
                    if ((dObj->protocol == DRV_SDMMC_PROTOCOL_EMMC) && (dObj->sleepWhenIdle == true))
                    {
                        if (dObj->emmcSleepWakeState == DRV_SDMMC_EMMC_STATE_WAKE)
                        {
                            dObj->emmcSleepWakeState = DRV_SDMMC_EMMC_STATE_SLEEP;
                            dObj->taskState = DRV_SDMMC_TASK_SLEEP_WAKE_CARD;
                        }
                    }
                }
                else if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    /* Periodically check if the card is still attached. Start a timer first. */
                    if (dObj->generalTimerHandle == SYS_TIME_HANDLE_INVALID)
                    {
                        if (SYS_TIME_DelayMS (dObj->cardDetectionPollingIntervalMs, &dObj->generalTimerHandle) == SYS_TIME_ERROR)
                        {
                            dObj->taskState = DRV_SDMMC_TASK_ERROR;
                            break;
                        }
                    }
                    else
                    {
                        if (SYS_TIME_DelayIsComplete(dObj->generalTimerHandle) == true)
                        {
                            dObj->generalTimerHandle = SYS_TIME_HANDLE_INVALID;

                            /* Polling timeout has expired. Now check if the card is still attached. */
                            if ((dObj->sdCardType & CARD_TYPE_SD_IO) == CARD_TYPE_SD_IO)
                            {
                                dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_DETACH_SDIO_SEL;
                            }
                            else
                            {
                                dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_DETACH;
                            }
                        }
                    }
                }
                else
                {
                     /* Nothing to do */
                }
            <#else>
                if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_NONE)
                {
                    if ((dObj->protocol == DRV_SDMMC_PROTOCOL_EMMC) && (dObj->sleepWhenIdle == true))
                    {
                        if (dObj->emmcSleepWakeState == DRV_SDMMC_EMMC_STATE_WAKE)
                        {
                            dObj->emmcSleepWakeState = DRV_SDMMC_EMMC_STATE_SLEEP;
                            dObj->taskState = DRV_SDMMC_TASK_SLEEP_WAKE_CARD;
                        }
                    }
                }
                else if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_POLLING)
                {
                    /* Periodically check if the card is still attached. Start a timer first. */
                    if (dObj->generalTimerHandle == SYS_TIME_HANDLE_INVALID)
                    {
                        if (SYS_TIME_DelayMS (dObj->cardDetectionPollingIntervalMs, &dObj->generalTimerHandle) == SYS_TIME_ERROR)
                        {
                            dObj->taskState = DRV_SDMMC_TASK_ERROR;
                            break;
                        }
                    }
                    else
                    {
                        if (SYS_TIME_DelayIsComplete(dObj->generalTimerHandle) == true)
                        {
                            dObj->generalTimerHandle = SYS_TIME_HANDLE_INVALID;

                            /* Polling timeout has expired. Now check if the card is still attached. */
                            if ((dObj->sdCardType & CARD_TYPE_SD_IO) == CARD_TYPE_SD_IO)
                            {
                                dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_DETACH_SDIO_SEL;
                            }
                            else
                            {
                                dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_DETACH;
                            }
                        }
                    }
                }
                else if(dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_USE_SDCD)
                {
                    /* PLIB provides the card attach/detach status */
                    if (dObj->sdmmcPlib->sdhostIsCardAttached () == false)
                    {
                        /* Card has been removed. Handle the event. */
                        dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                    }
                }
                else
                {
                     /* Nothing to do */
                }
            </#if>
            }
            break;


        case DRV_SDMMC_TASK_SLEEP_WAKE_CARD:

            dObj->dataTransferFlags.isDataPresent = false;

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SLEEP_WAKE, (((uint32_t)dObj->cardCtxt.rca << 16) | ((uint32_t)dObj->emmcSleepWakeState << 15)), (uint8_t)DRV_SDMMC_CMD_RESP_R1B, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    if (dObj->emmcSleepWakeState == DRV_SDMMC_EMMC_STATE_SLEEP)
                    {
                        /* Card is now in sleep mode. Go back checking for any transfer requests */
                        dObj->taskState = DRV_SDMMC_TASK_PROCESS_QUEUE;
                    }
                    else
                    {
                        /* Card is in wake mode now, select the card and proceed with data transfers */
                        dObj->taskState = DRV_SDMMC_TASK_SELECT_CARD;
                    }
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                }
            }
            break;

        case DRV_SDMMC_TASK_CHECK_CARD_DETACH_SDIO_SEL:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SELECT_DESELECT_CARD, ((uint32_t)dObj->cardCtxt.rca << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R1B, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);

                    if (((response & 0x00001E00U) >> 9) != 0x0FU)
                    {
                        /* Card is not in the expected state */
                        dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                    }
                    else
                    {
                        /* Card is present */
                        dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_DETACH_SDIO_DESEL;
                    }
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                }
            }
            break;

        case DRV_SDMMC_TASK_CHECK_CARD_DETACH_SDIO_DESEL:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SELECT_DESELECT_CARD, 0, (uint8_t)DRV_SDMMC_CMD_RESP_NONE, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                dObj->taskState = DRV_SDMMC_TASK_PROCESS_QUEUE;
            }
            break;

        case DRV_SDMMC_TASK_CHECK_CARD_DETACH:
            dObj->dataTransferFlags.isDataPresent = false;

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SEND_STATUS, ((uint32_t)dObj->cardCtxt.rca << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);
                    if (((response & 0x00001E00U) >> 9) != 0x03U)
                    {
                        /* Card is not in the expected state (standby state) */
                        dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                    }
                    else
                    {
                        /* Card is present and is in the standby state. Go back and check if any request is queued. */
                        dObj->taskState = DRV_SDMMC_TASK_PROCESS_QUEUE;
                    }
                }
                else
                {
                    /* The card is probably removed. Handle detach. */
                    dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
                }
            }
            break;

        case DRV_SDMMC_TASK_SELECT_CARD:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SELECT_DESELECT_CARD, ((uint32_t)dObj->cardCtxt.rca << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R1B, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);
                    dObj->taskState = DRV_SDMMC_TASK_SETUP_XFER;
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_ERROR;
                }
            }
            break;

        case DRV_SDMMC_TASK_SETUP_XFER:

            if (currentBufObj == NULL)
            {
                dObj->taskState = DRV_SDMMC_TASK_ERROR;
                break;
            }

            if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_WR_BLK)
            {
                dObj->sdmmcPlib->sdhostSetBlockCount(currentBufObj->nBlocks);
                dObj->sdmmcPlib->sdhostSetBlockSize(512);

                dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_WRITE;
                dObj->dataTransferFlags.isDataPresent = true;
                dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SDIO_BLOCK;

                currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_IO_RW_EXT;
                currentBufObj->arg = DRV_SDMMC_CMD53_WR_DATA(currentBufObj->fn, currentBufObj->blockStart, true, currentBufObj->nBlocks, currentBufObj->isAddrInc);
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R5;

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_CleanDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks << 9));
                </#if>

                dObj->sdmmcPlib->sdhostSetupDma (currentBufObj->buffer, (currentBufObj->nBlocks << 9), DRV_SDMMC_DATA_XFER_DIR_WR);
            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_WR_BYTES)
            {
                <#if DRV_SDMMC_PLIB == "HSMCI">
                dObj->sdmmcPlib->sdhostSetBlockCount(currentBufObj->nBlocks);
                <#else>
                dObj->sdmmcPlib->sdhostSetBlockSize(currentBufObj->nBlocks);
                </#if>

                dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_WRITE;
                dObj->dataTransferFlags.isDataPresent = true;
                dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SDIO_BYTE;

                currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_IO_RW_EXT;
                currentBufObj->arg = DRV_SDMMC_CMD53_WR_DATA(currentBufObj->fn, currentBufObj->blockStart, false, currentBufObj->nBlocks, currentBufObj->isAddrInc);
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R5;

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_CleanDCache_by_Addr(currentBufObj->buffer, currentBufObj->nBlocks);
                </#if>

                dObj->sdmmcPlib->sdhostSetupDma (currentBufObj->buffer, currentBufObj->nBlocks, DRV_SDMMC_DATA_XFER_DIR_WR);
            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_RD_BLK)
            {
                dObj->sdmmcPlib->sdhostSetBlockCount(currentBufObj->nBlocks);
                dObj->sdmmcPlib->sdhostSetBlockSize(512);

                dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_READ;
                dObj->dataTransferFlags.isDataPresent = true;
                dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SDIO_BLOCK;

                currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_IO_RW_EXT;
                currentBufObj->arg = DRV_SDMMC_CMD53_RD_DATA(currentBufObj->fn, currentBufObj->blockStart, true, currentBufObj->nBlocks, currentBufObj->isAddrInc);
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R5;

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_InvalidateDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks << 9));
                </#if>

                dObj->sdmmcPlib->sdhostSetupDma (currentBufObj->buffer, (currentBufObj->nBlocks << 9), DRV_SDMMC_DATA_XFER_DIR_RD);
            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_RD_BYTES)
            {
                <#if DRV_SDMMC_PLIB == "HSMCI">
                dObj->sdmmcPlib->sdhostSetBlockCount(currentBufObj->nBlocks);
                <#else>
                dObj->sdmmcPlib->sdhostSetBlockSize(currentBufObj->nBlocks);
                </#if>

                dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_READ;
                dObj->dataTransferFlags.isDataPresent = true;
                dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SDIO_BYTE;

                currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_IO_RW_EXT;
                currentBufObj->arg = DRV_SDMMC_CMD53_RD_DATA(currentBufObj->fn, currentBufObj->blockStart, false, currentBufObj->nBlocks, currentBufObj->isAddrInc);
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R5;

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_InvalidateDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks));
                </#if>

                dObj->sdmmcPlib->sdhostSetupDma (currentBufObj->buffer, currentBufObj->nBlocks, DRV_SDMMC_DATA_XFER_DIR_RD);
            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SD_MEM_READ)
            {
                dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_READ;
                dObj->dataTransferFlags.isDataPresent = true;

                if (currentBufObj->nBlocks == 1U)
                {
                    dObj->sdmmcPlib->sdhostSetBlockCount(0);
                    currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_READ_SINGLE_BLOCK;
                    dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SINGLE;
                }
                else
                {
                    dObj->sdmmcPlib->sdhostSetBlockCount (currentBufObj->nBlocks);
                    currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_READ_MULTI_BLOCK;
                    dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_MULTI;
                }

                currentBufObj->arg = (dObj->cardCtxt.cardType == DRV_SDMMC_CARD_TYPE_STANDARD)? currentBufObj->blockStart << 9 : currentBufObj->blockStart;
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R1;

                dObj->sdmmcPlib->sdhostSetBlockSize(512);

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_InvalidateDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks << 9));
                </#if>

                dObj->sdmmcPlib->sdhostSetupDma (currentBufObj->buffer, (currentBufObj->nBlocks << 9), DRV_SDMMC_DATA_XFER_DIR_RD);

            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SD_MEM_WRITE)
            {
                dObj->dataTransferFlags.transferDir = DRV_SDMMC_DATA_TRANSFER_DIR_WRITE;
                dObj->dataTransferFlags.isDataPresent = true;

                if (currentBufObj->nBlocks == 1U)
                {
                    dObj->sdmmcPlib->sdhostSetBlockCount(0);
                    currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_WRITE_SINGLE_BLOCK;
                    dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_SINGLE;
                }
                else
                {
                    dObj->sdmmcPlib->sdhostSetBlockCount (currentBufObj->nBlocks);
                    currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_WRITE_MULTI_BLOCK;
                    dObj->dataTransferFlags.transferType = DRV_SDMMC_DATA_TRANSFER_TYPE_MULTI;
                }
                currentBufObj->arg = (dObj->cardCtxt.cardType == DRV_SDMMC_CARD_TYPE_STANDARD)? currentBufObj->blockStart << 9 : currentBufObj->blockStart;
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R1;

                dObj->sdmmcPlib->sdhostSetBlockSize(512);

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_CleanDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks << 9));
                </#if>

                dObj->sdmmcPlib->sdhostSetupDma (currentBufObj->buffer, (currentBufObj->nBlocks << 9), DRV_SDMMC_DATA_XFER_DIR_WR);
            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_WR_DIR)
            {
                currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR;
                currentBufObj->arg = DRV_SDMMC_CMD52_WR_DATA(currentBufObj->fn, currentBufObj->blockStart, *((uint8_t*)(currentBufObj->buffer)), currentBufObj->isAddrInc);
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R5;

                dObj->dataTransferFlags.isDataPresent = false;

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_CleanDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks));
                </#if>
            }
            else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_RD_DIR)
            {
                currentBufObj->opCode = (uint8_t)DRV_SDMMC_CMD_IO_RW_DIR;
                currentBufObj->arg = DRV_SDMMC_CMD52_RD_DATA(currentBufObj->fn, currentBufObj->blockStart);
                currentBufObj->respType = DRV_SDMMC_CMD_RESP_R5;

                dObj->dataTransferFlags.isDataPresent = false;

                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
                SYS_CACHE_InvalidateDCache_by_Addr(currentBufObj->buffer, (int32_t)(currentBufObj->nBlocks));
                </#if>
            }


            dObj->taskState = DRV_SDMMC_TASK_XFER_COMMAND;

            /* Fall through to the next state */

        case DRV_SDMMC_TASK_XFER_COMMAND:

            lDRV_SDMMC_CommandSend (dObj, currentBufObj->opCode, currentBufObj->arg, (uint8_t)currentBufObj->respType, &dObj->dataTransferFlags);

            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    if (currentBufObj->respType == DRV_SDMMC_CMD_RESP_R5)
                    {
                        dObj->sdmmcPlib->sdhostReadResponse(DRV_SDMMC_READ_RESP_REG_0, &response);

                        if ((DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(response) & DRV_SDMMC_SDIO_CMD52_RESP_ERR_MSK) != 0U)
                        {
                            dObj->taskState = DRV_SDMMC_TASK_ERROR;
                        }
                        else if (currentBufObj->opType == DRV_SDMMC_OPERATION_TYPE_SDIO_RD_DIR)
                        {
                            *((uint8_t*)(currentBufObj->buffer)) = DRV_SDMMC_SDIO_CMD52_RESP_DATA_GET(response);
                        }
                    }

                    if (dObj->dataTransferFlags.isDataPresent == true)
                    {
                        dObj->taskState = DRV_SDMMC_TASK_WAIT_DATA_XFER_COMPLETE;
                    }
                    else
                    {
                        dObj->taskState = DRV_SDMMC_TASK_DESELECT_CARD;
                    }
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_ERROR;
                }

                dObj->dataTransferFlags.isDataPresent = false;
            }
            break;

        case DRV_SDMMC_TASK_WAIT_DATA_XFER_COMPLETE:
            /* Wait for the data transfer to get completed. */
            if (dObj->cardCtxt.isDataCompleted == true)
            {
                /* Check if there are any data errors. */
                if ((dObj->cardCtxt.errorFlag & DRV_SDMMC_ANY_DATA_ERRORS) != 0U)
                {
                    dObj->taskState = DRV_SDMMC_TASK_ERROR;
                }
                else
                {
                    if (currentBufObj != NULL)
                    {
                        /* Stop Transfer if multiple blocks are being
                         * transferred. CMD13 status check to ensure that
                         * there were no issues while performing the data
                         * transfer. */
                        if (dObj->dataTransferFlags.transferType == DRV_SDMMC_DATA_TRANSFER_TYPE_MULTI)
                        {
                            /* Send stop transmission command. */
                            dObj->taskState = DRV_SDMMC_TASK_SEND_STOP_TRANS_CMD;
                        }
                        else if (dObj->dataTransferFlags.transferType == DRV_SDMMC_DATA_TRANSFER_TYPE_SINGLE)
                        {
                            dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_STATUS;
                        }
                        else
                        {
                            dObj->taskState = DRV_SDMMC_TASK_DESELECT_CARD;
                        }
                    }
                    else
                    {
                        dObj->taskState = DRV_SDMMC_TASK_ERROR;
                    }
                }
            }
            break;

        case DRV_SDMMC_TASK_SEND_STOP_TRANS_CMD:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_STOP_TRANSMISSION, 0, (uint8_t)DRV_SDMMC_CMD_RESP_R1B, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->taskState = DRV_SDMMC_TASK_CHECK_CARD_STATUS;
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_ERROR;
                }
            }
            break;

        case DRV_SDMMC_TASK_CHECK_CARD_STATUS:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SEND_STATUS, ((uint32_t)dObj->cardCtxt.rca << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->commandStatus == DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                {
                    dObj->sdmmcPlib->sdhostReadResponse (DRV_SDMMC_READ_RESP_REG_0, &response);
                    if ((response & 0x100U) != 0U)
                    {
                        //Card is ready for new data. Corresponds to buffer empty signaling on the bus.
                        dObj->taskState = DRV_SDMMC_TASK_DESELECT_CARD;
                    }
                }
                else
                {
                    dObj->taskState = DRV_SDMMC_TASK_ERROR;
                }
            }
            break;

        case DRV_SDMMC_TASK_DESELECT_CARD:

            lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SELECT_DESELECT_CARD, 0, (uint8_t)DRV_SDMMC_CMD_RESP_NONE, &dObj->dataTransferFlags);
            if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
            {
                currentBufObj->status = DRV_SDMMC_COMMAND_COMPLETED;
                dObj->taskState = DRV_SDMMC_TASK_TRANSFER_COMPLETE;
            }
            break;

        case DRV_SDMMC_TASK_ERROR:
            if (dObj->cardDetectionMethod == DRV_SDMMC_CD_METHOD_USE_SDCD)
            {
                cardAttached = dObj->sdmmcPlib->sdhostIsCardAttached ();
                currentBufObj->status = DRV_SDMMC_COMMAND_ERROR_UNKNOWN;
                dObj->taskState = DRV_SDMMC_TASK_TRANSFER_COMPLETE;
            }
            else
            {
                /* PLIB does not provide card attach/detach status (HSMCI), poll the status
                 * of the card by reading the card status from the card */
                dObj->dataTransferFlags.isDataPresent = false;

                lDRV_SDMMC_CommandSend (dObj, (uint8_t)DRV_SDMMC_CMD_SEND_STATUS, ((uint32_t)dObj->cardCtxt.rca << 16), (uint8_t)DRV_SDMMC_CMD_RESP_R1, &dObj->dataTransferFlags);
                if (dObj->cmdState == DRV_SDMMC_CMD_EXEC_IS_COMPLETE)
                {
                    currentBufObj->status = DRV_SDMMC_COMMAND_ERROR_UNKNOWN;
                    dObj->taskState = DRV_SDMMC_TASK_TRANSFER_COMPLETE;

                    if (dObj->commandStatus != DRV_SDMMC_COMMAND_STATUS_SUCCESS)
                    {
                        /* The card is probably removed */
                        cardAttached = false;
                    }
                }
            }
            break;

        case DRV_SDMMC_TASK_TRANSFER_COMPLETE:

            if (currentBufObj != NULL)
            {
                /* Get the client object that owns this buffer */
                clientObj = &((DRV_SDMMC_CLIENT_OBJ *)dObj->clientObjPool)[currentBufObj->clientHandle & DRV_SDMMC_INDEX_MASK];

                /* Check if the client that submitted the request is active? */
                if (clientObj->clientHandle == currentBufObj->clientHandle)
                {
                    if (currentBufObj->status == DRV_SDMMC_COMMAND_COMPLETED)
                    {
                        evtStatus = DRV_SDMMC_EVENT_COMMAND_COMPLETE;
                    }
                    else
                    {
                        evtStatus = DRV_SDMMC_EVENT_COMMAND_ERROR;
                    }
                    if(clientObj->eventHandler != NULL)
                    {
                        /* Call the event handler */
                        clientObj->eventHandler((SYS_MEDIA_BLOCK_EVENT)evtStatus, currentBufObj->commandHandle, clientObj->context);
                    }
                }
                /* Free the completed buffer */
                lDRV_SDMMC_RemoveBufferObjFromList(dObj);
            }

            if (cardAttached)
            {
                dObj->taskState = DRV_SDMMC_TASK_PROCESS_QUEUE;
            }
            else
            {
                /* Reset the cardAttached back to true */
                cardAttached = true;
                dObj->taskState = DRV_SDMMC_TASK_HANDLE_CARD_DETACH;
            }
            break;

        case DRV_SDMMC_TASK_HANDLE_CARD_DETACH:

            // Remove the buffer objects queued by all clients on this driver instance
            lDRV_SDMMC_RemoveBufferObjects (dObj);

            dObj->mediaState = SYS_MEDIA_DETACHED;
            dObj->taskState = DRV_SDMMC_TASK_WAIT_FOR_DEVICE_ATTACH;
            break;

        default:
                   /* Nothing to do */
            break;
    }

    if (OSAL_MUTEX_Unlock(&dObj->mutex) != OSAL_RESULT_SUCCESS)
    {
        SYS_ASSERT(false, "SDMMC Driver: OSAL_MUTEX_Unlock failed");
    }
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
</#if>
/* MISRAC 2012 deviation block end */

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 16.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 16.3"
#pragma coverity compliance end_block "MISRA C-2012 Rule 16.5"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */