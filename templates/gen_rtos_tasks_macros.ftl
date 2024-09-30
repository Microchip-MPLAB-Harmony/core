<#assign GEN_APP_MAX_MPU_REG_CFG = 3>
<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_RTOS_TASK_SIZE_BYTES = "GEN_APP_RTOS_TASK_" + i + "_SIZE">
    <#assign GEN_APP_RTOS_TASK_PRIO = "GEN_APP_RTOS_TASK_" + i + "_PRIO">
    <#assign GEN_APP_TASK_ENABLE = "GEN_APP_TASK_ENABLE_" + i>
    <#assign GEN_APP_TASK_STATIC = "GEN_APP_TASK_USE_STATIC_ALLOCATION_" + i>
    <#assign GEN_APP_TASK_RESTRICTED_EN = "GEN_APP_TASK_CREATE_RESTRICTED_TASK_" + i>
    <#assign GEN_APP_TASK_PRIVILEGED_EN = "GEN_APP_TASK_CREATE_PRIVILEGED_TASK_" + i>

    <#if SELECT_RTOS == "FreeRTOS" && .vars[GEN_APP_TASK_ENABLE] == true>
        <#if .vars[GEN_APP_TASK_RESTRICTED_EN] == true>
            <#assign MPU_REG0_CFG = "0, 0, 0">
            <#assign MPU_REG1_CFG = "0, 0, 0">
            <#assign MPU_REG2_CFG = "0, 0, 0">
            <#list 0..(GEN_APP_MAX_MPU_REG_CFG-1) as j>
                <#assign MPU_REGION_EN = "GEN_APP_TASK_" + i + "_MPU_REG_CFG_" + j>
                <#if .vars[MPU_REGION_EN] == true>
                    <#assign MPU_REGION_BASE_ADDR = "GEN_APP_TASK_" + i + "_MPU_REG_BADDR_" + j>
                    <#assign MPU_REGION_LEN = "GEN_APP_TASK_" + i + "_MPU_REG_LEN_" + j>
                    <#assign MPU_REGION_ATTR = "GEN_APP_TASK_" + i + "_MPU_REG_ATTR_" + j>
                    <#assign MPU_REGION_ATTR_XN = "GEN_APP_TASK_" + i + "_MPU_REG_ATTR_XN_" + j>
                    <#assign MPU_REGION_ATTR_XN_MACRO = "">
                    <#if .vars[MPU_REGION_ATTR_XN] == true>
                        <#assign MPU_REGION_ATTR_XN_MACRO = " | portMPU_REGION_EXECUTE_NEVER">
                    </#if>
                    <#if j == 0>
                        <#assign MPU_REG0_CFG = "(void*)" + .vars[MPU_REGION_BASE_ADDR] + " , " + .vars[MPU_REGION_LEN] + " , " + .vars[MPU_REGION_ATTR] + MPU_REGION_ATTR_XN_MACRO>
                    <#elseif j == 1>
                        <#assign MPU_REG1_CFG = "(void*)" + .vars[MPU_REGION_BASE_ADDR] + " , " + .vars[MPU_REGION_LEN] + " , " + .vars[MPU_REGION_ATTR] + MPU_REGION_ATTR_XN_MACRO>
                    <#else>
                        <#assign MPU_REG2_CFG = "(void*)" + .vars[MPU_REGION_BASE_ADDR] + " , " + .vars[MPU_REGION_LEN] + " , " + .vars[MPU_REGION_ATTR] + MPU_REGION_ATTR_XN_MACRO>
                    </#if>
                </#if>
            </#list>
                <#lt>   static const xTaskParameters xTask${i}Parameters =
                <#lt>   {
                <#lt>       (TaskFunction_t) l${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks, /* pvTaskCode - the function that implements the task. */
                <#lt>       "${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks", /* pcName */
                <#lt>       ${.vars[GEN_APP_RTOS_TASK_SIZE_BYTES]} / sizeof(StackType_t), /* usStackDepth - defined in words, not bytes. */
                <#lt>       NULL, /* pvParameters - not being used in this case. */
                <#lt>       ${.vars[GEN_APP_RTOS_TASK_PRIO]} <#if .vars[GEN_APP_TASK_PRIVILEGED_EN] == true> | portPRIVILEGE_BIT</#if>, /* uxPriority*/
                <#lt>       xTask${i}Stack, /* puxStackBuffer - the array to use as the task stack. */
                <#lt>       /* xRegions - MPU regions*/
                <#lt>       {
                <#lt>           /* Base - address Length - Parameters */
                <#lt>           { ${MPU_REG0_CFG} },
                <#lt>           { ${MPU_REG1_CFG} },
                <#lt>           { ${MPU_REG2_CFG} }
                <#lt>       }
                <#lt>       <#if .vars[GEN_APP_TASK_STATIC] == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true >
                <#lt>       , &xTask${i}TCBBuffer
                <#lt>       </#if>
                <#lt>   };

            <#if .vars[GEN_APP_TASK_STATIC] == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true>
                <#lt>   (void) xTaskCreateRestrictedStatic(
                <#lt>       &xTask${i}Parameters,
                <#lt>       &x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks
                <#lt>   );
            <#else>
                <#lt>   (void) xTaskCreateRestricted(
                <#lt>       &xTask${i}Parameters,
                <#lt>       &x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks
                <#lt>   );
            </#if>
        <#else>
            <#if .vars[GEN_APP_TASK_STATIC] == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true>
                <#lt>   x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks = xTaskCreateStatic( (TaskFunction_t) l${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks,
                <#lt>       "${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks",
                <#lt>       ${.vars[GEN_APP_RTOS_TASK_SIZE_BYTES]} / sizeof(StackType_t),
                <#lt>       NULL,
                <#lt>       ${.vars[GEN_APP_RTOS_TASK_PRIO]} <#if FreeRTOS.FREERTOS_MPU_PORT_ENABLE == true> | portPRIVILEGE_BIT </#if>,
                <#lt>       xTask${i}Stack,
                <#lt>       &xTask${i}TCBBuffer );
            <#else>
                <#lt>    /* Create OS Thread for ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks. */
                <#lt>    (void) xTaskCreate(
                <#lt>           (TaskFunction_t) l${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks,
                <#lt>           "${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks",
                <#lt>           ${.vars[GEN_APP_RTOS_TASK_SIZE_BYTES] / 4},
                <#lt>           NULL,
                <#lt>           ${.vars[GEN_APP_RTOS_TASK_PRIO]} <#if FreeRTOS.FREERTOS_MPU_PORT_ENABLE == true> | portPRIVILEGE_BIT </#if>,
                <#lt>           &x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks);
            </#if>
        </#if>
    </#if>
</#list>
