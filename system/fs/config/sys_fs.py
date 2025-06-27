# coding: utf-8
"""*****************************************************************************
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
*****************************************************************************"""

import os

sys_fs_mcc_helpkeyword = "mcc_h3_sys_fs_configurations"

exclusionList = ["fx_user_sample.h"]
def AddFileXFiles(component, dirPath, destPath):
    dirPath = str(Module.getPath() + dirPath)
    fileNames = os.listdir(dirPath)
    for fileName in fileNames:
        # Find FileX source/header/assembler files
        if fileName.lower().startswith("fx") and fileName.lower().endswith(('.c', '.h')):
            # Dont process files in the exclusion list
            if fileName in exclusionList:
                continue
            # Get the relative path of the file w.r.t to the module path
            sourcePath = os.path.relpath(os.path.join(dirPath, fileName), Module.getPath())
            #create a file symbol
            fileSymbolName =  "FILEX_" + fileName.replace(".", "_").upper()
            fxFile = component.createFileSymbol(fileSymbolName, None)
            fxFile.setSourcePath(sourcePath)
            fxFile.setDestPath(destPath)
            fxFile.setProjectPath(destPath.split("../../third_party/azure_rtos/")[1])
            fxFile.setMarkup(False)
            fxFile.setOutputName(fileName)
            # if it is a source
            if fileName.lower().endswith(('.c')):
                fxFile.setType("SOURCE")
            else:
                fxFile.setType("HEADER")
            fxFile.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue(component.getID().lower(), "SYS_FS_FILEX")), ["SYS_FS_FILEX"])
            fxFile.setEnabled(Database.getSymbolValue(component.getID().lower(), "SYS_FS_FILEX"))

def updateLBA64Symbol(symbol, event):
    symbol.setVisible(event["value"])
    symbol.setValue(event["value"])

def instantiateComponent(sysFSComponent):
    fsTypes = ["FAT","MPFS2","FILEX"]
    mediaTypes =  ["SYS_FS_MEDIA_TYPE_NVM",
                    "SYS_FS_MEDIA_TYPE_MSD",
                    "SYS_FS_MEDIA_TYPE_SD_CARD",
                    "SYS_FS_MEDIA_TYPE_RAM",
                    "SYS_FS_MEDIA_TYPE_SPIFLASH"]

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Media File" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_MEDIA", {"isEnabled":True})

    if ("PIC32MZ" in Database.getSymbolValue("core", "PRODUCT_FAMILY")):
        if (Database.getSymbolValue("core", "USE_CACHE_MAINTENANCE") == False):
            Database.setSymbolValue("core", "USE_CACHE_MAINTENANCE", True)

    sysFSMenu = sysFSComponent.createMenuSymbol("SYS_FS_MENU", None)
    sysFSMenu.setLabel("File System settings")
    sysFSMenu.setHelp(sys_fs_mcc_helpkeyword)
    sysFSMenu.setDescription("File System settings")
    sysFSMenu.setVisible(True)

    # RTOS Settings
    sysFSRTOSMenu = sysFSComponent.createMenuSymbol("SYS_FS_RTOS_MENU", None)
    sysFSRTOSMenu.setLabel("RTOS settings")
    sysFSRTOSMenu.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSMenu.setDescription("RTOS settings")
    sysFSRTOSMenu.setVisible((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"))
    sysFSRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS"])

    sysFSRTOSTask = sysFSComponent.createComboSymbol("SYS_FS_RTOS", sysFSRTOSMenu, ["Standalone"])
    sysFSRTOSTask.setLabel("Run Library Tasks As")
    sysFSRTOSTask.setDefaultValue("Standalone")
    sysFSRTOSTask.setVisible(False)

    sysFSRTOSStackSize = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_STACK_SIZE", sysFSRTOSMenu)
    sysFSRTOSStackSize.setLabel("Stack Size (in bytes)")
    sysFSRTOSStackSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSStackSize.setDefaultValue(4096)
    sysFSRTOSStackSize.setMin(1)
    sysFSRTOSStackSize.setMax(2147483647)

    sysFSRTOSMsgQSize = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_TASK_MSG_QTY", sysFSRTOSMenu)
    sysFSRTOSMsgQSize.setLabel("Maximum Message Queue Size")
    sysFSRTOSMsgQSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSMsgQSize.setDescription("A µC/OS-III task contains an optional internal message queue (if OS_CFG_TASK_Q_EN is set to DEF_ENABLED in os_cfg.h). This argument specifies the maximum number of messages that the task can receive through this message queue. The user may specify that the task is unable to receive messages by setting this argument to 0")
    sysFSRTOSMsgQSize.setDefaultValue(0)
    sysFSRTOSMsgQSize.setVisible(getActiveRtos() == "MicriumOSIII")
    sysFSRTOSMsgQSize.setDependencies(sysFsRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    sysFSRTOSTaskTimeQuanta = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_TASK_TIME_QUANTA", sysFSRTOSMenu)
    sysFSRTOSTaskTimeQuanta.setLabel("Task Time Quanta")
    sysFSRTOSTaskTimeQuanta.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskTimeQuanta.setDescription("The amount of time (in clock ticks) for the time quanta when Round Robin is enabled. If you specify 0, then the default time quanta will be used which is the tick rate divided by 10.")
    sysFSRTOSTaskTimeQuanta.setDefaultValue(0)
    sysFSRTOSTaskTimeQuanta.setVisible(getActiveRtos() == "MicriumOSIII")
    sysFSRTOSTaskTimeQuanta.setDependencies(sysFsRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    sysFSRTOSTaskPriority = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_TASK_PRIORITY", sysFSRTOSMenu)
    sysFSRTOSTaskPriority.setLabel("Task Priority")
    sysFSRTOSTaskPriority.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskPriority.setDefaultValue(1)
    sysFSRTOSTaskPriority.setMin(0)
    sysFSRTOSTaskPriority.setMax(2147483647)

    sysFSRTOSTaskDelay = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_USE_DELAY", sysFSRTOSMenu)
    sysFSRTOSTaskDelay.setLabel("Use Task Delay?")
    sysFSRTOSTaskDelay.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskDelay.setDefaultValue(True)

    sysFSRTOSTaskDelayVal = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_DELAY", sysFSRTOSMenu)
    sysFSRTOSTaskDelayVal.setLabel("Task Delay")
    sysFSRTOSTaskDelayVal.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskDelayVal.setDefaultValue(10)
    sysFSRTOSTaskDelayVal.setDependencies(showRTOSTaskDel, ["SYS_FS_RTOS_USE_DELAY"])
    sysFSRTOSTaskDelayVal.setMin(0)
    sysFSRTOSTaskDelayVal.setMax(2147483647)

    sysFSRTOSTaskSpecificOpt = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_TASK_OPT_NONE", sysFSRTOSMenu)
    sysFSRTOSTaskSpecificOpt.setLabel("Task Specific Options")
    sysFSRTOSTaskSpecificOpt.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskSpecificOpt.setDescription("Contains task-specific options. Each option consists of one bit. The option is selected when the bit is set. The current version of µC/OS-III supports the following options:")
    sysFSRTOSTaskSpecificOpt.setDefaultValue(True)
    sysFSRTOSTaskSpecificOpt.setVisible(getActiveRtos() == "MicriumOSIII")
    sysFSRTOSTaskSpecificOpt.setDependencies(sysFsRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    sysFSRTOSTaskStkChk = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_TASK_OPT_STK_CHK", sysFSRTOSTaskSpecificOpt)
    sysFSRTOSTaskStkChk.setLabel("Stack checking is allowed for the task")
    sysFSRTOSTaskStkChk.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskStkChk.setDescription("Specifies whether stack checking is allowed for the task")
    sysFSRTOSTaskStkChk.setDefaultValue(True)
    sysFSRTOSTaskStkChk.setDependencies(sysFsRtosMicriumOSIIITaskOptVisibility, ["SYS_FS_RTOS_TASK_OPT_NONE"])

    sysFSRTOSTaskStkClr = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_TASK_OPT_STK_CLR", sysFSRTOSTaskSpecificOpt)
    sysFSRTOSTaskStkClr.setLabel("Stack needs to be cleared")
    sysFSRTOSTaskStkClr.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskStkClr.setDescription("Specifies whether the stack needs to be cleared")
    sysFSRTOSTaskStkClr.setDefaultValue(True)
    sysFSRTOSTaskStkClr.setDependencies(sysFsRtosMicriumOSIIITaskOptVisibility, ["SYS_FS_RTOS_TASK_OPT_NONE"])

    sysFSRTOSTaskSaveFp = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_TASK_OPT_SAVE_FP", sysFSRTOSTaskSpecificOpt)
    sysFSRTOSTaskSaveFp.setLabel("Floating-point registers needs to be saved")
    sysFSRTOSTaskSaveFp.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskSaveFp.setDescription("Specifies whether floating-point registers are saved. This option is only valid if the processor has floating-point hardware and the processor-specific code saves the floating-point registers")
    sysFSRTOSTaskSaveFp.setDefaultValue(False)
    sysFSRTOSTaskSaveFp.setDependencies(sysFsRtosMicriumOSIIITaskOptVisibility, ["SYS_FS_RTOS_TASK_OPT_NONE"])

    sysFSRTOSTaskNoTls = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_TASK_OPT_NO_TLS", sysFSRTOSTaskSpecificOpt)
    sysFSRTOSTaskNoTls.setLabel("TLS (Thread Local Storage) support needed for the task")
    sysFSRTOSTaskNoTls.setHelp(sys_fs_mcc_helpkeyword)
    sysFSRTOSTaskNoTls.setDescription("If the caller doesn’t want or need TLS (Thread Local Storage) support for the task being created. If you do not include this option, TLS will be supported by default. TLS support was added in V3.03.00")
    sysFSRTOSTaskNoTls.setDefaultValue(False)
    sysFSRTOSTaskNoTls.setDependencies(sysFsRtosMicriumOSIIITaskOptVisibility, ["SYS_FS_RTOS_TASK_OPT_NONE"])

    sysFSMaxFiles = sysFSComponent.createIntegerSymbol("SYS_FS_MAX_FILES", sysFSMenu)
    sysFSMaxFiles.setLabel("Maximum Simultaneous File Access")
    sysFSMaxFiles.setHelp(sys_fs_mcc_helpkeyword)
    sysFSMaxFiles.setDefaultValue(1)
    sysFSMaxFiles.setMin(1)
    sysFSMaxFiles.setMax(2147483647)

    sysFSBlockSize = sysFSComponent.createIntegerSymbol("SYS_FS_MEDIA_MAX_BLOCK_SIZE", sysFSMenu)
    sysFSBlockSize.setLabel("Size Of Block")
    sysFSBlockSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSBlockSize.setDefaultValue(512)
    sysFSBlockSize.setReadOnly(True)
    sysFSBlockSize.setMin(512)
    sysFSBlockSize.setMax(4096)

    sysFSBufferSize = sysFSComponent.createIntegerSymbol("SYS_FS_MEDIA_MANAGER_BUFFER_SIZE", sysFSMenu)
    sysFSBufferSize.setLabel("Size Of Media Manager Buffer")
    sysFSBufferSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSBufferSize.setDefaultValue(2048)
    sysFSBufferSize.setMin(512)
    sysFSBufferSize.setMax(2147483647)

    sysFSAutoMount = sysFSComponent.createBooleanSymbol("SYS_FS_AUTO_MOUNT", sysFSMenu)
    sysFSAutoMount.setLabel("Use File System Auto Mount Feature?")
    sysFSAutoMount.setHelp(sys_fs_mcc_helpkeyword)
    sysFSAutoMount.setDefaultValue(False)

    sysFSMedia = sysFSComponent.createIntegerSymbol("SYS_FS_INSTANCES_NUMBER", sysFSMenu)
    sysFSMedia.setLabel("Total Number Of Media")
    sysFSMedia.setHelp(sys_fs_mcc_helpkeyword)
    sysFSMedia.setDefaultValue(1)
    sysFSMedia.setMin(1)
    sysFSMedia.setMax(4)

    sysFSVol = sysFSComponent.createIntegerSymbol("SYS_FS_VOLUME_NUMBER", sysFSMenu)
    sysFSVol.setLabel("Total Number Of Volumes")
    sysFSVol.setHelp(sys_fs_mcc_helpkeyword)
    sysFSVol.setDefaultValue(1)
    sysFSVol.setMin(1)
    sysFSVol.setMax(10)
    sysFSVol.setDependencies(showFSVol, ["SYS_FS_AUTO_MOUNT"])

    sysFSTotalVol = sysFSComponent.createIntegerSymbol("SYS_FS_TOTAL_VOLUMES", sysFSMenu)
    sysFSTotalVol.setDefaultValue(sysFSVol.getValue())
    sysFSTotalVol.setVisible(False)

    sysFSClientNum = sysFSComponent.createIntegerSymbol("SYS_FS_CLIENT_NUMBER", sysFSMenu)
    sysFSClientNum.setLabel("Total Number File System Clients")
    sysFSClientNum.setHelp(sys_fs_mcc_helpkeyword)
    sysFSClientNum.setDescription("Indicates Number of clients who want to receive events on Mount or Unmount of volumes")
    sysFSClientNum.setDefaultValue(1)
    sysFSClientNum.setVisible(False)
    sysFSClientNum.setDependencies(showFSClientNum, ["SYS_FS_AUTO_MOUNT"])

    sysFSMedia = []
    sysFSMediaConfMenu = []
    sysFSMediaType = []
    sysFSMediaFsType = []
    sysFSMediaNVM = []
    sysFSMediaSRAM = []
    sysFSMediaVol = []
    sysFSMediaxVOL = []
    sysFSMediaxVolConfMenu = []
    sysFSMediaxVOLDeviceName = []
    sysFSMediaxVOLMountName = []
    showMediaVOL = [showMediaVOL0, showMediaVOL1, showMediaVOL2, showMediaVOL3]
    mediaDeviceName = [mediaDeviceName0, mediaDeviceName1, mediaDeviceName2, mediaDeviceName3]

    for i in range(0,4):
        sysFSMedia.append(i)
        sysFSMedia[i] = sysFSComponent.createBooleanSymbol("SYS_FS_IDX" + str(i), sysFSMenu)
        sysFSMedia[i].setLabel("Media" + str(i))
        sysFSMedia[i].setHelp(sys_fs_mcc_helpkeyword)
        sysFSMedia[i].setDefaultValue(i == 0)
        sysFSMedia[i].setVisible(i == 0)
        sysFSMedia[i].setDependencies(showMedia, ["SYS_FS_INSTANCES_NUMBER"])

        sysFSMediaConfMenu.append(i)
        sysFSMediaConfMenu[i] = sysFSComponent.createMenuSymbol("MEDIA_CONF_MENU" + str(i), sysFSMedia[i])
        sysFSMediaConfMenu[i].setLabel("Media configuration" + str(i))
        sysFSMediaConfMenu[i].setHelp(sys_fs_mcc_helpkeyword)
        sysFSMediaConfMenu[i].setDescription("Media configuration" + str(i))
        sysFSMediaConfMenu[i].setVisible(False)
        sysFSMediaConfMenu[i].setDependencies(showMediaConfMenu, ["SYS_FS_IDX" + str(i), "SYS_FS_AUTO_MOUNT"])

        sysFSMediaType.append(i)
        sysFSMediaType[i] = sysFSComponent.createComboSymbol("SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i), sysFSMediaConfMenu[i], mediaTypes)
        sysFSMediaType[i].setLabel("Media Type")
        sysFSMediaType[i].setHelp(sys_fs_mcc_helpkeyword)
        sysFSMediaType[i].setDefaultValue("SYS_FS_MEDIA_TYPE_SD_CARD")

        sysFSMediaFsType.append(i)
        sysFSMediaFsType[i] = sysFSComponent.createComboSymbol("SYS_FS_TYPE_DEFINE_IDX" + str(i) , sysFSMediaConfMenu[i], fsTypes)
        sysFSMediaFsType[i].setLabel("File System Type")
        sysFSMediaFsType[i].setHelp(sys_fs_mcc_helpkeyword)
        sysFSMediaFsType[i].setDefaultValue("FAT")

        sysFSMediaNVM.append(i)
        sysFSMediaNVM[i] = sysFSComponent.createBooleanSymbol("SYS_FS_USE_NVM_MBR" + str(i), sysFSMediaConfMenu[i])
        sysFSMediaNVM[i].setLabel("Create FAT12 in NVM")
        sysFSMediaNVM[i].setDefaultValue(False)
        sysFSMediaNVM[i].setVisible(False)
#        sysFSMediaNVM[i].setDependencies(showMediaNVMFAT12, ["SYS_FS_TYPE_DEFINE_IDX" + str(i), "SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i)])

        sysFSMediaSRAM.append(i)
        sysFSMediaSRAM[i] = sysFSComponent.createBooleanSymbol("SYS_FS_USE_SRAM_MBR" + str(i), sysFSMediaConfMenu[i])
        sysFSMediaSRAM[i].setLabel("Create FAT12 in SRAM")
        sysFSMediaSRAM[i].setDefaultValue(False)
        sysFSMediaSRAM[i].setVisible(False)
#        sysFSMediaSRAM[i].setDependencies(showMediaSRAMFAT12, ["SYS_FS_TYPE_DEFINE_IDX" + str(i), "SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i)])

        sysFSMediaVol.append(i)
        sysFSMediaVol[i] = sysFSComponent.createIntegerSymbol("SYS_FS_VOLUME_INSTANCES_NUMBER_IDX" + str(i), sysFSMediaConfMenu[i])
        sysFSMediaVol[i].setLabel("Number Of Volumes")
        sysFSMediaVol[i].setHelp(sys_fs_mcc_helpkeyword)
        sysFSMediaVol[i].setDefaultValue(1)
        sysFSMediaVol[i].setMax(4)
        sysFSMediaVol[i].setDependencies(totalNumberOfVolumes, ["SYS_FS_VOLUME_INSTANCES_NUMBER_IDX" + str(i), "SYS_FS_IDX" + str(i), "SYS_FS_AUTO_MOUNT", "SYS_FS_VOLUME_NUMBER"])

        for j in range(0,4):
            pos = (i*4) + j
            sysFSMediaxVOL.append(pos)
            sysFSMediaxVOL[pos] = sysFSComponent.createBooleanSymbol("SYS_FS_VOL_" + str(j+1) + "_IDX" + str(i), sysFSMediaConfMenu[i])
            sysFSMediaxVOL[pos].setLabel("Volume" + str(j))
            sysFSMediaxVOL[pos].setHelp(sys_fs_mcc_helpkeyword)
            sysFSMediaxVOL[pos].setDefaultValue(pos % 4 == 0)
            sysFSMediaxVOL[pos].setVisible(pos % 4 == 0)
            sysFSMediaxVOL[pos].setDependencies(showMediaVOL[i], ["SYS_FS_VOLUME_INSTANCES_NUMBER_IDX"  + str(i)])

            sysFSMediaxVolConfMenu.append(pos)
            sysFSMediaxVolConfMenu[pos] = sysFSComponent.createMenuSymbol("VOL_CONF_MENU" + str(pos) , sysFSMediaxVOL[pos])
            sysFSMediaxVolConfMenu[pos].setLabel("Volume configuration" + str(j) )
            sysFSMediaxVolConfMenu[pos].setHelp(sys_fs_mcc_helpkeyword)
            sysFSMediaxVolConfMenu[pos].setDescription("Volume configuration" + str(j))
            sysFSMediaxVolConfMenu[pos].setVisible(True)
            sysFSMediaxVolConfMenu[pos].setDependencies(showMediaVolMenu, ["SYS_FS_VOL_" + str(j+1) + "_IDX" + str(i)])

            sysFSMediaxVOLDeviceName.append(pos)
            sysFSMediaxVOLDeviceName[pos] = sysFSComponent.createStringSymbol("SYS_FS_MEDIA_DEVICE_" + str(j+1) + "_NAME_IDX"  + str(i), sysFSMediaxVolConfMenu[pos])
            sysFSMediaxVOLDeviceName[pos].setLabel("Device Name")
            sysFSMediaxVOLDeviceName[pos].setHelp(sys_fs_mcc_helpkeyword)
            sysFSMediaxVOLDeviceName[pos].setDefaultValue("/dev/mmcblka" + str(j+1))
            sysFSMediaxVOLDeviceName[pos].setVisible(True)
            sysFSMediaxVOLDeviceName[pos].setDependencies(mediaDeviceName[i], ["SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i)])

            sysFSMediaxVOLMountName.append(pos)
            sysFSMediaxVOLMountName[pos] = sysFSComponent.createStringSymbol("SYS_FS_MEDIA_MOUNT_" + str(j+1) + "_NAME_IDX"  + str(i), sysFSMediaxVolConfMenu[pos])
            sysFSMediaxVOLMountName[pos].setLabel("Media Mount Name")
            sysFSMediaxVOLMountName[pos].setHelp(sys_fs_mcc_helpkeyword)
            sysFSMediaxVOLMountName[pos].setDefaultValue("/mnt/myDrive" + str(j+1))
            sysFSMediaxVOLMountName[pos].setVisible(True)

    sysFSFileType = sysFSComponent.createIntegerSymbol("SYS_FS_MAX_FILE_SYSTEM_TYPE", sysFSMenu)
    sysFSFileType.setLabel("File System Types")
    sysFSFileType.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFileType.setDefaultValue(1)
    sysFSFileType.setMin(1)
    sysFSFileType.setMax(4)

    sysFSFat = sysFSComponent.createBooleanSymbol("SYS_FS_FAT", sysFSMenu)
    sysFSFat.setLabel("FAT File System")
    sysFSFat.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFat.setDefaultValue(True)

    sysFSFatVersion = sysFSComponent.createStringSymbol("SYS_FS_FAT_VERSION", sysFSFat)
    sysFSFatVersion.setLabel("FAT File System Version")
    sysFSFatVersion.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFatVersion.setDefaultValue("v0.15")
    sysFSFatVersion.setVisible(sysFSFat.getValue())
    sysFSFatVersion.setReadOnly(True)
    sysFSFatVersion.setDependencies(sysFsSymbolShow, ["SYS_FS_FAT"])

    sysFSFatReadonly = sysFSComponent.createBooleanSymbol("SYS_FS_FAT_READONLY", sysFSFat)
    sysFSFatReadonly.setLabel("Make FAT File System Read-only")
    sysFSFatReadonly.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFatReadonly.setDefaultValue(False)
    sysFSFatReadonly.setVisible(sysFSFat.getValue())
    sysFSFatReadonly.setDependencies(sysFsSymbolShow, ["SYS_FS_FAT"])

    sysFSFatCodePage = sysFSComponent.createKeyValueSetSymbol("SYS_FS_FAT_CODE_PAGE", sysFSFat)
    sysFSFatCodePage.setLabel("OEM code page to be used")
    sysFSFatCodePage.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFatCodePage.addKey("CODE_PAGE_0"  , "0"  , "All")
    sysFSFatCodePage.addKey("CODE_PAGE_437", "437", "U.S.")
    sysFSFatCodePage.addKey("CODE_PAGE_720", "720", "Arabic")
    sysFSFatCodePage.addKey("CODE_PAGE_737", "737", "Greek")
    sysFSFatCodePage.addKey("CODE_PAGE_771", "771", "KBL")
    sysFSFatCodePage.addKey("CODE_PAGE_775", "775", "Baltic")
    sysFSFatCodePage.addKey("CODE_PAGE_850", "850", "Latin 1")
    sysFSFatCodePage.addKey("CODE_PAGE_852", "852", "Latin 2")
    sysFSFatCodePage.addKey("CODE_PAGE_855", "855", "Cyrillic")
    sysFSFatCodePage.addKey("CODE_PAGE_857", "857", "Turkish")
    sysFSFatCodePage.addKey("CODE_PAGE_860", "860", "Portuguese")
    sysFSFatCodePage.addKey("CODE_PAGE_861", "861", "Icelandic")
    sysFSFatCodePage.addKey("CODE_PAGE_862", "862", "Hebrew")
    sysFSFatCodePage.addKey("CODE_PAGE_863", "863", "Canadian French")
    sysFSFatCodePage.addKey("CODE_PAGE_864", "864", "Arabic")
    sysFSFatCodePage.addKey("CODE_PAGE_865", "865", "Nordic")
    sysFSFatCodePage.addKey("CODE_PAGE_866", "866", "Russian")
    sysFSFatCodePage.addKey("CODE_PAGE_869", "869", "Greek 2")
    sysFSFatCodePage.addKey("CODE_PAGE_932", "932", "Japanese (DBCS)")
    sysFSFatCodePage.addKey("CODE_PAGE_936", "936", "Simplified Chinese (DBCS)")
    sysFSFatCodePage.addKey("CODE_PAGE_949", "949", "Korean (DBCS)")
    sysFSFatCodePage.addKey("CODE_PAGE_950", "950", "Traditional Chinese (DBCS)")
    sysFSFatCodePage.setOutputMode("Value")
    sysFSFatCodePage.setDisplayMode("Description")
    sysFSFatCodePage.setDefaultValue(1)
    sysFSFatCodePage.setVisible(sysFSFat.getValue())
    sysFSFatCodePage.setDependencies(sysFsSymbolShow, ["SYS_FS_FAT"])

    sysFSFatExFAT = sysFSComponent.createBooleanSymbol("SYS_FS_FAT_EXFAT_ENABLE", sysFSFat)
    sysFSFatExFAT.setLabel("Enable exFAT File System Support")
    sysFSFatExFAT.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFatExFAT.setDefaultValue(False)
    sysFSFatExFAT.setVisible(sysFSFat.getValue())
    sysFSFatExFAT.setDependencies(sysFsSymbolShow, ["SYS_FS_FAT"])

    sysFSFatLBA64 = sysFSComponent.createBooleanSymbol("SYS_FS_FAT_LBA64_ENABLE", sysFSFatExFAT)
    sysFSFatLBA64.setLabel("Enable 64-bit LBA Support")
    sysFSFatLBA64.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFatLBA64.setDefaultValue(False)
    sysFSFatLBA64.setVisible(sysFSFatExFAT.getValue())
    sysFSFatLBA64.setDependencies(updateLBA64Symbol, ["SYS_FS_FAT_EXFAT_ENABLE"])

    sysFSMpfs = sysFSComponent.createBooleanSymbol("SYS_FS_MPFS", sysFSMenu)
    sysFSMpfs.setLabel("Microchip File System")
    sysFSMpfs.setHelp(sys_fs_mcc_helpkeyword)
    sysFSMpfs.setDefaultValue(False)

    sysFSLFS = sysFSComponent.createBooleanSymbol("SYS_FS_LFS", sysFSMenu)
    sysFSLFS.setLabel("LittleFS File System")
    sysFSLFS.setHelp(sys_fs_mcc_helpkeyword)
    sysFSLFS.setDefaultValue(False)
    sysFSLFS.setDependencies(sysFsLFSEnabled, ["SYS_FS_LFS"])

    global isLFSExist
    isLFSExist = os.path.exists(os.path.join(Module.getPath(), "..", "littlefs"))
    sysFSLFSComment = sysFSComponent.createCommentSymbol("SYS_FS_LFS_COMMENT", sysFSLFS)
    sysFSLFSComment.setVisible((isLFSExist == False) and sysFSLFS.getValue())
    sysFSLFSComment.setLabel("*** Warning!!! littlefs is not present, need to download littlefs repository using MCC content manager ***")
    sysFSLFSComment.setDependencies(sysFsLFSCommentShow, ["SYS_FS_LFS"])

    sysFSLFSReadonly = sysFSComponent.createBooleanSymbol("SYS_FS_LFS_READONLY", sysFSLFS)
    sysFSLFSReadonly.setLabel("Make LittleFS File System Read-only")
    sysFSLFSReadonly.setHelp(sys_fs_mcc_helpkeyword)
    sysFSLFSReadonly.setDefaultValue(False)
    sysFSLFSReadonly.setVisible(sysFSLFS.getValue())
    sysFSLFSReadonly.setDependencies(sysFsSymbolShow, ["SYS_FS_LFS"])

    sysFSLFSSize = sysFSComponent.createIntegerSymbol("SYS_FS_LFS_SIZE", sysFSLFS)
    sysFSLFSSize.setLabel("Size Of LFS image (in KB)")
    sysFSLFSSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSLFSSize.setDefaultValue(64)
    sysFSLFSSize.setVisible(sysFSLFS.getValue())
    sysFSLFSSize.setDependencies(sysFsSymbolShow, ["SYS_FS_LFS"])

    sysFSLFSBlockSize = sysFSComponent.createIntegerSymbol("SYS_FS_LFS_BLOCK_SIZE", sysFSLFS)
    sysFSLFSBlockSize.setLabel("LFS Block Size")
    sysFSLFSBlockSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSLFSBlockSize.setDefaultValue(2048)
    sysFSLFSBlockSize.setMin(512)
    sysFSLFSBlockSize.setVisible(sysFSLFS.getValue())
    sysFSLFSBlockSize.setDependencies(sysFsSymbolShow, ["SYS_FS_LFS"])

    symOptionsLFS = sysFSComponent.createSettingSymbol("SYM_OPTIONS_LFS", None)
    symOptionsLFS.setCategory("C32")
    symOptionsLFS.setKey("appendMe")
    symOptionsLFS.setValue("-std=c99 -Wno-format")
    symOptionsLFS.setAppend(True, " ")
    symOptionsLFS.setEnabled(sysFSLFS.getValue())
    symOptionsLFS.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    preProcMacrosLFS = sysFSComponent.createSettingSymbol("PRE_PROC_MACROS_LFS", None)
    preProcMacrosLFS.setCategory("C32")
    preProcMacrosLFS.setKey("preprocessor-macros")
    preProcMacrosLFS.setValue("LFS_READONLY")
    preProcMacrosLFS.setAppend(True, ";")
    preProcMacrosLFS.setEnabled(sysFSLFSReadonly.getValue())
    preProcMacrosLFS.setDependencies(sysFsFileGen, ["SYS_FS_LFS_READONLY"])

    global isFileXExist
    filexSourcePath = os.path.join("..", "filex")
    isFileXExist = os.path.exists(os.path.join(Module.getPath(), filexSourcePath))
    sysFSFILEX = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX", sysFSMenu)
    sysFSFILEX.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEX.setLabel("FileX File System")
    sysFSFILEX.setDefaultValue(False)

    sysFSFILEXComment = sysFSComponent.createCommentSymbol("SYS_FS_FILEX_COMMENT", sysFSFILEX)
    sysFSFILEXComment.setVisible((isFileXExist == False) and sysFSFILEX.getValue())
    sysFSFILEXComment.setLabel("*** Warning!!! filex is not present, need to download filex repository using MCC content manager ***")
    sysFSFILEXComment.setDependencies(sysFsFileXCommentShow, ["SYS_FS_FILEX"])

    sysFSFILEXReadonly = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_READONLY", sysFSFILEX)
    sysFSFILEXReadonly.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXReadonly.setLabel("Make FileX File System Read-only")
    sysFSFILEXReadonly.setDefaultValue(False)
    sysFSFILEXReadonly.setVisible(sysFSFILEX.getValue())
    sysFSFILEXReadonly.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXNameLen = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_MAX_LONG_NAME_LEN", sysFSFILEX)
    sysFSFILEXNameLen.setLabel("Maximum size of long file name")
    sysFSFILEXNameLen.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXNameLen.setDefaultValue(256)
    sysFSFILEXNameLen.setMin(13)
    sysFSFILEXNameLen.setMax(256)
    sysFSFILEXNameLen.setVisible(sysFSFILEX.getValue())
    sysFSFILEXNameLen.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXMxSecCache = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_MAX_SECTOR_CACHE", sysFSFILEX)
    sysFSFILEXMxSecCache.setLabel("Maximum logical sector cache")
    sysFSFILEXMxSecCache.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXMxSecCache.setDefaultValue(256)
    sysFSFILEXMxSecCache.setMin(2)
    sysFSFILEXMxSecCache.setVisible(sysFSFILEX.getValue())
    sysFSFILEXMxSecCache.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXFatMapSize = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_FAT_MAP_SIZE", sysFSFILEX)
    sysFSFILEXFatMapSize.setLabel("FAT sector bit map size")
    sysFSFILEXFatMapSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXFatMapSize.setDefaultValue(128)
    sysFSFILEXFatMapSize.setMin(1)
    sysFSFILEXFatMapSize.setVisible(sysFSFILEX.getValue())
    sysFSFILEXFatMapSize.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXMaxFatCache = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_MAX_FAT_CACHE", sysFSFILEX)
    sysFSFILEXMaxFatCache.setLabel("Number of entries in the FAT cache")
    sysFSFILEXMaxFatCache.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXMaxFatCache.setDefaultValue(16)
    sysFSFILEXMaxFatCache.setMin(8)
    sysFSFILEXMaxFatCache.setVisible(sysFSFILEX.getValue())
    sysFSFILEXMaxFatCache.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXUpdateRateSec = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_UPDATE_RATE_IN_SECONDS", sysFSFILEX)
    sysFSFILEXUpdateRateSec.setLabel("FileX update rate in seconds")
    sysFSFILEXUpdateRateSec.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXUpdateRateSec.setDefaultValue(10)
    sysFSFILEXUpdateRateSec.setVisible(sysFSFILEX.getValue())
    sysFSFILEXUpdateRateSec.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXUpdateRateTick = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_UPDATE_RATE_IN_TICKS", sysFSFILEX)
    sysFSFILEXUpdateRateTick.setLabel("FileX update rate in ticks")
    sysFSFILEXUpdateRateTick.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXUpdateRateTick.setDefaultValue(1000)
    sysFSFILEXUpdateRateTick.setVisible(sysFSFILEX.getValue())
    sysFSFILEXUpdateRateTick.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXNoTimer = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_NO_TIMER", sysFSFILEX)
    sysFSFILEXNoTimer.setLabel("FileX without timer")
    sysFSFILEXNoTimer.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXNoTimer.setVisible(sysFSFILEX.getValue())
    sysFSFILEXNoTimer.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXNoUpdateOpenFile = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DONT_UPDATE_OPEN_FILES", sysFSFILEX)
    sysFSFILEXNoUpdateOpenFile.setLabel("FileX don't update open files")
    sysFSFILEXNoUpdateOpenFile.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXNoUpdateOpenFile.setVisible(sysFSFILEX.getValue())
    sysFSFILEXNoUpdateOpenFile.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableSearchCache = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_MEDIA_DISABLE_SEARCH_CACHE", sysFSFILEX)
    sysFSFILEXDisableSearchCache.setLabel("Disable file search cache optimization")
    sysFSFILEXDisableSearchCache.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableSearchCache.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableSearchCache.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableReadCache = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_DISABLE_DIRECT_DATA_READ_CACHE", sysFSFILEX)
    sysFSFILEXDisableReadCache.setLabel("Disable direct read sector update of cache")
    sysFSFILEXDisableReadCache.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableReadCache.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableReadCache.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableMediaStat = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_MEDIA_STATISTICS_DISABLE", sysFSFILEX)
    sysFSFILEXDisableMediaStat.setLabel("Disable media statistics")
    sysFSFILEXDisableMediaStat.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableMediaStat.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableMediaStat.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXEnableSingleFile = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_SINGLE_OPEN_LEGACY", sysFSFILEX)
    sysFSFILEXEnableSingleFile.setLabel("Enable single open file legacy logic")
    sysFSFILEXEnableSingleFile.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXEnableSingleFile.setVisible(sysFSFILEX.getValue())
    sysFSFILEXEnableSingleFile.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXRenamePath = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_RENAME_PATH_INHERIT", sysFSFILEX)
    sysFSFILEXRenamePath.setLabel("Renaming inherits path information")
    sysFSFILEXRenamePath.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXRenamePath.setVisible(sysFSFILEX.getValue())
    sysFSFILEXRenamePath.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXNoLocalPath = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_NO_LOCAL_PATH", sysFSFILEX)
    sysFSFILEXNoLocalPath.setLabel("Disable local path logic")
    sysFSFILEXNoLocalPath.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXNoLocalPath.setVisible(sysFSFILEX.getValue())
    sysFSFILEXNoLocalPath.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXEnableExFAT = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_ENABLE_EXFAT", sysFSFILEX)
    sysFSFILEXEnableExFAT.setLabel("Enable exFAT file system")
    sysFSFILEXEnableExFAT.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXEnableExFAT.setVisible(sysFSFILEX.getValue())
    sysFSFILEXEnableExFAT.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXExFatMaxCacheSize = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FX_EXFAT_MAX_CACHE_SIZE", sysFSFILEX)
    sysFSFILEXExFatMaxCacheSize.setLabel("ExFAT bitmap cache size")
    sysFSFILEXExFatMaxCacheSize.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXExFatMaxCacheSize.setDefaultValue(512)
    sysFSFILEXExFatMaxCacheSize.setMin(512)
    sysFSFILEXExFatMaxCacheSize.setMax(4096)
    sysFSFILEXExFatMaxCacheSize.setVisible(sysFSFILEX.getValue())
    sysFSFILEXExFatMaxCacheSize.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXSingleThread = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_SINGLE_THREAD", sysFSFILEX)
    sysFSFILEXSingleThread.setLabel("Enable filex single Thread")
    sysFSFILEXSingleThread.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXSingleThread.setVisible(sysFSFILEX.getValue())
    sysFSFILEXSingleThread.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXStandaloneEnable = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_STANDALONE_ENABLE", sysFSFILEX)
    sysFSFILEXStandaloneEnable.setLabel("Enable filex standalone mode")
    sysFSFILEXStandaloneEnable.setDefaultValue(True)
    sysFSFILEXStandaloneEnable.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXStandaloneEnable.setVisible(sysFSFILEX.getValue())
    sysFSFILEXStandaloneEnable.setDependencies(updateFileXmode, ["SYS_FS_FILEX", "HarmonyCore.SELECT_RTOS"])

    sysFSFILEXFaultToleData = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_FAULT_TOLERANT_DATA", sysFSFILEX)
    sysFSFILEXFaultToleData.setLabel("Data sector write requests flushed immediately")
    sysFSFILEXFaultToleData.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXFaultToleData.setVisible(sysFSFILEX.getValue())
    sysFSFILEXFaultToleData.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXFaultTolerant = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_FAULT_TOLERANT", sysFSFILEX)
    sysFSFILEXFaultTolerant.setLabel("System sector write requests flushed immediately")
    sysFSFILEXFaultTolerant.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXFaultTolerant.setVisible(sysFSFILEX.getValue())
    sysFSFILEXFaultTolerant.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDriverUse64bitLBA = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DRIVER_USE_64BIT_LBA", sysFSFILEX)
    sysFSFILEXDriverUse64bitLBA.setLabel("Enable 64-bits sector address")
    sysFSFILEXDriverUse64bitLBA.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDriverUse64bitLBA.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDriverUse64bitLBA.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXEnableFaultTolerant = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_ENABLE_FAULT_TOLERANT", sysFSFILEX)
    sysFSFILEXEnableFaultTolerant.setLabel("Enable filex fault tolerant")
    sysFSFILEXEnableFaultTolerant.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXEnableFaultTolerant.setVisible(sysFSFILEX.getValue())
    sysFSFILEXEnableFaultTolerant.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXFaultToleBootIndex = sysFSComponent.createIntegerSymbol("SYS_FS_FILEX_FAULT_TOLERANT_BOOT_INDEX", sysFSFILEX)
    sysFSFILEXFaultToleBootIndex.setLabel("FileX fault tolerant boot index")
    sysFSFILEXFaultToleBootIndex.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXFaultToleBootIndex.setDefaultValue(116)
    sysFSFILEXFaultToleBootIndex.setVisible(sysFSFILEX.getValue())
    sysFSFILEXFaultToleBootIndex.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableErrCheck = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_ERROR_CHECKING", sysFSFILEX)
    sysFSFILEXDisableErrCheck.setLabel("Disable filex error checking")
    sysFSFILEXDisableErrCheck.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableErrCheck.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableErrCheck.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableCache = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_CACHE", sysFSFILEX)
    sysFSFILEXDisableCache.setLabel("Disable filex cache")
    sysFSFILEXDisableCache.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableCache.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableCache.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableFileClose = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_FILE_CLOSE", sysFSFILEX)
    sysFSFILEXDisableFileClose.setLabel("Disable filex file close")
    sysFSFILEXDisableFileClose.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableFileClose.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableFileClose.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableFastOpen = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_FAST_OPEN", sysFSFILEX)
    sysFSFILEXDisableFastOpen.setLabel("Disable filex fast open")
    sysFSFILEXDisableFastOpen.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableFastOpen.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableFastOpen.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisablememPro = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_FORCE_MEMORY_OPERATION", sysFSFILEX)
    sysFSFILEXDisablememPro.setLabel("Disable force memory operations")
    sysFSFILEXDisablememPro.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisablememPro.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisablememPro.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableBuildOpt = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_BUILD_OPTIONS", sysFSFILEX)
    sysFSFILEXDisableBuildOpt.setLabel("Disable build options")
    sysFSFILEXDisableBuildOpt.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableBuildOpt.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableBuildOpt.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableOneLineFunc = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_ONE_LINE_FUNCTION", sysFSFILEX)
    sysFSFILEXDisableOneLineFunc.setLabel("Disable one line function")
    sysFSFILEXDisableOneLineFunc.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableOneLineFunc.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableOneLineFunc.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableFatEntryRef = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DIABLE_FAT_ENTRY_REFRESH", sysFSFILEX)
    sysFSFILEXDisableFatEntryRef.setLabel("Disable FAT entry refresh")
    sysFSFILEXDisableFatEntryRef.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableFatEntryRef.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableFatEntryRef.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSFILEXDisableConsecutiveDetect = sysFSComponent.createBooleanSymbol("SYS_FS_FILEX_FX_DISABLE_CONSECUTIVE_DETECT", sysFSFILEX)
    sysFSFILEXDisableConsecutiveDetect.setLabel("Disable consecutive detect")
    sysFSFILEXDisableConsecutiveDetect.setHelp(sys_fs_mcc_helpkeyword)
    sysFSFILEXDisableConsecutiveDetect.setVisible(sysFSFILEX.getValue())
    sysFSFILEXDisableConsecutiveDetect.setDependencies(sysFsSymbolShow, ["SYS_FS_FILEX"])

    sysFSLFNEnable = sysFSComponent.createBooleanSymbol("SYS_FS_LFN_ENABLE", sysFSMenu)
    sysFSLFNEnable.setLabel("Enable Long File Name Support")
    sysFSLFNEnable.setHelp(sys_fs_mcc_helpkeyword)
    sysFSLFNEnable.setDefaultValue(True)
    sysFSLFNEnable.setReadOnly(sysFSFatExFAT.getValue())
    sysFSLFNEnable.setDependencies(sysFSLFNSet, ["SYS_FS_FAT_EXFAT_ENABLE"])

    sysFSNameLen = sysFSComponent.createIntegerSymbol("SYS_FS_FILE_NAME_LEN", sysFSMenu)
    sysFSNameLen.setLabel("File name length in bytes")
    sysFSNameLen.setHelp(sys_fs_mcc_helpkeyword)
    sysFSNameLen.setDefaultValue(255)
    sysFSNameLen.setMin(12)
    sysFSNameLen.setMax(255)

    sysFSPathLen = sysFSComponent.createIntegerSymbol("SYS_FS_CWD_STRING_LEN", sysFSMenu)
    sysFSPathLen.setLabel("Current working directory scratch buffer length in bytes")
    sysFSPathLen.setHelp(sys_fs_mcc_helpkeyword)
    sysFSPathLen.setDefaultValue(1024)
    sysFSPathLen.setMin(1)
    sysFSPathLen.setMax(1024)

    createAlignedBufferSymbols = False

    # Check if Cache is present on the device
    if (Database.getSymbolValue("core", "DATA_CACHE_ENABLE") != None):
        if (Database.getSymbolValue("core", "CoreArchitecture") != "CORTEX-M4"):
            createAlignedBufferSymbols = True

    if (createAlignedBufferSymbols == True):
        sysFSFatAlignedBufferEnableDesc = "File system will use this aligned buffer to submit the request to Media if the input buffer for the read/Write operations is not aligned to Cache Line Size. \
        If the underlying media driver uses DMA and device has cache enabled the buffer submitted to the driver has to be aligned to cache line size as the drivers will perform Cache Maintenance operations on the buffer. \
        When file system aligned buffer will be used then the total number of sectors/nBytes to be read/written will be divided by the aligned buffer size and will be sent to drivers in iterations. As the total sectors/nbytes are now divided into chunks it may effect the overall throughput. \
        Increasing the length of the buffer will increase the throughput but consume more RAM memory."

        sysFSAlignedBufferEnable = sysFSComponent.createBooleanSymbol("SYS_FS_ALIGNED_BUFFER_ENABLE", sysFSMenu)
        sysFSAlignedBufferEnable.setLabel("Enable Cache Line Aligned Buffer for Cache Management")
        sysFSAlignedBufferEnable.setHelp(sys_fs_mcc_helpkeyword)
        sysFSAlignedBufferEnable.setDefaultValue(True)
        sysFSAlignedBufferEnable.setDescription(sysFSFatAlignedBufferEnableDesc)
        sysFSAlignedBufferEnable.setVisible(True)
        sysFSAlignedBufferEnable.setDependencies(sysFsAlignedBufferShow, ["SYS_FS_FAT", "SYS_FS_MPFS", "SYS_FS_LFS", "SYS_FS_FILEX"])

        sysFSAlignedBufferLen = sysFSComponent.createIntegerSymbol("SYS_FS_ALIGNED_BUFFER_LEN", sysFSAlignedBufferEnable)
        sysFSAlignedBufferLen.setLabel("Aligned Buffer Length in Multiple of 512 Bytes")
        sysFSAlignedBufferLen.setHelp(sys_fs_mcc_helpkeyword)
        sysFSAlignedBufferLen.setDefaultValue(512)
        sysFSAlignedBufferLen.setMin(512)
        sysFSAlignedBufferLen.setVisible((sysFSAlignedBufferEnable.getValue() == True) and ((sysFSFat.getValue() == True) or (sysFSFILEX.getValue() == True)))
        sysFSAlignedBufferLen.setDependencies(sysFsAlignedBufferLenSymbolShow, ["SYS_FS_ALIGNED_BUFFER_ENABLE", "SYS_FS_FAT", "SYS_FS_FILEX"])

############################################Generate Files#################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sysFSHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_HEADER", None)
    sysFSHeaderFile.setSourcePath("/system/fs/templates/sys_fs.h.ftl")
    sysFSHeaderFile.setOutputName("sys_fs.h")
    sysFSHeaderFile.setDestPath("/system/fs/")
    sysFSHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSHeaderFile.setMarkup(True)
    sysFSHeaderFile.setOverwrite(True)
    sysFSHeaderFile.setType("HEADER")

    sysFSLocalHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_LOCAL_HEADER", None)
    sysFSLocalHeaderFile.setSourcePath("/system/fs/src/sys_fs_local.h.ftl")
    sysFSLocalHeaderFile.setOutputName("sys_fs_local.h")
    sysFSLocalHeaderFile.setDestPath("/system/fs/src/")
    sysFSLocalHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSLocalHeaderFile.setMarkup(True)
    sysFSLocalHeaderFile.setOverwrite(True)
    sysFSLocalHeaderFile.setType("HEADER")

    sysFSMedManHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_MEDIA_MANAGER_HEADER", None)
    sysFSMedManHeaderFile.setSourcePath("/system/fs/sys_fs_media_manager.h.ftl")
    sysFSMedManHeaderFile.setOutputName("sys_fs_media_manager.h")
    sysFSMedManHeaderFile.setDestPath("/system/fs/")
    sysFSMedManHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSMedManHeaderFile.setType("HEADER")
    sysFSMedManHeaderFile.setMarkup(True)

    sysFSMedLocalHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_MEDIA_MANAGER_LOCAL_HEADER", None)
    sysFSMedLocalHeaderFile.setSourcePath("/system/fs/src/sys_fs_media_manager_local.h")
    sysFSMedLocalHeaderFile.setOutputName("sys_fs_media_manager_local.h")
    sysFSMedLocalHeaderFile.setDestPath("/system/fs/src/")
    sysFSMedLocalHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSMedLocalHeaderFile.setType("HEADER")

    sysFSffIntHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_FAT_INTERFACE_HEADER", None)
    sysFSffIntHeaderFile.setSourcePath("/system/fs/templates/sys_fs_fat_interface.h.ftl")
    sysFSffIntHeaderFile.setOutputName("sys_fs_fat_interface.h")
    sysFSffIntHeaderFile.setDestPath("/system/fs/")
    sysFSffIntHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSffIntHeaderFile.setType("HEADER")
    sysFSffIntHeaderFile.setMarkup(True)
    sysFSffIntHeaderFile.setOverwrite(True)
    sysFSffIntHeaderFile.setEnabled(sysFSFat.getValue())
    sysFSffIntHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSffHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_FAT_HEADER", None)
    sysFSffHeaderFile.setSourcePath("/system/fs/fat_fs/file_system/ff.h.ftl")
    sysFSffHeaderFile.setOutputName("ff.h")
    sysFSffHeaderFile.setDestPath("/system/fs/fat_fs/file_system")
    sysFSffHeaderFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/file_system")
    sysFSffHeaderFile.setType("HEADER")
    sysFSffHeaderFile.setMarkup(True)
    sysFSffHeaderFile.setOverwrite(True)
    sysFSffHeaderFile.setEnabled(sysFSFat.getValue())
    sysFSffHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSFFConfHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_FAT_CONF_HEADER", None)
    sysFSFFConfHeaderFile.setSourcePath("/system/fs/fat_fs/file_system/ffconf.h.ftl")
    sysFSFFConfHeaderFile.setOutputName("ffconf.h")
    sysFSFFConfHeaderFile.setDestPath("/system/fs/fat_fs/file_system/")
    sysFSFFConfHeaderFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/file_system/")
    sysFSFFConfHeaderFile.setType("HEADER")
    sysFSFFConfHeaderFile.setEnabled(sysFSFat.getValue())
    sysFSFFConfHeaderFile.setMarkup(True)
    sysFSFFConfHeaderFile.setOverwrite(True)
    sysFSFFConfHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSDiskIOHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_DISKIO_HEADER", None)
    sysFSDiskIOHeaderFile.setSourcePath("/system/fs/fat_fs/hardware_access/diskio.h")
    sysFSDiskIOHeaderFile.setOutputName("diskio.h")
    sysFSDiskIOHeaderFile.setDestPath("/system/fs/fat_fs/hardware_access/")
    sysFSDiskIOHeaderFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/hardware_access/")
    sysFSDiskIOHeaderFile.setType("HEADER")
    sysFSDiskIOHeaderFile.setEnabled(sysFSFat.getValue())
    sysFSDiskIOHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSMPFSHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_MPFS_HEADER", None)
    sysFSMPFSHeaderFile.setSourcePath("/system/fs/mpfs/mpfs.h")
    sysFSMPFSHeaderFile.setOutputName("mpfs.h")
    sysFSMPFSHeaderFile.setDestPath("/system/fs/mpfs/")
    sysFSMPFSHeaderFile.setProjectPath("config/" + configName + "/system/fs/mpfs/")
    sysFSMPFSHeaderFile.setEnabled(sysFSMpfs.getValue())
    sysFSMPFSHeaderFile.setType("HEADER")
    sysFSMPFSHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_MPFS"])

    sysFSMPFSLocHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_MPFS_LOCAL_HEADER", None)
    sysFSMPFSLocHeaderFile.setSourcePath("/system/fs/mpfs/src/mpfs_local.h.ftl")
    sysFSMPFSLocHeaderFile.setOutputName("mpfs_local.h")
    sysFSMPFSLocHeaderFile.setDestPath("/system/fs/mpfs/")
    sysFSMPFSLocHeaderFile.setProjectPath("config/" + configName + "/system/fs/mpfs/")
    sysFSMPFSLocHeaderFile.setEnabled(sysFSMpfs.getValue())
    sysFSMPFSLocHeaderFile.setType("HEADER")
    sysFSMPFSLocHeaderFile.setMarkup(True)
    sysFSMPFSLocHeaderFile.setOverwrite(True)
    sysFSMPFSLocHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_MPFS"])

    sysFSLFSIntHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_INTERFACE_HEADER", None)
    sysFSLFSIntHeaderFile.setSourcePath("/system/fs/templates/sys_fs_littlefs_interface.h.ftl")
    sysFSLFSIntHeaderFile.setOutputName("sys_fs_littlefs_interface.h")
    sysFSLFSIntHeaderFile.setDestPath("/system/fs/")
    sysFSLFSIntHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSLFSIntHeaderFile.setType("HEADER")
    sysFSLFSIntHeaderFile.setMarkup(True)
    sysFSLFSIntHeaderFile.setOverwrite(True)
    sysFSLFSIntHeaderFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSIntHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_HEADER", None)
    sysFSLFSHeaderFile.setSourcePath("../littlefs/lfs.h")
    sysFSLFSHeaderFile.setOutputName("lfs.h")
    sysFSLFSHeaderFile.setDestPath("/system/fs/littlefs/")
    sysFSLFSHeaderFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSHeaderFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSHeaderFile.setType("HEADER")
    sysFSLFSHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSBDHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_BDIO_HEADER", None)
    sysFSLFSBDHeaderFile.setSourcePath("/system/fs/littlefs/hardware_access/lfs_bdio.h")
    sysFSLFSBDHeaderFile.setOutputName("lfs_bdio.h")
    sysFSLFSBDHeaderFile.setDestPath("/system/fs/littlefs/")
    sysFSLFSBDHeaderFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSBDHeaderFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSBDHeaderFile.setType("HEADER")
    sysFSLFSBDHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSUTILHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_UTIL_HEADER", None)
    sysFSLFSUTILHeaderFile.setSourcePath("../littlefs/lfs_util.h")
    sysFSLFSUTILHeaderFile.setOutputName("lfs_util.h")
    sysFSLFSUTILHeaderFile.setDestPath("/system/fs/littlefs/")
    sysFSLFSUTILHeaderFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSUTILHeaderFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSUTILHeaderFile.setType("HEADER")
    sysFSLFSUTILHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSLicenseFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_LICENSE", None)
    sysFSLFSLicenseFile.setSourcePath("../littlefs/LICENSE.md")
    sysFSLFSLicenseFile.setOutputName("LICENSE.md")
    sysFSLFSLicenseFile.setDestPath("/system/fs/littlefs/")
    sysFSLFSLicenseFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSLicenseFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSLicenseFile.setType("SOURCE")
    sysFSLFSLicenseFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSFILEXIntHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_FILEX_INTERFACE_HEADER", None)
    sysFSFILEXIntHeaderFile.setSourcePath("/system/fs/templates/sys_fs_filex_interface.h.ftl")
    sysFSFILEXIntHeaderFile.setOutputName("sys_fs_filex_interface.h")
    sysFSFILEXIntHeaderFile.setDestPath("/system/fs/")
    sysFSFILEXIntHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSFILEXIntHeaderFile.setType("HEADER")
    sysFSFILEXIntHeaderFile.setMarkup(True)
    sysFSFILEXIntHeaderFile.setOverwrite(True)
    sysFSFILEXIntHeaderFile.setEnabled(sysFSFILEX.getValue())
    sysFSFILEXIntHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

    sysFSFILEXIODRVHeaderFile = sysFSComponent.createFileSymbol("SYS_FS_FILEX_IO_DRV_HEADER", None)
    sysFSFILEXIODRVHeaderFile.setSourcePath("/system/fs/filex/hardware_access/filex_io_drv.h.ftl")
    sysFSFILEXIODRVHeaderFile.setOutputName("filex_io_drv.h")
    sysFSFILEXIODRVHeaderFile.setDestPath("/system/fs/filex/")
    sysFSFILEXIODRVHeaderFile.setProjectPath("config/" + configName + "/system/fs/filex/")
    sysFSFILEXIODRVHeaderFile.setEnabled(sysFSFILEX.getValue())
    sysFSFILEXIODRVHeaderFile.setType("HEADER")
    sysFSFILEXIODRVHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])
    sysFSFILEXIODRVHeaderFile.setMarkup(True)

    sysFSFILEXLicenseFile = sysFSComponent.createFileSymbol("SYS_FS_FILEX_LICENSE", None)
    sysFSFILEXLicenseFile.setSourcePath("../filex/LICENSE.txt")
    sysFSFILEXLicenseFile.setOutputName("LICENSE.txt")
    sysFSFILEXLicenseFile.setDestPath("/system/fs/filex/")
    sysFSFILEXLicenseFile.setProjectPath("config/" + configName + "/system/fs/filex/")
    sysFSFILEXLicenseFile.setEnabled(sysFSFILEX.getValue())
    sysFSFILEXLicenseFile.setType("SOURCE")
    sysFSFILEXLicenseFile.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

    sysFSSourceFile = sysFSComponent.createFileSymbol("SYS_FS_SOURCE", None)
    sysFSSourceFile.setSourcePath("/system/fs/src/sys_fs.c.ftl")
    sysFSSourceFile.setOutputName("sys_fs.c")
    sysFSSourceFile.setDestPath("/system/fs/src/")
    sysFSSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSSourceFile.setType("SOURCE")
    sysFSSourceFile.setMarkup(True)
    sysFSSourceFile.setOverwrite(True)

    sysFSMedManSourceFile = sysFSComponent.createFileSymbol("SYS_FS_MEDIA_MANAGER_SOURCE", None)
    sysFSMedManSourceFile.setSourcePath("/system/fs/src/sys_fs_media_manager.c.ftl")
    sysFSMedManSourceFile.setOutputName("sys_fs_media_manager.c")
    sysFSMedManSourceFile.setDestPath("/system/fs/src/")
    sysFSMedManSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSMedManSourceFile.setType("SOURCE")
    sysFSMedManSourceFile.setMarkup(True)
    sysFSMedManSourceFile.setOverwrite(True)

    sysFSffIntSourceFile = sysFSComponent.createFileSymbol("SYS_FS_FAT_INTERFACE_SOURCE", None)
    sysFSffIntSourceFile.setSourcePath("/system/fs/src/sys_fs_fat_interface.c.ftl")
    sysFSffIntSourceFile.setOutputName("sys_fs_fat_interface.c")
    sysFSffIntSourceFile.setDestPath("/system/fs/src/")
    sysFSffIntSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSffIntSourceFile.setType("SOURCE")
    sysFSffIntSourceFile.setMarkup(True)
    sysFSffIntSourceFile.setOverwrite(True)
    sysFSffIntSourceFile.setEnabled(sysFSFat.getValue())
    sysFSffIntSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSffSourceFile = sysFSComponent.createFileSymbol("SYS_FS_FAT_SOURCE", None)
    sysFSffSourceFile.setSourcePath("system/fs/fat_fs/file_system/ff.c")
    sysFSffSourceFile.setOutputName("ff.c")
    sysFSffSourceFile.setDestPath("system/fs/fat_fs/file_system/")
    sysFSffSourceFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/file_system/")
    sysFSffSourceFile.setType("SOURCE")
    sysFSffSourceFile.setEnabled(sysFSFat.getValue())
    sysFSffSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSUnicodeSourceFile = sysFSComponent.createFileSymbol("SYS_FS_FAT_UNICODE_SOURCE", None)
    sysFSUnicodeSourceFile.setSourcePath("system/fs/fat_fs/file_system/ffunicode.c")
    sysFSUnicodeSourceFile.setOutputName("ffunicode.c")
    sysFSUnicodeSourceFile.setDestPath("system/fs/fat_fs/file_system/")
    sysFSUnicodeSourceFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/file_system/")
    sysFSUnicodeSourceFile.setType("SOURCE")
    sysFSUnicodeSourceFile.setEnabled(sysFSFat.getValue())
    sysFSUnicodeSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSDiskIOFile = sysFSComponent.createFileSymbol("SYS_FS_DISKIO_SOURCE", None)
    sysFSDiskIOFile.setSourcePath("/system/fs/fat_fs/hardware_access/diskio.c.ftl")
    sysFSDiskIOFile.setOutputName("diskio.c")
    sysFSDiskIOFile.setDestPath("/system/fs/fat_fs/hardware_access/")
    sysFSDiskIOFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/hardware_access/")
    sysFSDiskIOFile.setType("SOURCE")
    sysFSDiskIOFile.setMarkup(True)
    sysFSDiskIOFile.setOverwrite(True)
    sysFSDiskIOFile.setEnabled(sysFSFat.getValue())
    sysFSDiskIOFile.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSMPFSSourceFile = sysFSComponent.createFileSymbol("SYS_FS_MPFS_SOURCE", None)
    sysFSMPFSSourceFile.setSourcePath("/system/fs/mpfs/src/mpfs.c.ftl")
    sysFSMPFSSourceFile.setOutputName("mpfs.c")
    sysFSMPFSSourceFile.setDestPath("/system/fs/mpfs/")
    sysFSMPFSSourceFile.setProjectPath("config/" + configName + "/system/fs/mpfs/")
    sysFSMPFSSourceFile.setEnabled(sysFSMpfs.getValue())
    sysFSMPFSSourceFile.setType("SOURCE")
    sysFSMPFSSourceFile.setMarkup(True)
    sysFSMPFSSourceFile.setOverwrite(True)
    sysFSMPFSSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_MPFS"])

    sysFSLFSIntSourceFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_INTERFACE_SOURCE", None)
    sysFSLFSIntSourceFile.setSourcePath("/system/fs/src/sys_fs_littlefs_interface.c.ftl")
    sysFSLFSIntSourceFile.setOutputName("sys_fs_littlefs_interface.c")
    sysFSLFSIntSourceFile.setDestPath("/system/fs/src/")
    sysFSLFSIntSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSLFSIntSourceFile.setType("SOURCE")
    sysFSLFSIntSourceFile.setMarkup(True)
    sysFSLFSIntSourceFile.setOverwrite(True)
    sysFSLFSIntSourceFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSIntSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSSourceFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_SOURCE", None)
    sysFSLFSSourceFile.setSourcePath("../littlefs/lfs.c")
    sysFSLFSSourceFile.setOutputName("lfs.c")
    sysFSLFSSourceFile.setDestPath("system/fs/littlefs/")
    sysFSLFSSourceFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSSourceFile.setType("SOURCE")
    sysFSLFSSourceFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSBDSourceFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_BDIO_SOURCE", None)
    sysFSLFSBDSourceFile.setSourcePath("/system/fs/littlefs/hardware_access/lfs_bdio.c.ftl")
    sysFSLFSBDSourceFile.setOutputName("lfs_bdio.c")
    sysFSLFSBDSourceFile.setDestPath("/system/fs/littlefs/")
    sysFSLFSBDSourceFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSBDSourceFile.setType("SOURCE")
    sysFSLFSBDSourceFile.setMarkup(True)
    sysFSLFSBDSourceFile.setOverwrite(True)
    sysFSLFSBDSourceFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSBDSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSLFSUTILSourceFile = sysFSComponent.createFileSymbol("SYS_FS_LFS_UTIL_SOURCE", None)
    sysFSLFSUTILSourceFile.setSourcePath("../littlefs/lfs_util.c")
    sysFSLFSUTILSourceFile.setOutputName("lfs_util.c")
    sysFSLFSUTILSourceFile.setDestPath("system/fs/littlefs/")
    sysFSLFSUTILSourceFile.setProjectPath("config/" + configName + "/system/fs/littlefs/")
    sysFSLFSUTILSourceFile.setType("SOURCE")
    sysFSLFSUTILSourceFile.setEnabled(sysFSLFS.getValue())
    sysFSLFSUTILSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    sysFSFILEXIntSourceFile = sysFSComponent.createFileSymbol("SYS_FS_FILEX_INTERFACE_SOURCE", None)
    sysFSFILEXIntSourceFile.setSourcePath("/system/fs/src/sys_fs_filex_interface.c.ftl")
    sysFSFILEXIntSourceFile.setOutputName("sys_fs_filex_interface.c")
    sysFSFILEXIntSourceFile.setDestPath("/system/fs/src/")
    sysFSFILEXIntSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSFILEXIntSourceFile.setType("SOURCE")
    sysFSFILEXIntSourceFile.setMarkup(True)
    sysFSFILEXIntSourceFile.setOverwrite(True)
    sysFSFILEXIntSourceFile.setEnabled(sysFSFILEX.getValue())
    sysFSFILEXIntSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

    sysFSFILEXIODRVSourceFile = sysFSComponent.createFileSymbol("SYS_FS_FILEX_IO_DRV_SOURCE", None)
    sysFSFILEXIODRVSourceFile.setSourcePath("/system/fs/filex/hardware_access/filex_io_drv.c.ftl")
    sysFSFILEXIODRVSourceFile.setOutputName("filex_io_drv.c")
    sysFSFILEXIODRVSourceFile.setDestPath("/system/fs/filex/")
    sysFSFILEXIODRVSourceFile.setProjectPath("config/" + configName + "/system/fs/filex/")
    sysFSFILEXIODRVSourceFile.setType("SOURCE")
    sysFSFILEXIODRVSourceFile.setMarkup(True)
    sysFSFILEXIODRVSourceFile.setOverwrite(True)
    sysFSFILEXIODRVSourceFile.setEnabled(sysFSFILEX.getValue())
    sysFSFILEXIODRVSourceFile.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

    sysFSSystemInitdataFile = sysFSComponent.createFileSymbol("sysFSInitDataFile", None)
    sysFSSystemInitdataFile.setType("STRING")
    sysFSSystemInitdataFile.setOutputName("core.LIST_SYSTEM_INIT_C_LIBRARY_INITIALIZATION_DATA")
    sysFSSystemInitdataFile.setSourcePath("/system/fs/templates/system/initialization_data.c.ftl")
    sysFSSystemInitdataFile.setMarkup(True)

    sysFSSystemInitFile = sysFSComponent.createFileSymbol("sysFSInitFile", None)
    sysFSSystemInitFile.setType("STRING")
    sysFSSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_MIDDLEWARE")
    sysFSSystemInitFile.setSourcePath("/system/fs/templates/system/initialization.c.ftl")
    sysFSSystemInitFile.setMarkup(True)

    sysFSConfigFile = sysFSComponent.createFileSymbol("sysFSConfigFile", None)
    sysFSConfigFile.setType("STRING")
    sysFSConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    sysFSConfigFile.setSourcePath("/system/fs/templates/system/configuration.h.ftl")
    sysFSConfigFile.setMarkup(True)

    sysFSConfig2File = sysFSComponent.createFileSymbol("sysFSConfig2File", None)
    sysFSConfig2File.setType("STRING")
    sysFSConfig2File.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    sysFSConfig2File.setSourcePath("/system/fs/templates/system/sys_fs_idx.h.ftl")
    sysFSConfig2File.setMarkup(True)

    sysFSSystemDefFile = sysFSComponent.createFileSymbol("sysFSSystemDefFile", None)
    sysFSSystemDefFile.setType("STRING")
    sysFSSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sysFSSystemDefFile.setSourcePath("/system/fs/templates/system/definitions.h.ftl")
    sysFSSystemDefFile.setMarkup(True)

    sysFSSystemTaskFile = sysFSComponent.createFileSymbol("sysFSSystemTaskFile", None)
    sysFSSystemTaskFile.setType("STRING")
    sysFSSystemTaskFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    sysFSSystemTaskFile.setSourcePath("/system/fs/templates/system/tasks.c.ftl")
    sysFSSystemTaskFile.setMarkup(True)

    sysFSSystemRtosTaskFile = sysFSComponent.createFileSymbol("sysFSSystemRtosTaskFile", None)
    sysFSSystemRtosTaskFile.setType("STRING")
    sysFSSystemRtosTaskFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    sysFSSystemRtosTaskFile.setSourcePath("/system/fs/templates/system/rtos_tasks.c.ftl")
    sysFSSystemRtosTaskFile.setMarkup(True)
    sysFSSystemRtosTaskFile.setEnabled((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"))
    sysFSSystemRtosTaskFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS"])

    sysFSFatIncludePath = sysFSComponent.createSettingSymbol("SYS_FS_FAT_XC32_INCLUDE_PATH", None)
    sysFSFatIncludePath.setCategory("C32")
    sysFSFatIncludePath.setKey("extra-include-directories")
    sysFSFatIncludePath.setValue(";../src/config/" + configName + "/system/fs/fat_fs/file_system" + ";../src/config/" + configName + "/system/fs/fat_fs/hardware_access")
    sysFSFatIncludePath.setAppend(True, ";")
    sysFSFatIncludePath.setEnabled(sysFSFat.getValue())
    sysFSFatIncludePath.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSFatXc32cppIncludePath = sysFSComponent.createSettingSymbol("SYS_FS_FAT_XC32CPP_INCLUDE_PATH", None)
    sysFSFatXc32cppIncludePath.setCategory("C32CPP")
    sysFSFatXc32cppIncludePath.setKey("extra-include-directories")
    sysFSFatXc32cppIncludePath.setValue(sysFSFatIncludePath.getValue())
    sysFSFatXc32cppIncludePath.setAppend(True, ";")
    sysFSFatXc32cppIncludePath.setEnabled(sysFSFat.getValue())
    sysFSFatXc32cppIncludePath.setDependencies(sysFsFileGen, ["SYS_FS_FAT"])

    sysFSLFSIncludePath = sysFSComponent.createSettingSymbol("SYS_FS_LFS_XC32_INCLUDE_PATH", None)
    sysFSLFSIncludePath.setCategory("C32")
    sysFSLFSIncludePath.setKey("extra-include-directories")
    sysFSLFSIncludePath.setValue(";../src/config/" + configName + "/system/fs/littlefs")
    sysFSLFSIncludePath.setAppend(True, ";")
    sysFSLFSIncludePath.setEnabled(sysFSLFS.getValue())
    sysFSLFSIncludePath.setDependencies(sysFsFileGen, ["SYS_FS_LFS"])

    filexDestPath = "../../third_party/azure_rtos/filex"
    if isFileXExist == True:
        AddFileXFiles(sysFSComponent, filexSourcePath + "/common/src/", filexDestPath + "/common/src/")
        AddFileXFiles(sysFSComponent, filexSourcePath + "/common/inc/", filexDestPath + "/common/inc/")
        AddFileXFiles(sysFSComponent, filexSourcePath + "/ports/generic/inc/", filexDestPath + "/ports/generic/inc/")

    filexUserHeaderFile = sysFSComponent.createFileSymbol("FILEX_FX_USER_H", None)
    filexUserHeaderFile.setSourcePath("/system/fs/filex/fx_user.h.ftl")
    filexUserHeaderFile.setOutputName("fx_user.h")
    filexUserHeaderFile.setMarkup(True)
    filexUserHeaderFile.setOverwrite(True)
    filexUserHeaderFile.setDestPath("/system/fs/filex/")
    filexUserHeaderFile.setProjectPath("config/" + configName + "/system/fs/filex/")
    filexUserHeaderFile.setType("HEADER")
    filexUserHeaderFile.setEnabled(sysFSFILEX.getValue())
    filexUserHeaderFile.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

    filexPreProcMacros = sysFSComponent.createSettingSymbol("FILEX_PRE_PROC_MACROS", None)
    filexPreProcMacros.setCategory("C32")
    filexPreProcMacros.setKey("preprocessor-macros")
    filexPreProcMacros.setValue("FX_INCLUDE_USER_DEFINE_FILE")
    filexPreProcMacros.setAppend(True, ";")
    filexPreProcMacros.setEnabled(sysFSFILEX.getValue())
    filexPreProcMacros.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

    sysFSFILEXIncludePath = sysFSComponent.createSettingSymbol("SYS_FS_FILEX_XC32_INCLUDE_PATH", None)
    sysFSFILEXIncludePath.setCategory("C32")
    sysFSFILEXIncludePath.setKey("extra-include-directories")
    sysFSFILEXIncludePath.setValue(";../src/config/" + configName + "/system/fs/filex;../src/third_party/azure_rtos/filex/common/inc;../src/third_party/azure_rtos/filex/ports/generic/inc")
    sysFSFILEXIncludePath.setAppend(True, ";")
    sysFSFILEXIncludePath.setEnabled(sysFSFILEX.getValue())
    sysFSFILEXIncludePath.setDependencies(sysFsFileGen, ["SYS_FS_FILEX"])

###########################################################################################################
deviceNames = { 'SYS_FS_MEDIA_TYPE_NVM' : '/dev/nvma',
    'SYS_FS_MEDIA_TYPE_MSD' : '/dev/sda',
    'SYS_FS_MEDIA_TYPE_SD_CARD' : '/dev/mmcblka',
    'SYS_FS_MEDIA_TYPE_RAM' : '/dev/rama',
    'SYS_FS_MEDIA_TYPE_SPIFLASH' : '/dev/mtda'
    }

def sysFsFileGen(symbol, event):
    symbol.setEnabled(event["value"])

def sysFsSymbolShow(symbol, event):
    symbol.setVisible(event["value"])

def sysFsFileXCommentShow(symbol, event):
    global isFileXExist
    symbol.setVisible((isFileXExist == False) and event["value"])

def sysFsLFSCommentShow(symbol, event):
    global isLFSExist
    symbol.setVisible((isLFSExist == False) and event["value"])

def updateFileXmode(symbol, event):
    component = symbol.getComponent()
    symbol.setVisible(component.getSymbolValue("SYS_FS_FILEX"))
    symbol.setValue((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "ThreadX"))

def sysFsAlignedBufferLenSymbolShow(symbol, event):
    component = symbol.getComponent()

    fatEnabled = component.getSymbolValue("SYS_FS_FAT")
    filexEnabled = component.getSymbolValue("SYS_FS_FILEX")

    alignedBufferEnabled = component.getSymbolValue("SYS_FS_ALIGNED_BUFFER_ENABLE")

    symbol.setVisible(((fatEnabled == True) or (filexEnabled == True)) and (alignedBufferEnabled == True))

def sysFsAlignedBufferShow(symbol, event):
    component = symbol.getComponent()

    fatEnabled = component.getSymbolValue("SYS_FS_FAT")
    mpfsEnabled = component.getSymbolValue("SYS_FS_MPFS")
    lfsEnabled = component.getSymbolValue("SYS_FS_LFS")
    filexEnabled = component.getSymbolValue("SYS_FS_FILEX")

    if ((fatEnabled == True) or (mpfsEnabled == True) or (lfsEnabled == True) or (filexEnabled == True)):
        symbol.setVisible(True)

def sysFSLFNSet(symbol, event):
    if (event["value"] == True):
        symbol.setReadOnly(True)
        symbol.setValue(True)
    else:
        symbol.setReadOnly(False)

def genRtosTask(symbol, event):
    if (event["value"] != "BareMetal"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def showRTOSMenu(symbol, event):
    if (event["value"] != "BareMetal"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def showRTOSTaskDel(sysFSRTOSTaskDelayVal, enable):
    sysFSRTOSTaskDelayVal.setVisible(enable["value"])

def showFSVol(sysFSVol,enable):
    sysFSVol.setVisible(not enable["value"])

global volumeValues

volumeValues = [0, 0, 0, 0]

def totalNumberOfVolumes(symbol, event):
    component = symbol.getComponent()

    if (component.getSymbolByID("SYS_FS_AUTO_MOUNT").getValue() == True):
        for i in range(0,4):
            if (component.getSymbolByID("SYS_FS_IDX" + str(i)).getVisible() == True):
                volumeValues[i] = component.getSymbolByID("SYS_FS_VOLUME_INSTANCES_NUMBER_IDX" + str(i)).getValue()
            else:
                volumeValues[i] = 0

        totalNumVolumes = volumeValues[0] + volumeValues[1] + volumeValues[2] + volumeValues[3]
    else:
        totalNumVolumes = component.getSymbolByID("SYS_FS_VOLUME_NUMBER").getValue()

    component.getSymbolByID("SYS_FS_TOTAL_VOLUMES").setValue(totalNumVolumes)

def showFSClientNum(sysFSClientNum,enable):
    sysFSClientNum.setVisible(enable["value"])

def showMedia(sysFSMedia, count):
    component = sysFSMedia.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_IDX" + str(i)).setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_IDX" + str(i)).setValue(count["value"] >= i + 1)

def showMediaConfMenu(sysFSMediaConfMenu, enable):
    component = sysFSMediaConfMenu.getComponent()
    auto_mount = component.getSymbolValue("SYS_FS_AUTO_MOUNT")
    for i in range(0,4):
        media = component.getSymbolValue("SYS_FS_IDX" + str(i))
        component.getSymbolByID("MEDIA_CONF_MENU" + str(i)).setVisible((media==True) & (auto_mount==True))

def showMediaNVMFAT12(sysFSMediaNVM, enable):
    component = sysFSMediaNVM.getComponent()
    for i in range(0,4):
        fs = component.getSymbolValue("SYS_FS_TYPE_DEFINE_IDX" + str(i))
        media = component.getSymbolValue("SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i))
        component.getSymbolByID("SYS_FS_USE_NVM_MBR" + str(i)).setVisible((media == "SYS_FS_MEDIA_TYPE_NVM") & (fs == "FAT"))

def showMediaSRAMFAT12(sysFSMediaSRAM, enable):
    component = sysFSMediaSRAM.getComponent()
    for i in range(0,4):
        fs = component.getSymbolValue("SYS_FS_TYPE_DEFINE_IDX" + str(i))
        media = component.getSymbolValue("SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i))
        component.getSymbolByID("SYS_FS_USE_SRAM_MBR" + str(i)).setVisible((media == "SYS_FS_MEDIA_TYPE_RAM") & (fs == "FAT"))

def showMediaVOL0(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX0").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX0").setValue(count["value"] >= i + 1)

def showMediaVOL1(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX1").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX1").setValue(count["value"] >= i + 1)

def showMediaVOL2(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX2").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX2").setValue(count["value"] >= i + 1)

def showMediaVOL3(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX3").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX3").setValue(count["value"] >= i + 1)

def showMediaVolMenu(sysFSMediaVolConfMenu, enable):
    sysFSMediaVolConfMenu.setVisible(enable["value"])

def mediaDeviceName0(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX0").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX0").setValue(deviceNames.get(name["value"])  + str(i + 1))

def mediaDeviceName1(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX1").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX1").setValue(deviceNames.get(name["value"])  + str(i + 1))

def mediaDeviceName2(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX2").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX2").setValue(deviceNames.get(name["value"])  + str(i + 1))

def mediaDeviceName3(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX3").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX3").setValue(deviceNames.get(name["value"])  + str(i + 1))

def sysFsRtosMicriumOSIIIAppTaskVisibility(symbol, event):
    if (event["value"] == "MicriumOSIII"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def sysFsRtosMicriumOSIIITaskOptVisibility(symbol, event):
    symbol.setVisible(event["value"])

def sysFsLFSEnabled (symbol, event):
    if event["value"] == True:
        Database.sendMessage("core", "HEAP_SIZE", {"heap_size":8192})

def getActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "FreeRTOS"):
            return "FreeRTOS"
        elif (activeComponents[i] == "ThreadX"):
            return "ThreadX"
        elif (activeComponents[i] == "MicriumOSIII"):
            return "MicriumOSIII"
        elif (activeComponents[i] == "MbedOS"):
            return "MbedOS"

def destroyComponent(sysFSComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_MEDIA", {"isEnabled":False})