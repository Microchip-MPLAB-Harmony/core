<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_RTOS_TASK_USE_DELAY = "GEN_APP_RTOS_TASK_" + i + "_USE_DELAY">
    <#assign GEN_APP_RTOS_TASK_DELAY = "GEN_APP_RTOS_TASK_" + i + "_DELAY">
    <#assign GEN_APP_TASK_ENABLE = "GEN_APP_TASK_ENABLE_" + i>
    <#assign GEN_APP_RTOS_TASK_USE_FPU_CONTEXT = "GEN_APP_RTOS_TASK_" + i + "_OPT_USE_FPU_CONTEXT">
    <#assign GEN_APP_TASK_STATIC = "GEN_APP_TASK_USE_STATIC_ALLOCATION_" + i>
    <#assign GEN_APP_RTOS_TASK_SIZE_BYTES = "GEN_APP_RTOS_TASK_" + i + "_SIZE">
    <#assign GEN_APP_TASK_RESTRICTED_EN = "GEN_APP_TASK_CREATE_RESTRICTED_TASK_" + i>

    <#if SELECT_RTOS == "FreeRTOS" && .vars[GEN_APP_TASK_ENABLE] == true>
        <#lt>/* Handle for the ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks. */
        <#lt>TaskHandle_t x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks;

        <#if .vars[GEN_APP_TASK_STATIC] == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true>
            <#lt>/* Structure that will hold the TCB of the task being created. */
            <#lt>StaticTask_t xTask${i}TCBBuffer;
        </#if>

        <#if .vars[GEN_APP_TASK_RESTRICTED_EN] == true || (.vars[GEN_APP_TASK_STATIC] == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true)>
            <#if .vars[GEN_APP_TASK_RESTRICTED_EN] == true>
                <#assign STACK_BUFFER_ALIGNMENT = "__attribute__((aligned(" + .vars[GEN_APP_RTOS_TASK_SIZE_BYTES] + ")))">
            <#else>
                <#assign STACK_BUFFER_ALIGNMENT = "">
            </#if>

            <#lt>/* Buffer that the task being created will use as its stack.  Note this is
            <#lt>an array of StackType_t variables.  The size of StackType_t is dependent on
            <#lt>the RTOS port. */
            <#lt>StackType_t xTask${i}Stack[ ${.vars[GEN_APP_RTOS_TASK_SIZE_BYTES]} / sizeof(StackType_t) ] ${STACK_BUFFER_ALIGNMENT};
        </#if>

        <#lt>static void l${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks(  void *pvParameters  )
        <#lt>{   <#if .vars[GEN_APP_RTOS_TASK_USE_FPU_CONTEXT]?? && .vars[GEN_APP_RTOS_TASK_USE_FPU_CONTEXT] == true>
        <#lt>    portTASK_USES_FLOATING_POINT();
        <#lt>
        <#lt>    </#if>
        <#lt>    while(true)
        <#lt>    {
        <#lt>        ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks();
        <#if .vars[GEN_APP_RTOS_TASK_USE_DELAY] == true>
        <#lt>        vTaskDelay(${.vars[GEN_APP_RTOS_TASK_DELAY]}U / portTICK_PERIOD_MS);
        </#if>
        <#lt>    }
        <#lt>}
    </#if>
</#list>