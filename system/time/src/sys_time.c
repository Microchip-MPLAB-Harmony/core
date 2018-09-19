#include <string.h>
#include "system/time/sys_time.h"
#include "configuration.h"
#include "sys_time_local.h"

/* Number of CPU clock measured with cache disabled */ 
#define COMPARE_UPDATE_EXECUTION_CYCLES          (900)  

static SYS_TIME_COUNTER_OBJ gSystemCounterObj;

static SYS_TIME_TIMER_OBJ timers[SYS_TIME_MAX_TIMERS];

/* This a global token counter used to generate unique timer handles */
static uint16_t gSysTimeTokenCount = 1;

// *****************************************************************************
// *****************************************************************************
// Section: Local Functions
// *****************************************************************************
// *****************************************************************************
static void time_resourceLock()
{
    SYS_INT_SourceDisable(gSystemCounterObj.hwTimerIntNum);
    return;
}

static void time_resourceUnlock()
{
    SYS_INT_SourceEnable(gSystemCounterObj.hwTimerIntNum);
    return;
}

static SYS_TIME_TIMER_OBJ * time_getTimerObject(SYS_TIME_HANDLE handle)
{
    /* The buffer index is the contained in the lower 16 bits of the buffer
     * handle */
    if ((handle & _SYS_TIME_HANDLE_TOKEN_MAX) < SYS_TIME_MAX_TIMERS)
    {
        return (&timers[handle & _SYS_TIME_HANDLE_TOKEN_MAX]);
    }
    else
    {
        return NULL;
    }
}

static void hwTimer_CompareUpdate(void)
{    
    uint64_t nextHwCounterValue = 0;
    uint64_t currHwCounterValue;
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ* )&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmrActive = counterObj->tmrActive;

    counterObj->hwTimerPreviousValue = counterObj->hwTimerCurrentValue;

    if (tmrActive != NULL)
    {
        if (tmrActive->relativeTimePending > SYS_TIME_HW_COUNTER_HALF_PERIOD)
        {
            nextHwCounterValue = counterObj->hwTimerCurrentValue + SYS_TIME_HW_COUNTER_HALF_PERIOD;
        }
        else
        {
            nextHwCounterValue = counterObj->hwTimerCurrentValue + tmrActive->relativeTimePending;
        }
    }
    else
    {
        nextHwCounterValue = counterObj->hwTimerCurrentValue + SYS_TIME_HW_COUNTER_HALF_PERIOD;
    }       

    currHwCounterValue = counterObj->timePlib->timerCounterGet();

    /* The hardware counter has rolled over */
    if (currHwCounterValue < counterObj->hwTimerPreviousValue)
    {
        currHwCounterValue = SYS_TIME_HW_COUNTER_PERIOD + currHwCounterValue;
    }

    /* Already elapsed or about elapse. Set compare value to immediately generate an interrupt */
    if (nextHwCounterValue  < (currHwCounterValue + counterObj->hwTimerCompareMargin))
    {
        counterObj->hwTimerCompareValue = currHwCounterValue + counterObj->hwTimerCompareMargin;
    }
    else
    {
        counterObj->hwTimerCompareValue = nextHwCounterValue;
    }

    /* Compare value cannot be zero. */
    if ((counterObj->hwTimerCompareValue & SYS_TIME_HW_COUNTER_PERIOD) == 0)
    {
        counterObj->hwTimerCompareValue = 1;
    }

    counterObj->timePlib->timerCompareSet(counterObj->hwTimerCompareValue);          
}
    
static uint32_t counter32_update(uint32_t elapsedCount, uint8_t* isSwCounter32Oveflow)
{
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    uint32_t prevSwCounter32Bit = counterObj->swCounter64Low;
    uint32_t newSwCounter32Bit;

    *isSwCounter32Oveflow = false;

    newSwCounter32Bit = prevSwCounter32Bit + elapsedCount;

    if (newSwCounter32Bit < prevSwCounter32Bit)
    {
        *isSwCounter32Oveflow = true;
    }

    return newSwCounter32Bit;
}

static void counter64_update(uint32_t elapsedCount)
{
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    uint8_t isSwCounter32Oveflow = false;

    counterObj->swCounter64Low = counter32_update(elapsedCount, &isSwCounter32Oveflow);

    if (isSwCounter32Oveflow == true)
    {
        /* Update high counter for 64 bit on each 32 bit counter overflow */
        counterObj->swCounter64High++;
    }
}

static bool timer_removeFromList(SYS_TIME_TIMER_OBJ *delTimer)
{
    SYS_TIME_COUNTER_OBJ* counter = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmr = counter->tmrActive;
    SYS_TIME_TIMER_OBJ* prevTmr = NULL;
    bool isHeadTimerUpdated = false;

    tmr = counter->tmrActive;

    /* Find the timer to be deleted from the linked list */
    while ((tmr != NULL) && (tmr != delTimer))
    {
        prevTmr = tmr;
        tmr = tmr->tmrNext;
    }

    /* Could not find the timer in the list? return */
    if (tmr == NULL)
    {
        return isHeadTimerUpdated;
    }

    /* Add the deleted timer pending time to the next timer in the list */
    if (delTimer->tmrNext != NULL)
    {
        delTimer->tmrNext->relativeTimePending += delTimer->relativeTimePending;
    }

    /* If the deleted timer was at the head of the list */
    if (prevTmr == NULL)
    {
        counter->tmrActive = counter->tmrActive->tmrNext;
        isHeadTimerUpdated = true;
    }
    else
    {
        /* If the deleted timer was not the head of the list */
        prevTmr->tmrNext = delTimer->tmrNext;
    }

    delTimer->tmrNext = NULL;

    return isHeadTimerUpdated;
}

static bool timer_addToList(SYS_TIME_TIMER_OBJ* newTimer)
{
    uint64_t total_time = 0;
    SYS_TIME_COUNTER_OBJ* counter = (SYS_TIME_COUNTER_OBJ* )&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmr = counter->tmrActive;
    SYS_TIME_TIMER_OBJ* prevTmr = NULL;
    uint32_t newTimerTime;
    bool isHeadTimerUpdated = false;

    if (newTimer == NULL)
    {
        return isHeadTimerUpdated;
    }
    
    newTimerTime = newTimer->relativeTimePending;

    if (tmr == NULL)
    {
        /* Add the new timer to the top of the list */
        newTimer->relativeTimePending = newTimerTime;
        counter->tmrActive = newTimer;
        isHeadTimerUpdated = true;
    }
    else
    {
        /* Find appropriate location to insert the new timer */
        while (tmr != NULL)
        {
            if ((total_time + tmr->relativeTimePending) > newTimerTime)
            {
                break;
            }
            total_time += tmr->relativeTimePending;
            prevTmr = tmr;
            tmr = tmr->tmrNext;
        }

        /* The new timer must be inserted to the head of the list */
        if (prevTmr == NULL)
        {
            /* head = newTimer*/
            counter->tmrActive = newTimer;
            /* head->next = previous head */
            newTimer->tmrNext = tmr;
            isHeadTimerUpdated = true;
        }
        else
        {
            newTimer->tmrNext = prevTmr->tmrNext;
            prevTmr->tmrNext = newTimer;
        }

        /* Update the relative times */
        newTimer->relativeTimePending = newTimerTime - total_time;
        if (newTimer->tmrNext != NULL)
        {
            /* Subtract the new timers time from the next timer in the list */
            newTimer->tmrNext->relativeTimePending -= newTimer->relativeTimePending;
        }
    }
    return isHeadTimerUpdated;
}

static uint32_t timer_getElapsedCount(uint32_t hwTimerCurrentValue)
{
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ* )&gSystemCounterObj;
    uint32_t elapsedCount = 0;

    /* Calculate the elapsed time since the last time the timers in the list
     * were updated. */
    if (hwTimerCurrentValue > counterObj->hwTimerPreviousValue)
    {
        elapsedCount = hwTimerCurrentValue - counterObj->hwTimerPreviousValue;
    }
    else
    {
        elapsedCount = (SYS_TIME_HW_COUNTER_PERIOD - counterObj->hwTimerPreviousValue) + hwTimerCurrentValue + 1;
    }
    
    return elapsedCount;

}

static uint32_t timer_getTotalElapsedCount(SYS_TIME_TIMER_OBJ* tmr)
{
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ* )&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmrActive = counterObj->tmrActive;
    uint32_t pendingCount = 0;
    uint32_t elapsedCount = 0;
    uint32_t hwTimerCurrentValue;
    
    /* Add time from all timers in front */
    while ((tmrActive != NULL) && (tmrActive != tmr))
    {
        pendingCount += tmrActive->relativeTimePending;
        tmrActive = tmrActive->tmrNext;
    }
    /* Add the pending time of the requested timer */
    pendingCount += tmrActive->relativeTimePending;
    hwTimerCurrentValue = counterObj->timePlib->timerCounterGet();
    elapsedCount = timer_getElapsedCount(hwTimerCurrentValue); 
    
    if (pendingCount >= elapsedCount)
    {
        pendingCount -= elapsedCount;
    }
    else
    {
        pendingCount = 0;
    }
    
    if (tmrActive->requestedTime >= pendingCount)
    {
        elapsedCount = tmrActive->requestedTime - pendingCount;
    }
    else
    {
        elapsedCount = 0;
    }
    
    return elapsedCount;
}

static void timer_updateTimerList(uint32_t elapsedCount)
{
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ* )&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmr = NULL;

    tmr = counterObj->tmrActive;

    while ((tmr != NULL) && (elapsedCount > 0))
    {
        if (tmr->relativeTimePending >= elapsedCount)
        {
            tmr->relativeTimePending -= elapsedCount;
            elapsedCount = 0;
        }
        else
        {
            /* The timer has probably expired */
            elapsedCount -= tmr->relativeTimePending;
            tmr->relativeTimePending = 0;
        }
        tmr = tmr->tmrNext;
    }

    counterObj->hwTimerPreviousValue = counterObj->hwTimerCurrentValue;
}

static void timer_add(SYS_TIME_TIMER_OBJ* newTimer)
{
    SYS_TIME_COUNTER_OBJ* counterObj = (SYS_TIME_COUNTER_OBJ* )&gSystemCounterObj;
    uint32_t elapsedCount = 0;
    bool isHeadTimerUpdated = false;
    bool interruptState;

    counterObj->hwTimerCurrentValue = counterObj->timePlib->timerCounterGet();

    elapsedCount = timer_getElapsedCount(counterObj->hwTimerCurrentValue);

    timer_updateTimerList(elapsedCount);

    counter64_update(elapsedCount);

    isHeadTimerUpdated = timer_addToList(newTimer);

    if (isHeadTimerUpdated == true)
    {
        interruptState = SYS_INT_Disable();
        hwTimer_CompareUpdate();
        SYS_INT_Restore(interruptState);
    }
}

static void timer_notify(void)
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmrActive = counterObj->tmrActive;
    
    while (tmrActive != NULL)
    {
        if(tmrActive->relativeTimePending == 0)
        {
            tmrActive->tmrElapsed = true;            
            if(tmrActive->callback != NULL)
            {
                tmrActive->callback(tmrActive->context);
            }
            timer_removeFromList(tmrActive);
            /* Reload the relative pending time with the requested time */
            tmrActive->relativeTimePending = tmrActive->requestedTime;
            tmrActive = counterObj->tmrActive;            
        }
        else
        {
            break;
        }
    }    
}

static void timer_updateTime(uint32_t elapsedCounts)
{    
    timer_updateTimerList(elapsedCounts);
    
    timer_notify();
           
    /* Add the removed timers back into the linked list if the timer type is periodic. */
    for (uint8_t i = 0; i < SYS_TIME_MAX_TIMERS; i++)
    {
        if ((timers[i].tmrElapsed == true) && (timers[i].active == true))
        {
            if (timers[i].type == SYS_TIME_PERIODIC)
            {
                timers[i].tmrElapsed = false;
                timer_addToList(&timers[i]);
            }
            else
            {
                timers[i].active = false;
            }
        }
    }
}

static void TIME_PLIB_Callback(uintptr_t context)
{    
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ* tmrActive = counterObj->tmrActive;
    uint32_t elapsedCount = 0;
    bool interruptState;                
                
    counterObj->interruptContext = true;

    counterObj->hwTimerCurrentValue = counterObj->timePlib->timerCounterGet();

    elapsedCount = timer_getElapsedCount(counterObj->hwTimerCurrentValue)                  ;

    if (tmrActive != NULL)
    {
        timer_updateTime(elapsedCount);        
    }
    counter64_update(elapsedCount);
    
    interruptState = SYS_INT_Disable();
    hwTimer_CompareUpdate();
    SYS_INT_Restore(interruptState);

    counterObj->interruptContext = false;
}

static void counter_init(SYS_MODULE_INIT * init)
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_INIT * initData = (SYS_TIME_INIT *)init;
    int32_t cpuCyclesPerTimerClock;


    counterObj->timePlib = initData->timePlib;
    counterObj->hwTimerFrequency = counterObj->timePlib->timerFrequencyGet();

    cpuCyclesPerTimerClock=(SYS_TIME_CPU_CLOCK_FREQUENCY/counterObj->hwTimerFrequency);
    counterObj->hwTimerCompareMargin=(COMPARE_UPDATE_EXECUTION_CYCLES/cpuCyclesPerTimerClock) +2;        

    counterObj->hwTimerIntNum = initData->hwTimerIntNum;
    counterObj->hwTimerPreviousValue = 0;
    counterObj->hwTimerPeriodValue = SYS_TIME_HW_COUNTER_PERIOD;
    counterObj->hwTimerCompareValue = SYS_TIME_HW_COUNTER_HALF_PERIOD;

    counterObj->swCounter64Low = 0;
    counterObj->swCounter64High = 0;
    counterObj->tmrActive = NULL;
    counterObj->interruptContext = false;

    counterObj->timePlib->timerCallbackSet(TIME_PLIB_Callback, 0);
    if (counterObj->timePlib->timerPeriodSet != NULL)
    {
        counterObj->timePlib->timerPeriodSet(counterObj->hwTimerPeriodValue);
    }
    counterObj->timePlib->timerCompareSet(counterObj->hwTimerCompareValue);
    counterObj->timePlib->timerStart();
}

// *****************************************************************************
// *****************************************************************************
// Section: System Interface Functions
// *****************************************************************************
// *****************************************************************************
SYS_MODULE_OBJ SYS_TIME_Initialize( const SYS_MODULE_INDEX index, const SYS_MODULE_INIT * const init )
{
    if(init == 0 || index != SYS_TIME_INDEX_0)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    counter_init((SYS_MODULE_INIT *)init);
    memset(timers, 0, sizeof(timers));

    gSystemCounterObj.status = SYS_STATUS_READY;

    return (SYS_MODULE_OBJ)&gSystemCounterObj;
}


void SYS_TMR_Deinitialize ( SYS_MODULE_OBJ object )
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;

    if(counterObj != (SYS_TIME_COUNTER_OBJ *)object)
    {
        return;
    }

    counterObj->timePlib->timerStop();

    memset(&timers, 0, sizeof(timers));
    memset(&gSystemCounterObj, 0, sizeof(gSystemCounterObj));

    counterObj->status = SYS_STATUS_UNINITIALIZED;

    return;
}

SYS_STATUS SYS_TIME_Status ( SYS_MODULE_OBJ object )
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_STATUS status = SYS_STATUS_UNINITIALIZED;

    if(counterObj == (SYS_TIME_COUNTER_OBJ *)object)
    {
        status = counterObj->status;
    }

    return status;
}

// *****************************************************************************
// *****************************************************************************
// Section:  SYS TIME 32-bit Counter and Conversion Functions
// *****************************************************************************
// *****************************************************************************
uint32_t SYS_TIME_FrequencyGet ( void )
{
    return gSystemCounterObj.hwTimerFrequency;
}

uint64_t SYS_TIME_Counter64Get ( void )
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    uint64_t counter64;
    uint32_t counter32;
    uint32_t elapsedCount;
    uint8_t isSwCounter32Oveflow = false;

    time_resourceLock();

    elapsedCount = timer_getElapsedCount(counterObj->timePlib->timerCounterGet());

    counter32 = counter32_update(elapsedCount, &isSwCounter32Oveflow);
    counter64 = counterObj->swCounter64High;

    if (isSwCounter32Oveflow == true)
    {
        counter64++;
    }

    counter64 = ((counter64 << 32) + counter32);

    time_resourceUnlock();

    return counter64;
}

uint32_t SYS_TIME_CounterGet ( void )
{
    uint32_t counter32;

    counter32 = (uint32_t)SYS_TIME_Counter64Get();

    return counter32;
}

void SYS_TIME_CounterSet ( uint32_t count )
{
    time_resourceLock();

    gSystemCounterObj.swCounter64Low = count;
    gSystemCounterObj.swCounter64High = 0;

    time_resourceUnlock();
}

uint32_t  SYS_TIME_CountToUS ( uint32_t count )
{
    return ((float)count/gSystemCounterObj.hwTimerFrequency)*1000000.0;
}

uint32_t  SYS_TIME_CountToMS ( uint32_t count )
{
    return ((float)count/gSystemCounterObj.hwTimerFrequency)*1000.0;
}

uint32_t SYS_TIME_USToCount ( uint32_t us )
{
    return (us * ((float)gSystemCounterObj.hwTimerFrequency/1000000));
}

uint32_t SYS_TIME_MSToCount ( uint32_t ms )
{
    return (ms * ((float)gSystemCounterObj.hwTimerFrequency/1000));
}


// *****************************************************************************
// *****************************************************************************
// Section:  SYS TIME 32-bit Software Timers
// *****************************************************************************
// *****************************************************************************
SYS_TIME_HANDLE SYS_TIME_TimerCreate(
    uint32_t count, 
    uint32_t period, 
    SYS_TIME_CALLBACK callBack, 
    uintptr_t context, 
    SYS_TIME_CALLBACK_TYPE type
)
{
    SYS_TIME_HANDLE tmrHandle = SYS_TIME_HANDLE_INVALID;
    SYS_TIME_TIMER_OBJ *tmr;
    uint32_t tmrObjIndex = 0;

    time_resourceLock();
    if((gSystemCounterObj.status == SYS_STATUS_READY) && (period > 0) && (period >= count))
    {
        for(tmr = timers; tmr < &timers[SYS_TIME_MAX_TIMERS]; tmr++)
        {
            if(tmr->inUse == false)
            {
                tmr->inUse = true;
                tmr->active = false;
                tmr->tmrElapsed = false;
                tmr->type = type;
                tmr->requestedTime = period;
                tmr->callback = callBack;
                tmr->context = context;
                tmr->relativeTimePending = period - count;

                /* Assign a handle to this request. The timer handle must be unique. */
                tmr->tmrHandle = (SYS_TIME_HANDLE)_SYS_TIME_MAKE_HANDLE(gSysTimeTokenCount, tmrObjIndex);
                /* Update the token number. */
                _SYS_TIME_UPDATE_HANDLE_TOKEN(gSysTimeTokenCount);

                tmrHandle = tmr->tmrHandle;

                break;
            }
            tmrObjIndex++;
        }
    }

    time_resourceUnlock();

    return tmrHandle;
}

SYS_TIME_RESULT SYS_TIME_TimerReload(
    SYS_TIME_HANDLE handle, 
    uint32_t count, 
    uint32_t period, 
    SYS_TIME_CALLBACK callBack, 
    uintptr_t context, 
    SYS_TIME_CALLBACK_TYPE type
)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    tmr = time_getTimerObject(handle);

    if((tmr != NULL) && (tmr->inUse == true) && (period > 0) && (period >= count))
    {
        time_resourceLock();        
        /* Temporarily remove the timer from the list. Update and then add it back */
        timer_removeFromList(tmr);                
        tmr->tmrElapsed = false;
        tmr->type = type;
        tmr->requestedTime = period;
        tmr->relativeTimePending = period - count;          
        tmr->callback = callBack;
        tmr->context = context;        
        if (gSystemCounterObj.interruptContext == false)
        {
            timer_add(tmr);
        }
        else
        {
            timer_addToList(tmr);
        }
        tmr->active = true;        
        time_resourceUnlock();
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_TimerDestroy(SYS_TIME_HANDLE handle)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    tmr = time_getTimerObject(handle);

    if((tmr != NULL) && (tmr->inUse == true))
    {
        time_resourceLock();
        if(tmr->active == true)
        {
            timer_removeFromList(tmr);
            tmr->active = false;
        }
        tmr->tmrElapsed = false;
        tmr->inUse = false;
        time_resourceUnlock();
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_TimerStart(SYS_TIME_HANDLE handle)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    tmr = time_getTimerObject(handle);

    if((tmr != NULL) && (tmr->inUse == true) && (tmr->active == false))
    {
        time_resourceLock();
        if (gSystemCounterObj.interruptContext == false)
        {
            timer_add(tmr);
        }
        else
        {
            timer_addToList(tmr);
        }
        tmr->active = true;
        time_resourceUnlock();
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_TimerStop(SYS_TIME_HANDLE handle)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    tmr = time_getTimerObject(handle);

    if((tmr != NULL) && (tmr->inUse == true) && (tmr->active == true))
    {
        time_resourceLock();
        timer_removeFromList(tmr);
        tmr->active = false;
        /* Make sure the timer is started fresh, when next time the timer start API is called */
        tmr->relativeTimePending = tmr->requestedTime;
        time_resourceUnlock();
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_TimerCounterGet(SYS_TIME_HANDLE handle, uint32_t *count)
{    
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    SYS_TIME_RESULT result = SYS_TIME_ERROR;
    uint32_t elapsedCount;    
    
    if (count != NULL)
    {
        tmr = time_getTimerObject(handle);
        if((tmr != NULL) && (tmr->active == true))
        {
            time_resourceLock();
            elapsedCount = timer_getTotalElapsedCount(tmr);
            time_resourceUnlock();
            *count = elapsedCount;
            result = SYS_TIME_SUCCESS;
        }
    }
            
    return result;
}

bool SYS_TIME_TimerPeriodHasExpired(SYS_TIME_HANDLE handle)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    bool status = false;

    tmr = time_getTimerObject(handle);

    if((tmr != NULL) && (tmr->inUse == true))
    {
        status = tmr->tmrElapsed;
    }

    return status;
}


// *****************************************************************************
// *****************************************************************************
// Section:  SYS TIME Delay Interface Functions
// *****************************************************************************
// *****************************************************************************
SYS_TIME_RESULT SYS_TIME_DelayUS ( int us, SYS_TIME_HANDLE* handle )
{
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    if ((handle == NULL) || (us == 0))
    {
        return result;
    }

    *handle = SYS_TIME_TimerCreate(0, SYS_TIME_USToCount(us), NULL, 0, SYS_TIME_SINGLE);
    if(*handle != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerStart(*handle);
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_DelayMS ( int ms, SYS_TIME_HANDLE* handle )
{
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    if ((handle == NULL) || (ms == 0))
    {
        return result;
    }

    *handle = SYS_TIME_TimerCreate(0, SYS_TIME_MSToCount(ms), NULL, 0, SYS_TIME_SINGLE);
    if(*handle != SYS_TIME_HANDLE_INVALID)
    {
        result = SYS_TIME_SUCCESS;
        SYS_TIME_TimerStart(*handle);
    }

    return result;
}

bool SYS_TIME_DelayIsComplete ( SYS_TIME_HANDLE handle )
{
    bool status = false;

    if(true == SYS_TIME_TimerPeriodHasExpired(handle))
    {
        SYS_TIME_TimerDestroy(handle);
        status = true;
    }

    return status;
}


// *****************************************************************************
// *****************************************************************************
// Section:  SYS TIME Callback Interface Functions
// *****************************************************************************
// *****************************************************************************
SYS_TIME_HANDLE SYS_TIME_CallbackRegisterUS ( SYS_TIME_CALLBACK callback, uintptr_t context, int us, SYS_TIME_CALLBACK_TYPE type )
{
    SYS_TIME_HANDLE handle = SYS_TIME_HANDLE_INVALID;

    if (us != 0)
    {
        handle = SYS_TIME_TimerCreate(0, SYS_TIME_USToCount(us), callback, context, type);
        if(handle != SYS_TIME_HANDLE_INVALID)
        {
            SYS_TIME_TimerStart(handle);
        }
    }

    return handle;
}

SYS_TIME_HANDLE SYS_TIME_CallbackRegisterMS ( SYS_TIME_CALLBACK callback, uintptr_t context, int ms, SYS_TIME_CALLBACK_TYPE type )
{
    SYS_TIME_HANDLE handle = SYS_TIME_HANDLE_INVALID;

    if (ms != 0)
    {
        handle = SYS_TIME_TimerCreate(0, SYS_TIME_MSToCount(ms), callback, context, type);
        if(handle != SYS_TIME_HANDLE_INVALID)
        {
            SYS_TIME_TimerStart(handle);
        }
    }

    return handle;
}