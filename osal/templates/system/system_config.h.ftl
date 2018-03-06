<#assign num = OSAL_RTOS?number>
<#if (num > 0) >
	<#lt>#define OSAL_USE_RTOS          ${OSAL_RTOS}
</#if>

