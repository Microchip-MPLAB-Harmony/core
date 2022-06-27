# SYS\_CMD\_DEVICE\_NODE Struct

**Parent topic:**[Library Interface](GUID-F1DBA6FA-9373-4832-9CD9-BDC0B227003B.md)

## C

```c
typedef struct
{
    const SYS_CMD_API* pCmdApi; // Cmd IO APIs
    const void* cmdIoParam; // channel specific parameter
} SYS_CMD_DEVICE_NODE;

```

## Summary

Defines the data structure to store each command instance.

## Description

This data structure stores all the data relevant to a uniquely entered<br />command instance. It is a node for a linked list structure to support the<br />Command Processor System Service's command history feature

## Remarks

None.

