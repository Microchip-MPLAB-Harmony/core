def instantiateComponent(sysFSComponent):
    fsTypes = ["FAT","MPFS2"]
    mediaTypes =  ["SYS_FS_MEDIA_TYPE_NVM",
                    "SYS_FS_MEDIA_TYPE_MSD",
                    "SYS_FS_MEDIA_TYPE_SD_CARD",
                    "SYS_FS_MEDIA_TYPE_RAM",
                    "SYS_FS_MEDIA_TYPE_SPIFLASH"]

    res = Database.activateComponents(["HarmonyCore"])

    # Enable dependent Harmony core components
    Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 2)
    
    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 2)

    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True, 2)

    sysFSMenu = sysFSComponent.createMenuSymbol(None, None)
    sysFSMenu.setLabel("File System settings")
    sysFSMenu.setDescription("File System settings")
    sysFSMenu.setVisible(True)
    
    sysFSRTOSMenu = sysFSComponent.createMenuSymbol(None, None)
    sysFSRTOSMenu.setLabel("RTOS settings")
    sysFSRTOSMenu.setDescription("RTOS settings")
    sysFSRTOSMenu.setVisible((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != 0))
    sysFSRTOSMenu.setDependencies(showRTOSMenu, ["Harmony.SELECT_RTOS"])
    
    sysFSRTOSTask = sysFSComponent.createComboSymbol("SYS_FS_RTOS", sysFSRTOSMenu, ["Standalone"])
    sysFSRTOSTask.setLabel("Run Library Tasks As")
    sysFSRTOSTask.setDefaultValue("Standalone")
    sysFSRTOSTask.setVisible(False)
    
    sysFSRTOSStackSize = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_STACK_SIZE", sysFSRTOSMenu)
    sysFSRTOSStackSize.setLabel("Stack Size")
    sysFSRTOSStackSize.setDefaultValue(1024)
    
    sysFSRTOSTaskPriority = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_TASK_PRIORITY", sysFSRTOSMenu)
    sysFSRTOSTaskPriority.setLabel("Task Priority")
    sysFSRTOSTaskPriority.setDefaultValue(1)
    
    sysFSRTOSTaskDelay = sysFSComponent.createBooleanSymbol("SYS_FS_RTOS_USE_DELAY", sysFSRTOSMenu)
    sysFSRTOSTaskDelay.setLabel("Use Task Delay?")
    sysFSRTOSTaskDelay.setDefaultValue(True)    
    
    sysFSRTOSTaskDelayVal = sysFSComponent.createIntegerSymbol("SYS_FS_RTOS_DELAY", sysFSRTOSMenu)
    sysFSRTOSTaskDelayVal.setLabel("Task Delay")
    sysFSRTOSTaskDelayVal.setDefaultValue(10) 
    sysFSRTOSTaskDelayVal.setDependencies(showRTOSTaskDel, ["SYS_FS_RTOS_USE_DELAY"])   
    
    sysFSMaxFiles = sysFSComponent.createIntegerSymbol("SYS_FS_MAX_FILES", sysFSMenu)
    sysFSMaxFiles.setLabel("Maximum Simultaneous File Access")
    sysFSMaxFiles.setDefaultValue(1)
    
    sysFSBlockSize = sysFSComponent.createIntegerSymbol("SYS_FS_MEDIA_MAX_BLOCK_SIZE", sysFSMenu)
    sysFSBlockSize.setLabel("Size Of Block")
    sysFSBlockSize.setDefaultValue(512)
    sysFSBlockSize.setReadOnly(True)
    
    sysFSBufferSize = sysFSComponent.createIntegerSymbol("SYS_FS_MEDIA_MANAGER_BUFFER_SIZE", sysFSMenu)
    sysFSBufferSize.setLabel("Size Of Media Manager Buffer")
    sysFSBufferSize.setDefaultValue(2048)
    
    sysFSAutoMount = sysFSComponent.createBooleanSymbol("SYS_FS_AUTO_MOUNT", sysFSMenu)
    sysFSAutoMount.setLabel("Use File System Auto Mount Feature?")
    sysFSAutoMount.setDefaultValue(False)
    
    sysFSMedia = sysFSComponent.createIntegerSymbol("SYS_FS_INSTANCES_NUMBER", sysFSMenu)
    sysFSMedia.setLabel("Total Number Of Media")
    sysFSMedia.setDefaultValue(1)
    sysFSMedia.setMax(4)
    
    sysFSVol = sysFSComponent.createIntegerSymbol("SYS_FS_VOLUME_NUMBER", sysFSMenu)
    sysFSVol.setLabel("Total Number Of Volumes")
    sysFSVol.setDefaultValue(1)
    sysFSVol.setDependencies(showFSVol, ["SYS_FS_AUTO_MOUNT"])

    sysFSClientNum = sysFSComponent.createIntegerSymbol("SYS_FS_CLIENT_NUMBER", sysFSMenu)
    sysFSClientNum.setLabel("Total Number File System Clients")
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
        sysFSMedia[i].setDefaultValue(i == 0)   
        sysFSMedia[i].setVisible(i == 0)
        sysFSMedia[i].setDependencies(showMedia, ["SYS_FS_INSTANCES_NUMBER"])
        
        sysFSMediaConfMenu.append(i)
        sysFSMediaConfMenu[i] = sysFSComponent.createMenuSymbol("MEDIA_CONF_MENU" + str(i), sysFSMedia[i])
        sysFSMediaConfMenu[i].setLabel("Media configuration" + str(i))
        sysFSMediaConfMenu[i].setDescription("Media configuration" + str(i))
        sysFSMediaConfMenu[i].setVisible(False)
        sysFSMediaConfMenu[i].setDependencies(showMediaConfMenu, ["SYS_FS_IDX" + str(i), "SYS_FS_AUTO_MOUNT"])
        
        sysFSMediaType.append(i)
        sysFSMediaType[i] = sysFSComponent.createComboSymbol("SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i), sysFSMediaConfMenu[i], mediaTypes)
        sysFSMediaType[i].setLabel("Media Type")
        sysFSMediaType[i].setDefaultValue("SYS_FS_MEDIA_TYPE_SD_CARD")
        
        sysFSMediaFsType.append(i)
        sysFSMediaFsType[i] = sysFSComponent.createComboSymbol("SYS_FS_TYPE_DEFINE_IDX" + str(i) , sysFSMediaConfMenu[i], fsTypes)
        sysFSMediaFsType[i].setLabel("File System Type")
        sysFSMediaFsType[i].setDefaultValue("FAT")
        
        sysFSMediaNVM.append(i)
        sysFSMediaNVM[i] = sysFSComponent.createBooleanSymbol("SYS_FS_USE_NVM_MBR" + str(i), sysFSMediaConfMenu[i])
        sysFSMediaNVM[i].setLabel("Create FAT12 in NVM")
        sysFSMediaNVM[i].setDefaultValue(False) 
        sysFSMediaNVM[i].setVisible(False)
        sysFSMediaNVM[i].setDependencies(showMediaNVMFAT12, ["SYS_FS_TYPE_DEFINE_IDX" + str(i), "SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i)])

        sysFSMediaSRAM.append(i)    
        sysFSMediaSRAM[i] = sysFSComponent.createBooleanSymbol("SYS_FS_USE_SRAM_MBR" + str(i), sysFSMediaConfMenu[i])
        sysFSMediaSRAM[i].setLabel("Create FAT12 in SRAM")
        sysFSMediaSRAM[i].setDefaultValue(False)    
        sysFSMediaSRAM[i].setVisible(False)
        sysFSMediaSRAM[i].setDependencies(showMediaSRAMFAT12, ["SYS_FS_TYPE_DEFINE_IDX" + str(i), "SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i)])

        sysFSMediaVol.append(i)
        sysFSMediaVol[i] = sysFSComponent.createIntegerSymbol("SYS_FS_VOLUME_INSTANCES_NUMBER_IDX" + str(i), sysFSMediaConfMenu[i])
        sysFSMediaVol[i].setLabel("Number Of Volumes")
        sysFSMediaVol[i].setDefaultValue(1)
        sysFSMediaVol[i].setMax(4)
        
        for j in range(0,4):
            pos = (i*4) + j
            sysFSMediaxVOL.append(pos)
            sysFSMediaxVOL[pos] = sysFSComponent.createBooleanSymbol("SYS_FS_VOL_" + str(j+1) + "_IDX" + str(i), sysFSMediaConfMenu[i])
            sysFSMediaxVOL[pos].setLabel("Volume" + str(j))
            sysFSMediaxVOL[pos].setDefaultValue(pos % 4 == 0)   
            sysFSMediaxVOL[pos].setVisible(pos % 4 == 0)
            sysFSMediaxVOL[pos].setDependencies(showMediaVOL[i], ["SYS_FS_VOLUME_INSTANCES_NUMBER_IDX"  + str(i)])
            
            sysFSMediaxVolConfMenu.append(pos)
            sysFSMediaxVolConfMenu[pos] = sysFSComponent.createMenuSymbol("VOL_CONF_MENU" + str(pos) , sysFSMediaxVOL[pos])
            sysFSMediaxVolConfMenu[pos].setLabel("Volume configuration" + str(j) )
            sysFSMediaxVolConfMenu[pos].setDescription("Volume configuration" + str(j))
            sysFSMediaxVolConfMenu[pos].setVisible(True)
            sysFSMediaxVolConfMenu[pos].setDependencies(showMediaVolMenu, ["SYS_FS_VOL_" + str(j+1) + "_IDX" + str(i)])
            
            sysFSMediaxVOLDeviceName.append(pos)
            sysFSMediaxVOLDeviceName[pos] = sysFSComponent.createStringSymbol("SYS_FS_MEDIA_DEVICE_" + str(j+1) + "_NAME_IDX"  + str(i), sysFSMediaxVolConfMenu[pos])
            sysFSMediaxVOLDeviceName[pos].setLabel("Device Name")
            sysFSMediaxVOLDeviceName[pos].setDefaultValue("/dev/mmcblka" + str(j+1))    
            sysFSMediaxVOLDeviceName[pos].setVisible(True)
            sysFSMediaxVOLDeviceName[pos].setDependencies(mediaDeviceName[i], ["SYS_FS_MEDIA_TYPE_DEFINE_IDX" + str(i)])
            
            sysFSMediaxVOLMountName.append(pos)
            sysFSMediaxVOLMountName[pos] = sysFSComponent.createStringSymbol("SYS_FS_MEDIA_MOUNT_" + str(j+1) + "_NAME_IDX"  + str(i), sysFSMediaxVolConfMenu[pos])
            sysFSMediaxVOLMountName[pos].setLabel("Media Mount Name")
            sysFSMediaxVOLMountName[pos].setDefaultValue("/mnt/myDrive" + str(j+1)) 
            sysFSMediaxVOLMountName[pos].setVisible(True)
    
    sysFSFileType = sysFSComponent.createIntegerSymbol("SYS_FS_MAX_FILE_SYSTEM_TYPE", sysFSMenu)
    sysFSFileType.setLabel("File System Types")
    sysFSFileType.setDefaultValue(1)
    sysFSFileType.setMax(2)
        
    sysFSFat = sysFSComponent.createBooleanSymbol("SYS_FS_FAT", sysFSMenu)
    sysFSFat.setLabel("FAT File System")
    sysFSFat.setDefaultValue(True)

    sysFSMpfs = sysFSComponent.createBooleanSymbol("SYS_FS_MPFS", sysFSMenu)
    sysFSMpfs.setLabel("Microchip File System")
    sysFSMpfs.setDefaultValue(False)

    sysFSNameLen = sysFSComponent.createIntegerSymbol("SYS_FS_FILE_NAME_LEN", sysFSMenu)
    sysFSNameLen.setLabel("File name length in bytes")
    sysFSNameLen.setDefaultValue(255)
    sysFSNameLen.setMax(255)

    sysFSPathLen = sysFSComponent.createIntegerSymbol("SYS_FS_CWD_STRING_LEN", sysFSMenu)
    sysFSPathLen.setLabel("Current working directory scratch buffer length in bytes")
    sysFSPathLen.setDefaultValue(1024)
    sysFSPathLen.setMax(1)

    sysFSMBR = sysFSComponent.createBooleanSymbol("SYS_FS_USE_MBR", sysFSMenu)
    sysFSMBR.setLabel("Use MBR")
    sysFSMBR.setDefaultValue(False)
    sysFSMBR.setReadOnly(True)
    

############################################Generate Files#################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sysFSHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSHeaderFile.setSourcePath("/system/fs/sys_fs.h")
    sysFSHeaderFile.setOutputName("sys_fs.h")
    sysFSHeaderFile.setDestPath("/system/fs/")
    sysFSHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSHeaderFile.setType("HEADER")

    sysFSLocalHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSLocalHeaderFile.setSourcePath("/system/fs/src/sys_fs_local.h")
    sysFSLocalHeaderFile.setOutputName("sys_fs_local.h")
    sysFSLocalHeaderFile.setDestPath("/system/fs/src/")
    sysFSLocalHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSLocalHeaderFile.setType("HEADER")
    
    sysFSMedManHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSMedManHeaderFile.setSourcePath("/system/fs/sys_fs_media_manager.h")
    sysFSMedManHeaderFile.setOutputName("sys_fs_media_manager.h")
    sysFSMedManHeaderFile.setDestPath("/system/fs/")
    sysFSMedManHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSMedManHeaderFile.setType("HEADER")
    
    sysFSMedLocalHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSMedLocalHeaderFile.setSourcePath("/system/fs/src/sys_fs_media_manager_local.h")
    sysFSMedLocalHeaderFile.setOutputName("sys_fs_media_manager_local.h")
    sysFSMedLocalHeaderFile.setDestPath("/system/fs/src/")
    sysFSMedLocalHeaderFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSMedLocalHeaderFile.setType("HEADER")
    
    sysFSffHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSffHeaderFile.setSourcePath("/system/fs/fat_fs/src/file_system/ff.h")
    sysFSffHeaderFile.setOutputName("ff.h")
    sysFSffHeaderFile.setDestPath("/system/fs/fat_fs/src/file_system")
    sysFSffHeaderFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/file_system")
    sysFSffHeaderFile.setType("HEADER")
    
    sysFSFFConfHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSFFConfHeaderFile.setSourcePath("/system/fs/fat_fs/src/file_system/ffconf.h")
    sysFSFFConfHeaderFile.setOutputName("ffconf.h")
    sysFSFFConfHeaderFile.setDestPath("/system/fs/fat_fs/src/file_system/")
    sysFSFFConfHeaderFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/file_system/")
    sysFSFFConfHeaderFile.setType("HEADER")
    
    sysFSDiskIOHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSDiskIOHeaderFile.setSourcePath("/system/fs/fat_fs/src/hardware_access/diskio.h")
    sysFSDiskIOHeaderFile.setOutputName("diskio.h")
    sysFSDiskIOHeaderFile.setDestPath("/system/fs/fat_fs/src/hardware_access/")
    sysFSDiskIOHeaderFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/hardware_access/")
    sysFSDiskIOHeaderFile.setType("HEADER")
    
    sysFSMPFSHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSMPFSHeaderFile.setSourcePath("/system/fs/mpfs/mpfs.h")
    sysFSMPFSHeaderFile.setOutputName("mpfs.h")
    sysFSMPFSHeaderFile.setDestPath("/system/fs/mpfs/")
    sysFSMPFSHeaderFile.setProjectPath("config/" + configName + "/system/fs/mpfs/")
    sysFSMPFSHeaderFile.setType("HEADER")
    
    sysFSMPFSLocHeaderFile = sysFSComponent.createFileSymbol(None, None)
    sysFSMPFSLocHeaderFile.setSourcePath("/system/fs/mpfs/src/mpfs_local.h")
    sysFSMPFSLocHeaderFile.setOutputName("mpfs_local.h")
    sysFSMPFSLocHeaderFile.setDestPath("/system/fs/mpfs/src/")
    sysFSMPFSLocHeaderFile.setProjectPath("config/" + configName + "/system/fs/mpfs/")
    sysFSMPFSLocHeaderFile.setType("HEADER")
    
    
    sysFSSourceFile = sysFSComponent.createFileSymbol(None, None)
    sysFSSourceFile.setSourcePath("/system/fs/src/sys_fs.c")
    sysFSSourceFile.setOutputName("sys_fs.c")
    sysFSSourceFile.setDestPath("/system/fs/src/")
    sysFSSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSSourceFile.setType("SOURCE")

    sysFSMedManSourceFile = sysFSComponent.createFileSymbol(None, None)
    sysFSMedManSourceFile.setSourcePath("/system/fs/src/sys_fs_media_manager.c")
    sysFSMedManSourceFile.setOutputName("sys_fs_media_manager.c")
    sysFSMedManSourceFile.setDestPath("/system/fs/src/")
    sysFSMedManSourceFile.setProjectPath("config/" + configName + "/system/fs/")
    sysFSMedManSourceFile.setType("SOURCE")
    
    sysFSffSourceFile = sysFSComponent.createFileSymbol(None, None)
    sysFSffSourceFile.setSourcePath("system/fs/fat_fs/src/file_system/ff.c")
    sysFSffSourceFile.setOutputName("ff.c")
    sysFSffSourceFile.setDestPath("system/fs/fat_fs/src/")
    sysFSffSourceFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/")
    sysFSffSourceFile.setType("SOURCE")
    
    sysFSDiskIOFile = sysFSComponent.createFileSymbol(None, None)
    sysFSDiskIOFile.setSourcePath("/system/fs/fat_fs/src/hardware_access/diskio.c")
    sysFSDiskIOFile.setOutputName("diskio.c")
    sysFSDiskIOFile.setDestPath("/system/fs/fat_fs/src/")
    sysFSDiskIOFile.setProjectPath("config/" + configName + "/system/fs/fat_fs/")
    sysFSDiskIOFile.setType("SOURCE")

    sysFSMPFSSourceFile = sysFSComponent.createFileSymbol(None, None)
    sysFSMPFSSourceFile.setSourcePath("/system/fs/mpfs/src/mpfs.c")
    sysFSMPFSSourceFile.setOutputName("mpfs.c")
    sysFSMPFSSourceFile.setDestPath("/system/fs/mpfs/src/")
    sysFSMPFSSourceFile.setProjectPath("config/" + configName + "/system/fs/mpfs/")
    sysFSMPFSSourceFile.setType("SOURCE")
    
    sysFSSystemInitdataFile = sysFSComponent.createFileSymbol("sysFSSystemInitFile", None)
    sysFSSystemInitdataFile.setType("STRING")
    sysFSSystemInitdataFile.setOutputName("core.LIST_SYSTEM_INIT_C_LIBRARY_INITIALIZATION_DATA")
    sysFSSystemInitdataFile.setSourcePath("/system/fs/templates/system/system_initialize_data.c.ftl")
    sysFSSystemInitdataFile.setMarkup(True)

    sysFSSystemInitFile = sysFSComponent.createFileSymbol("sysFSInitDataFile", None)
    sysFSSystemInitFile.setType("STRING")
    sysFSSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_MIDDLEWARE")
    sysFSSystemInitFile.setSourcePath("/system/fs/templates/system/system_initialize.c.ftl")
    sysFSSystemInitFile.setMarkup(True)
    
    sysFSConfigFile = sysFSComponent.createFileSymbol("sysFSConfigFile", None)
    sysFSConfigFile.setType("STRING")
    sysFSConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    sysFSConfigFile.setSourcePath("/system/fs/templates/system/system_config.h.ftl")
    sysFSConfigFile.setMarkup(True)
    
    sysFSConfig2File = sysFSComponent.createFileSymbol("sysFSConfig2File", None)
    sysFSConfig2File.setType("STRING")
    sysFSConfig2File.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    sysFSConfig2File.setSourcePath("/system/fs/templates/system/sys_fs_idx.h.ftl")
    sysFSConfig2File.setMarkup(True)

    sysFSSystemDefFile = sysFSComponent.createFileSymbol("sysFSSystemDefFile", None)
    sysFSSystemDefFile.setType("STRING")
    sysFSSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sysFSSystemDefFile.setSourcePath("/system/fs/templates/system/system_definitions.h.ftl")
    sysFSSystemDefFile.setMarkup(True)  
    
    sysFSSystemTaskFile = sysFSComponent.createFileSymbol("sysFSSystemTaskFile", None)
    sysFSSystemTaskFile.setType("STRING")
    sysFSSystemTaskFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    sysFSSystemTaskFile.setSourcePath("/system/fs/templates/system/system_tasks.c.ftl")
    sysFSSystemTaskFile.setMarkup(True) 

    sysFSSystemRtosTaskFile = sysFSComponent.createFileSymbol("sysFSSystemRtosTaskFile", None)
    sysFSSystemRtosTaskFile.setType("STRING")
    sysFSSystemRtosTaskFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    sysFSSystemRtosTaskFile.setSourcePath("/system/fs/templates/system/system_rtos_tasks.c.ftl")
    sysFSSystemRtosTaskFile.setMarkup(True)
    sysFSSystemRtosTaskFile.setEnabled((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != 0))
    sysFSSystemRtosTaskFile.setDependencies(genRtosTask, ["Harmony.SELECT_RTOS"])

###########################################################################################################
deviceNames = { 'SYS_FS_MEDIA_TYPE_NVM' : '/dev/nvma',
    'SYS_FS_MEDIA_TYPE_MSD' : '/dev/sda',
    'SYS_FS_MEDIA_TYPE_SD_CARD' : '/dev/mmcblka',
    'SYS_FS_MEDIA_TYPE_RAM' : '/dev/rama',
    'SYS_FS_MEDIA_TYPE_SPIFLASH' : '/dev/mtda'
    }

def genRtosTask(symbol, event):
    if (event["value"] != 0):
        # If not Bare Metal
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def showRTOSMenu(symbol, event):
    if (event["value"] != "BareMetal"):
        # If not Bare Metal
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def showRTOSTaskDel(sysFSRTOSTaskDelayVal, enable):
    sysFSRTOSTaskDelayVal.setVisible(enable["value"])

def showFSVol(sysFSVol,enable):
    sysFSVol.setVisible(not enable["value"])

def showFSClientNum(sysFSClientNum,enable):
    sysFSClientNum.setVisible(enable["value"])

def showMedia(sysFSMedia, count):
    component = sysFSMedia.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_IDX" + str(i)).setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_IDX" + str(i)).setValue(count["value"] >= i + 1, 2)

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
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX0").setValue(count["value"] >= i + 1, 2)
    
def showMediaVOL1(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX1").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX1").setValue(count["value"] >= i + 1, 2)
    
def showMediaVOL2(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX2").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX2").setValue(count["value"] >= i + 1, 2)
    
def showMediaVOL3(sysFSVol, count):
    component = sysFSVol.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX3").setVisible(count["value"] >= i + 1)
        component.getSymbolByID("SYS_FS_VOL_" + str(i + 1) + "_IDX3").setValue(count["value"] >= i + 1, 2)
    
def showMediaVolMenu(sysFSMediaVolConfMenu, enable):
    sysFSMediaVolConfMenu.setVisible(enable["value"])
    
def mediaDeviceName0(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX0").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX0").setValue(deviceNames.get(name["value"])  + str(i + 1),2)

def mediaDeviceName1(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX1").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX1").setValue(deviceNames.get(name["value"])  + str(i + 1),2)

def mediaDeviceName2(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX2").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX2").setValue(deviceNames.get(name["value"])  + str(i + 1),2)

def mediaDeviceName3(sysFSMedia0VOL0DeviceName, name):
    component = sysFSMedia0VOL0DeviceName.getComponent()
    for i in range(0,4):
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX3").clearValue()
        component.getSymbolByID("SYS_FS_MEDIA_DEVICE_" + str(i + 1) + "_NAME_IDX3").setValue(deviceNames.get(name["value"])  + str(i + 1),2)

