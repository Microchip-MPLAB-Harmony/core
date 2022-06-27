# Mutex Operations

A mutex or mutual exclusion is used to protect a shared resource from access by multiple threads at the same time. A shared resource may be a common data structure in RAM or it may be a hardware peripheral. In either case a mutex can be used to ensure the integrity of the entire resource by only allowing one thread to access it at a time.

The library must be written in such a way that before the shared resources is accessed the mutex has to be obtained. Once obtained the accesses should occur, and once complete the mutex should then be released. While no restrictions are enforced the sequence of operations between the lock and unlock should ideally take as few lines of code as possible to ensure good system performance.

The mutex may be implemented as a form of binary semaphore but an underlying RTOS will often add other features. It is normal to add the restriction that a mutex may only be unlocked from the thread that originally obtained the lock in the first place. The RTOS may also provide features to mitigate priority inversion problems \(where a high priority thread blocks on a lower priority one holding a mutex\) by providing priority inheritance allowing lower priority threads to be temporarily raised to complete and release a locked mutex.

```c
/* perform operations on a shared data structure */
struct myDataStructure {
    uint16_t  x;
    uint8_t y;
} myDataStructure;

...
OSAL_MUTEX_DECLARE(mutexDS);
OSAL_MUTEX_Create(&mutexDS);

...
/* wait 2 seconds to obtain the mutex */
if (OSAL_MUTEX_Lock(mutexDS, 2000) == OSAL_RESULT_TRUE)
{
    /* operate on the data structure */
    myDataStructure.x = 32;
    OSAL_MUTEX_Unlock(mutexDS);
}
```

**Parent topic:**[Using The Library](GUID-0EE2CCDD-3C1B-4DA6-90EB-50B9B67AC895.md)

