#include <string.h>
#include "system/time/sys_time.h"
#include "configuration.h"
#include "sys_time_local.h"

static SYS_TIME_COUNTER_OBJ gSystemCounterObj;

static SYS_TIME_TIMER_OBJ timers[SYS_TIME_MAX_TIMERS];

/* This a global token counter used to generate unique timer handles */
static uint16_t gSysTimeTokenCount = 0;

// *****************************************************************************
// *****************************************************************************
// Section: Local Functions
// *****************************************************************************
// *****************************************************************************
static void time_resourceLock()
{
    SYS_INT_SourceDisable(gSystemCounterObj.timeInterrupt);
    return;
}

static void time_resourceUnlock()
{
    SYS_INT_SourceEnable(gSystemCounterObj.timeInterrupt);
    return;
}

static SYS_TIME_TIMER_OBJ * time_getTimerObject(SYS_TIME_HANDLE handle)
{
    /* The buffer index is the contained in the lower 16 bits of the buffer
     * handle */
    return (&timers[handle & _SYS_TIME_HANDLE_TOKEN_MAX]);
}

static void timeToCounter_update(SYS_TIME_COUNTER_OBJ * counterObj)
{
    uintmax_t tempCount = ((uintmax_t)counterObj->counter + (uintmax_t)counterObj->tmrActive->timeRelActive);

    if(tempCount > COUNTER_MAX)
    {
        counterObj->timeToCounter = counterObj->tmrActive->timeRelActive - (COUNTER_MAX - counterObj->counter);
        counterObj->tmrRollover = true;
    }
    else
    {
        counterObj->timeToCounter = (TIME)tempCount;
    }
}

static void timer_removeFromList(SYS_TIME_TIMER_OBJ *timer)
{
    SYS_TIME_COUNTER_OBJ *counter = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ *tmr = counter->tmrActive;

    time_resourceLock();

    do {
        /* If it's an active timer */
        if(tmr == timer)
        {
            if(counter->tmrElapsed == false)
            {
                tmr->tmrNext->timeRelActive += (counter->timeToCounter - counter->counter);
            }

            counter->tmrActive = tmr->tmrNext;
            timeToCounter_update(counter);
            break;
        }
        else if(tmr->tmrNext == timer)
        {
            tmr->tmrNext = timer->tmrNext;

            /* Update next timer relative time */
            tmr->tmrNext->timeRelActive += timer->timeRelActive;

            timer->timeRelActive = timer->time;
            timer->tmrNext = NULL;
            break;
        }
        else
        {
            tmr = tmr->tmrNext;
        }
    }while(tmr->tmrNext != NULL);

    time_resourceUnlock();

    return;
}

static void timer_addToList(SYS_TIME_TIMER_OBJ *timer)
{
    SYS_TIME_COUNTER_OBJ *counter = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_TIMER_OBJ *tmr = counter->tmrActive;
    SYS_TIME_TIMER_OBJ *prevTmr = counter->tmrActive;
    TIME timeTotal = 0;

    time_resourceLock();

    /* Get to a point where total timeout value is greater than the new timer's
     * timeout */
    while(tmr != NULL)
    {
        timeTotal += tmr->timeRelActive;
        if(timeTotal > timer->time)
        {
            break;
        }

        prevTmr = tmr;
        tmr = tmr->tmrNext;
    }

    /* Add new timer to the list */
    /* If new timer has to be first timer */
    if(tmr == counter->tmrActive)
    {
        timer->timeRelActive = timer->time;
        timer->tmrNext = tmr;
        counter->tmrActive = timer;
        counter->tmrElapsed = false;
        timeToCounter_update(counter);
    }
    else
    {
        timer->timeRelActive = timer->time - (timeTotal - tmr->timeRelActive);
        timer->tmrNext = tmr;
        prevTmr->tmrNext = timer;
    }

    /* Adjust next timer to new relative time if it's not NULL */
    if(timer->tmrNext != NULL)
    {
        timer->tmrNext->timeRelActive -= timer->timeRelActive;
    }

    time_resourceUnlock();

    return;
}

static void timer_update(SYS_TIME_COUNTER_OBJ * counterObj)
{
    SYS_TIME_TIMER_OBJ *timerObj = counterObj->tmrActive;

    timer_removeFromList(timerObj);

    if(timerObj->type == SYS_TIME_PERIODIC)
    {
        timer_addToList(timerObj);
    }
    else
    {
        timerObj->active = false;
        counterObj->tmrActive = timerObj->tmrNext;
    }

    /* For periodic timer, elapsed flag is set if timer is expired at least
     * once */
    timerObj->tmrElapsed = true;

    if(timerObj->callback != NULL)
    {
        timerObj->callback(timerObj->context);
    }

    timeToCounter_update(counterObj);

    return;
}

static void counter_update(SYS_TIME_COUNTER_OBJ * counterObj)
{
    TIME counterLow = counterObj->counter & HW_COUNTER_MAX;
    TIME counterHigh = counterObj->counter >> HW_COUNTER_WIDTH;

    if((counterLow + counterObj->timePeriod) > HW_COUNTER_MAX)
    {
        counterLow = ((counterLow + counterObj->timePeriod) - HW_COUNTER_MAX);

        if(counterHigh < HIGH_COUNTER_MAX)
        {
            counterHigh++;
        }
        else
        {
            counterObj->tmrRollover = false;
            counterHigh = 0;
        }
    }
    else
    {
        counterLow += counterObj->timePeriod;
    }

    counterObj->counter = ((counterHigh << HW_COUNTER_WIDTH) | (counterLow & HW_COUNTER_MAX));

}

static void counter_task(void)
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;

    counter_update(counterObj);

    if((counterObj->tmrActive != NULL) && (counterObj->timeToCounter <= counterObj->counter))
    {
        if(counterObj->tmrRollover == false)
        {
            counterObj->tmrElapsed = true;
            timer_update(counterObj);
        }

    }
}

static void TIME_PLIB_Callback(uintptr_t context)
{
    counter_task();
}

static void counter_init(SYS_MODULE_INIT * init)
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;
    SYS_TIME_INIT * initData = (SYS_TIME_INIT *)init;

    counterObj->timePlib = initData->timePlib;
    counterObj->timeFrequency = initData->timeFrequency;
    counterObj->timeInterrupt = initData->timeInterrupt;
    counterObj->timePeriod = (initData->timeUnitResolution * (counterObj->timeFrequency/1000000));

    counterObj->counter = 0;
    counterObj->tmrActive = NULL;
    counterObj->tmrElapsed = false;

    counterObj->timePlib->timerCallbackSet(TIME_PLIB_Callback, 0);
    counterObj->timePlib->timerPeriodSet(counterObj->timePeriod);
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
TIME SYS_TIME_FrequencyGet ( void )
{
    return gSystemCounterObj.timeFrequency;
}

TIME SYS_TIME_CounterGet ( void )
{
    SYS_TIME_COUNTER_OBJ * counterObj = (SYS_TIME_COUNTER_OBJ *)&gSystemCounterObj;

    return (counterObj->counter + counterObj->timePlib->timerCounterGet());
}

void SYS_TIME_CounterSet ( TIME count )
{
    time_resourceLock();
    gSystemCounterObj.counter = count;
    time_resourceUnlock();
}

uint32_t  SYS_TIME_CountToUS ( TIME count )
{
    return ((count * 1000000)/gSystemCounterObj.timeFrequency);
}

uint32_t  SYS_TIME_CountToMS ( TIME count )
{
    return ((count * 1000)/gSystemCounterObj.timeFrequency);
}

TIME SYS_TIME_USToCount ( uint32_t us )
{
    return (us * (gSystemCounterObj.timeFrequency/1000000));
}

TIME SYS_TIME_MSToCount ( uint32_t ms )
{
    return (ms * (gSystemCounterObj.timeFrequency/1000));
}


// *****************************************************************************
// *****************************************************************************
// Section:  SYS TIME 32-bit Software Timers
// *****************************************************************************
// *****************************************************************************
SYS_TIME_HANDLE SYS_TIME_TimerCreate(TIME count, TIME period, SYS_TIME_CALLBACK callBack, uintptr_t context, SYS_TIME_CALLBACK_TYPE type)
{
    SYS_TIME_HANDLE tmrHandle = SYS_TIME_HANDLE_INVALID;
    SYS_TIME_TIMER_OBJ *tmr;
    uint32_t tmrObjIndex = 0;

    time_resourceLock();
    if(gSystemCounterObj.status == SYS_STATUS_READY)
    {
        for(tmr = timers; tmr < &timers[SYS_TIME_MAX_TIMERS]; tmr++)
        {
            if(tmr->inuse == false)
            {
                tmr->inuse = true;
                tmr->active = false;
                tmr->type = type;
                tmr->time = period;
                tmr->callback = callBack;
                tmr->context = context;
                tmr->timeRelActive = period - count;

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

SYS_TIME_RESULT SYS_TIME_TimerReload(SYS_TIME_HANDLE handle, TIME count, TIME period, SYS_TIME_CALLBACK callBack, uintptr_t context, SYS_TIME_CALLBACK_TYPE type)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    tmr = time_getTimerObject(handle);

    if(tmr->inuse == true)
    {
        time_resourceLock();
        tmr->active = false;
        tmr->type = type;
        tmr->time = period;
        tmr->callback = callBack;
        tmr->context = context;
        tmr->timeRelActive = period - count;
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

    if(tmr->inuse == true && tmr->active == true)
    {
        time_resourceLock();
        if(tmr->active == true)
        {
            tmr->active = false;
            timer_removeFromList(tmr);
        }
        tmr->inuse = false;
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

    if(tmr->inuse == true)
    {
        time_resourceLock();
        tmr->active = true;
        timer_addToList(tmr);
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

    if(tmr->inuse == true && tmr->active == true)
    {
        time_resourceLock();
        tmr->active = false;
        timer_removeFromList(tmr);
        time_resourceUnlock();
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_TimerCounterGet(SYS_TIME_HANDLE handle, TIME *count)
{
    /* TODO */
    return SYS_TIME_ERROR;
}

bool SYS_TIME_TimerPeriodHasExpired(SYS_TIME_HANDLE handle)
{
    SYS_TIME_TIMER_OBJ *tmr = NULL;

    tmr = time_getTimerObject(handle);

    return tmr->tmrElapsed;
}


// *****************************************************************************
// *****************************************************************************
// Section:  SYS TIME Delay Interface Functions
// *****************************************************************************
// *****************************************************************************
SYS_TIME_RESULT SYS_TIME_DelayUS ( int us, SYS_TIME_HANDLE *handle )
{
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

    *handle = SYS_TIME_TimerCreate(0, SYS_TIME_USToCount(us), NULL, 0, SYS_TIME_SINGLE);
    if(*handle != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerStart(*handle);
        result = SYS_TIME_SUCCESS;
    }

    return result;
}

SYS_TIME_RESULT SYS_TIME_DelayMS ( int ms, SYS_TIME_HANDLE *handle )
{
    SYS_TIME_RESULT result = SYS_TIME_ERROR;

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
        SYS_TIME_TimerStop(handle);
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

    handle = SYS_TIME_TimerCreate(0, SYS_TIME_USToCount(us), callback, context, type);
    if(handle != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerStart(handle);
    }

    return handle;
}

SYS_TIME_HANDLE SYS_TIME_CallbackRegisterMS ( SYS_TIME_CALLBACK callback, uintptr_t context, int ms, SYS_TIME_CALLBACK_TYPE type )
{
    SYS_TIME_HANDLE handle = SYS_TIME_HANDLE_INVALID;

    handle = SYS_TIME_TimerCreate(0, SYS_TIME_MSToCount(ms), callback, context, type);
    if(handle != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerStart(handle);
    }

    return handle;
}