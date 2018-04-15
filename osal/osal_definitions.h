
#ifndef __OSAL_DEFINITIONS_H
#define __OSAL_DEFINITIONS_H

#if (OSAL_USE_RTOS == BARE_METAL)
   #include "osal/osal_impl_basic.h"
#elif (OSAL_USE_RTOS == FREE_RTOS_V10)
   #include "osal/osal_freertos.h"
#endif

#endif//__OSAL_DEFINITIONS_H
