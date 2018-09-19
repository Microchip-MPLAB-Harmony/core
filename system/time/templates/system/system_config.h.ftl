/* TIME System Service Configuration Options */
#define SYS_TIME_MAX_TIMERS                  ${SYS_TIME_MAX_TIMERS?string}
#define SYS_TIME_HW_COUNTER_WIDTH            ${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_WIDTH}
#define SYS_TIME_HW_COUNTER_PERIOD           ${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_PERIOD_MAX}
#define SYS_TIME_HW_COUNTER_HALF_PERIOD		 (SYS_TIME_HW_COUNTER_PERIOD>>1)
#define SYS_TIME_CPU_CLOCK_FREQUENCY         ${core.CPU_CLOCK_FREQUENCY}