/*--------------------------------------------------------------------------
 * MPLAB XC32 Compiler -  ${LINKER_DEVICE_NAME} linker script
 *
 * Copyright (c) 2023, Microchip Technology Inc. and its subsidiaries ("Microchip")
 * All rights reserved.
 *
 * This software is developed by Microchip Technology Inc. and its
 * subsidiaries ("Microchip").
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * 1.      Redistributions of source code must retain the above copyright
 *         notice, this list of conditions and the following disclaimer.
 * 2.      Redistributions in binary form must reproduce the above
 *         copyright notice, this list of conditions and the following
 *         disclaimer in the documentation and/or other materials provided
 *         with the distribution.
 * 3.      Microchip's name may not be used to endorse or promote products
 *         derived from this software without specific prior written
 *         permission.
 *
 * THIS SOFTWARE IS PROVIDED BY MICROCHIP "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL MICROCHIP BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWSOEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
SEARCH_DIR(.)

/*
 *  Define the __XC32_RESET_HANDLER_NAME macro on the command line when you
 *  want to use a different name for the Reset Handler function.
 */
#ifndef __XC32_RESET_HANDLER_NAME
#define __XC32_RESET_HANDLER_NAME Reset_Handler
#endif /* __XC32_RESET_HANDLER_NAME */

/*  Set the entry point in the ELF file. Once the entry point is in the ELF
 *  file, you can then use the --write-sla option to xc32-bin2hex to place
 *  the address into the hex file using the SLA field (RECTYPE 5). This hex
 *  record may be useful for a bootloader that needs to determine the entry
 *  point to the application.
 */
ENTRY(__XC32_RESET_HANDLER_NAME)

/*************************************************************************
 * Memory-Region Macro Definitions
 * The XC32 linker preprocesses linker scripts. You may define these
 * macros in the MPLAB X project properties or on the command line when
 * calling the linker via the xc32-gcc shell.
 *************************************************************************/

#ifndef ROM_ORIGIN
#  define ROM_ORIGIN ${LINKER_ROM_ORIGIN}
#endif
#ifndef ROM_LENGTH
#  define ROM_LENGTH ${LINKER_ROM_LENGTH}
#elif (ROM_LENGTH > ${LINKER_ROM_LENGTH})
#  error ROM_LENGTH is greater than the max size of ${LINKER_ROM_LENGTH}
#endif
#ifndef BOOT_ROM_ORIGIN
#  define BOOT_ROM_ORIGIN ${LINKER_BOOTROM_ORIGIN}
#endif
#ifndef BOOT_ROM_LENGTH
#  define BOOT_ROM_LENGTH ${LINKER_BOOTROM_LENGTH}
#elif (BOOT_ROM_LENGTH > ${LINKER_BOOTROM_LENGTH})
#  error BOOT_ROM_LENGTH is greater than the max size of ${LINKER_BOOTROM_LENGTH}
#endif
#ifndef RAM_ORIGIN
#  define RAM_ORIGIN ${LINKER_RAM_ORIGIN}
#endif
#ifndef RAM_LENGTH
#  define RAM_LENGTH ${LINKER_RAM_LENGTH}
#elif (RAM_LENGTH > ${LINKER_RAM_LENGTH})
#  error RAM_LENGTH is greater than the max size of ${LINKER_RAM_LENGTH}
#endif
#ifndef ITCM_ORIGIN
#  define ITCM_ORIGIN 0x0
#endif
#ifndef __XC32_ITCM_LENGTH
#  define __XC32_ITCM_LENGTH ${LINKER_ITCM_ORIGIN}
#elif (defined(__XC32_ITCM_LENGTH)  && __XC32_ITCM_LENGTH != ${LINKER_ITCM_LENGTH})
#  warning Non-standard ITCM length, using default ${LINKER_ITCM_LENGTH}
#  undef __XC32_ITCM_LENGTH
#  define __XC32_ITCM_LENGTH ${LINKER_ITCM_LENGTH}
#endif
#ifndef DTCM_ORIGIN
#  define DTCM_ORIGIN ${LINKER_DTCM_ORIGIN}
#endif
#ifndef __XC32_DTCM_LENGTH
#  define __XC32_DTCM_LENGTH 0x0
#elif (defined(__XC32_DTCM_LENGTH)  && __XC32_DTCM_LENGTH != ${LINKER_DTCM_LENGTH})
#  warning Non-standard DTCM length, using default ${LINKER_DTCM_LENGTH}
#  undef __XC32_DTCM_LENGTH
#  define __XC32_DTCM_LENGTH ${LINKER_DTCM_LENGTH}
#endif



/*************************************************************************
 * Memory-Region Definitions
 * The MEMORY command describes the location and size of blocks of memory
 * on the target device. The command below uses the macros defined above.
 *************************************************************************/
MEMORY
{
  boot_rom (LRX) : ORIGIN = BOOT_ROM_ORIGIN, LENGTH = BOOT_ROM_LENGTH
  rom (LRX) : ORIGIN = ROM_ORIGIN, LENGTH = ROM_LENGTH
  ram (WX!R) : ORIGIN = RAM_ORIGIN, LENGTH = RAM_LENGTH
 itcm (WX) : ORIGIN = ITCM_ORIGIN, LENGTH = __XC32_ITCM_LENGTH
dtcm (WX!R) : ORIGIN = DTCM_ORIGIN, LENGTH = __XC32_DTCM_LENGTH
  config_0A000000 : ORIGIN = 0x0A000000, LENGTH = 0x4
  config_0A000020 : ORIGIN = 0x0A000020, LENGTH = 0x4
  config_0A000040 : ORIGIN = 0x0A000040, LENGTH = 0x4
  config_0A000044 : ORIGIN = 0x0A000044, LENGTH = 0x4
  config_0A000048 : ORIGIN = 0x0A000048, LENGTH = 0x4
  config_0A00004C : ORIGIN = 0x0A00004C, LENGTH = 0x4
  config_0A000054 : ORIGIN = 0x0A000054, LENGTH = 0x4
  config_0A000058 : ORIGIN = 0x0A000058, LENGTH = 0x4
  config_0A00005C : ORIGIN = 0x0A00005C, LENGTH = 0x4
  config_0A000060 : ORIGIN = 0x0A000060, LENGTH = 0x4
  config_0A000064 : ORIGIN = 0x0A000064, LENGTH = 0x4
  config_0A000080 : ORIGIN = 0x0A000080, LENGTH = 0x4
  config_0A0000A0 : ORIGIN = 0x0A0000A0, LENGTH = 0x4
  config_0A002000 : ORIGIN = 0x0A002000, LENGTH = 0x4
  config_0A002004 : ORIGIN = 0x0A002004, LENGTH = 0x4
  config_0A002008 : ORIGIN = 0x0A002008, LENGTH = 0x4
  config_0A002080 : ORIGIN = 0x0A002080, LENGTH = 0x4
  config_0A002084 : ORIGIN = 0x0A002084, LENGTH = 0x4
  config_0A002088 : ORIGIN = 0x0A002088, LENGTH = 0x4
  config_0A00208C : ORIGIN = 0x0A00208C, LENGTH = 0x4
  config_0A002090 : ORIGIN = 0x0A002090, LENGTH = 0x4
  config_0A002094 : ORIGIN = 0x0A002094, LENGTH = 0x4
  config_0A002098 : ORIGIN = 0x0A002098, LENGTH = 0x4
  config_0A00209C : ORIGIN = 0x0A00209C, LENGTH = 0x4
  config_0A0020A0 : ORIGIN = 0x0A0020A0, LENGTH = 0x4
  config_0A0020A4 : ORIGIN = 0x0A0020A4, LENGTH = 0x4
  config_0A0020A8 : ORIGIN = 0x0A0020A8, LENGTH = 0x4
  config_0A0020AC : ORIGIN = 0x0A0020AC, LENGTH = 0x4
  config_0A0020B0 : ORIGIN = 0x0A0020B0, LENGTH = 0x4
  config_0A0020B4 : ORIGIN = 0x0A0020B4, LENGTH = 0x4
  config_0A0020B8 : ORIGIN = 0x0A0020B8, LENGTH = 0x4
  config_0A0020BC : ORIGIN = 0x0A0020BC, LENGTH = 0x4
  config_0A0020C0 : ORIGIN = 0x0A0020C0, LENGTH = 0x4
  config_0A0020C4 : ORIGIN = 0x0A0020C4, LENGTH = 0x4
  config_0A0020C8 : ORIGIN = 0x0A0020C8, LENGTH = 0x4
  config_0A0020CC : ORIGIN = 0x0A0020CC, LENGTH = 0x4
  config_0A0020D0 : ORIGIN = 0x0A0020D0, LENGTH = 0x4
  config_0A0020D4 : ORIGIN = 0x0A0020D4, LENGTH = 0x4
  config_0A0020D8 : ORIGIN = 0x0A0020D8, LENGTH = 0x4
  config_0A0020DC : ORIGIN = 0x0A0020DC, LENGTH = 0x4
  config_0A0020E0 : ORIGIN = 0x0A0020E0, LENGTH = 0x4
  config_0A0020E4 : ORIGIN = 0x0A0020E4, LENGTH = 0x4
  config_0A0020E8 : ORIGIN = 0x0A0020E8, LENGTH = 0x4
  config_0A0020EC : ORIGIN = 0x0A0020EC, LENGTH = 0x4
  config_0A0020F0 : ORIGIN = 0x0A0020F0, LENGTH = 0x4
  config_0A0020F4 : ORIGIN = 0x0A0020F4, LENGTH = 0x4
  config_0A0020F8 : ORIGIN = 0x0A0020F8, LENGTH = 0x4
  config_0A0020FC : ORIGIN = 0x0A0020FC, LENGTH = 0x4
  config_0A002100 : ORIGIN = 0x0A002100, LENGTH = 0x4
  config_0A002110 : ORIGIN = 0x0A002110, LENGTH = 0x4
  config_0A002114 : ORIGIN = 0x0A002114, LENGTH = 0x4
  config_0A002118 : ORIGIN = 0x0A002118, LENGTH = 0x4
  config_0A00211C : ORIGIN = 0x0A00211C, LENGTH = 0x4
  config_0A002120 : ORIGIN = 0x0A002120, LENGTH = 0x4
  config_0A008000 : ORIGIN = 0x0A008000, LENGTH = 0x4
  config_0A008020 : ORIGIN = 0x0A008020, LENGTH = 0x4
  config_0A008040 : ORIGIN = 0x0A008040, LENGTH = 0x4
  config_0A008044 : ORIGIN = 0x0A008044, LENGTH = 0x4
  config_0A008048 : ORIGIN = 0x0A008048, LENGTH = 0x4
  config_0A00804C : ORIGIN = 0x0A00804C, LENGTH = 0x4
  config_0A008054 : ORIGIN = 0x0A008054, LENGTH = 0x4
  config_0A008058 : ORIGIN = 0x0A008058, LENGTH = 0x4
  config_0A00805C : ORIGIN = 0x0A00805C, LENGTH = 0x4
  config_0A008060 : ORIGIN = 0x0A008060, LENGTH = 0x4
  config_0A008064 : ORIGIN = 0x0A008064, LENGTH = 0x4
  config_0A008080 : ORIGIN = 0x0A008080, LENGTH = 0x4
  config_0A0080A0 : ORIGIN = 0x0A0080A0, LENGTH = 0x4
  config_0A00A000 : ORIGIN = 0x0A00A000, LENGTH = 0x4
  config_0A00A004 : ORIGIN = 0x0A00A004, LENGTH = 0x4
  config_0A00A008 : ORIGIN = 0x0A00A008, LENGTH = 0x4
  config_0A00A080 : ORIGIN = 0x0A00A080, LENGTH = 0x4
  config_0A00A084 : ORIGIN = 0x0A00A084, LENGTH = 0x4
  config_0A00A088 : ORIGIN = 0x0A00A088, LENGTH = 0x4
  config_0A00A08C : ORIGIN = 0x0A00A08C, LENGTH = 0x4
  config_0A00A090 : ORIGIN = 0x0A00A090, LENGTH = 0x4
  config_0A00A094 : ORIGIN = 0x0A00A094, LENGTH = 0x4
  config_0A00A098 : ORIGIN = 0x0A00A098, LENGTH = 0x4
  config_0A00A09C : ORIGIN = 0x0A00A09C, LENGTH = 0x4
  config_0A00A0A0 : ORIGIN = 0x0A00A0A0, LENGTH = 0x4
  config_0A00A0A4 : ORIGIN = 0x0A00A0A4, LENGTH = 0x4
  config_0A00A0A8 : ORIGIN = 0x0A00A0A8, LENGTH = 0x4
  config_0A00A0AC : ORIGIN = 0x0A00A0AC, LENGTH = 0x4
  config_0A00A0B0 : ORIGIN = 0x0A00A0B0, LENGTH = 0x4
  config_0A00A0B4 : ORIGIN = 0x0A00A0B4, LENGTH = 0x4
  config_0A00A0B8 : ORIGIN = 0x0A00A0B8, LENGTH = 0x4
  config_0A00A0BC : ORIGIN = 0x0A00A0BC, LENGTH = 0x4
  config_0A00A0C0 : ORIGIN = 0x0A00A0C0, LENGTH = 0x4
  config_0A00A0C4 : ORIGIN = 0x0A00A0C4, LENGTH = 0x4
  config_0A00A0C8 : ORIGIN = 0x0A00A0C8, LENGTH = 0x4
  config_0A00A0CC : ORIGIN = 0x0A00A0CC, LENGTH = 0x4
  config_0A00A0D0 : ORIGIN = 0x0A00A0D0, LENGTH = 0x4
  config_0A00A0D4 : ORIGIN = 0x0A00A0D4, LENGTH = 0x4
  config_0A00A0D8 : ORIGIN = 0x0A00A0D8, LENGTH = 0x4
  config_0A00A0DC : ORIGIN = 0x0A00A0DC, LENGTH = 0x4
  config_0A00A0E0 : ORIGIN = 0x0A00A0E0, LENGTH = 0x4
  config_0A00A0E4 : ORIGIN = 0x0A00A0E4, LENGTH = 0x4
  config_0A00A0E8 : ORIGIN = 0x0A00A0E8, LENGTH = 0x4
  config_0A00A0EC : ORIGIN = 0x0A00A0EC, LENGTH = 0x4
  config_0A00A0F0 : ORIGIN = 0x0A00A0F0, LENGTH = 0x4
  config_0A00A0F4 : ORIGIN = 0x0A00A0F4, LENGTH = 0x4
  config_0A00A0F8 : ORIGIN = 0x0A00A0F8, LENGTH = 0x4
  config_0A00A0FC : ORIGIN = 0x0A00A0FC, LENGTH = 0x4
  config_0A00A100 : ORIGIN = 0x0A00A100, LENGTH = 0x4
  config_0A00A110 : ORIGIN = 0x0A00A110, LENGTH = 0x4
  config_0A00A114 : ORIGIN = 0x0A00A114, LENGTH = 0x4
  config_0A00A118 : ORIGIN = 0x0A00A118, LENGTH = 0x4
  config_0A00A11C : ORIGIN = 0x0A00A11C, LENGTH = 0x4
  config_0A00A120 : ORIGIN = 0x0A00A120, LENGTH = 0x4

}

/* Variables used by FreeRTOS-MPU. */
_Privileged_Functions_Region_Size = 32768;
_Privileged_Data_Region_Size = 4096;

__FLASH_segment_start__ = ORIGIN( rom );
__FLASH_segment_end__ = __FLASH_segment_start__ + ROM_LENGTH;

__privileged_functions_start__ = ORIGIN( rom );
__privileged_functions_end__ = __privileged_functions_start__ + _Privileged_Functions_Region_Size;

__SRAM_segment_start__ = ORIGIN( ram );
__SRAM_segment_end__ = __SRAM_segment_start__ + LENGTH( ram );

__privileged_data_start__ = ORIGIN( ram );
__privileged_data_end__ = ORIGIN( ram ) + _Privileged_Data_Region_Size;
/*************************************************************************
 * Output region definitions.
 * CODE_REGION defines the output region for .text/.rodata.
 * DATA_REGION defines the output region for .data/.bss
 * VECTOR_REGION defines the output region for .vectors.
 *
 * CODE_REGION defaults to 'rom', if rom is present (non-zero length),
 * and 'ram' otherwise.
 * N.B. The BFA will still allocate code to any MEMORY named 'rom' regardless
 * of CODE_REGION's value. If you wish to use rom for something else please
 * rename the MEMORY entry.
 * DATA_REGION defaults to 'ram', which must be present.
 * VECTOR_REGION defaults to CODE_REGION, unless 'boot_rom' is present.
 */
#ifndef CODE_REGION
# if ROM_LENGTH > 0
#   define CODE_REGION rom
# else
#   define CODE_REGION ram
# endif
#endif
#ifndef DATA_REGION
# define DATA_REGION ram
#endif
#ifndef VECTOR_REGION
# define VECTOR_REGION boot_rom
#endif

__rom_end = ORIGIN(rom) + LENGTH(rom);
__ram_end = ORIGIN(ram) + LENGTH(ram);

/*************************************************************************
 * Section Definitions - Map input sections to output sections
 *************************************************************************/
SECTIONS
{
    .config_0A000000 : {
      KEEP(*(.config_0A000000))
    } > config_0A000000
    .config_0A000020 : {
      KEEP(*(.config_0A000020))
    } > config_0A000020
    .config_0A000040 : {
      KEEP(*(.config_0A000040))
    } > config_0A000040
    .config_0A000044 : {
      KEEP(*(.config_0A000044))
    } > config_0A000044
    .config_0A000048 : {
      KEEP(*(.config_0A000048))
    } > config_0A000048
    .config_0A00004C : {
      KEEP(*(.config_0A00004C))
    } > config_0A00004C
    .config_0A000054 : {
      KEEP(*(.config_0A000054))
    } > config_0A000054
    .config_0A000058 : {
      KEEP(*(.config_0A000058))
    } > config_0A000058
    .config_0A00005C : {
      KEEP(*(.config_0A00005C))
    } > config_0A00005C
    .config_0A000060 : {
      KEEP(*(.config_0A000060))
    } > config_0A000060
    .config_0A000064 : {
      KEEP(*(.config_0A000064))
    } > config_0A000064
    .config_0A000080 : {
      KEEP(*(.config_0A000080))
    } > config_0A000080
    .config_0A0000A0 : {
      KEEP(*(.config_0A0000A0))
    } > config_0A0000A0
    .config_0A002000 : {
      KEEP(*(.config_0A002000))
    } > config_0A002000
    .config_0A002004 : {
      KEEP(*(.config_0A002004))
    } > config_0A002004
    .config_0A002008 : {
      KEEP(*(.config_0A002008))
    } > config_0A002008
    .config_0A002080 : {
      KEEP(*(.config_0A002080))
    } > config_0A002080
    .config_0A002084 : {
      KEEP(*(.config_0A002084))
    } > config_0A002084
    .config_0A002088 : {
      KEEP(*(.config_0A002088))
    } > config_0A002088
    .config_0A00208C : {
      KEEP(*(.config_0A00208C))
    } > config_0A00208C
    .config_0A002090 : {
      KEEP(*(.config_0A002090))
    } > config_0A002090
    .config_0A002094 : {
      KEEP(*(.config_0A002094))
    } > config_0A002094
    .config_0A002098 : {
      KEEP(*(.config_0A002098))
    } > config_0A002098
    .config_0A00209C : {
      KEEP(*(.config_0A00209C))
    } > config_0A00209C
    .config_0A0020A0 : {
      KEEP(*(.config_0A0020A0))
    } > config_0A0020A0
    .config_0A0020A4 : {
      KEEP(*(.config_0A0020A4))
    } > config_0A0020A4
    .config_0A0020A8 : {
      KEEP(*(.config_0A0020A8))
    } > config_0A0020A8
    .config_0A0020AC : {
      KEEP(*(.config_0A0020AC))
    } > config_0A0020AC
    .config_0A0020B0 : {
      KEEP(*(.config_0A0020B0))
    } > config_0A0020B0
    .config_0A0020B4 : {
      KEEP(*(.config_0A0020B4))
    } > config_0A0020B4
    .config_0A0020B8 : {
      KEEP(*(.config_0A0020B8))
    } > config_0A0020B8
    .config_0A0020BC : {
      KEEP(*(.config_0A0020BC))
    } > config_0A0020BC
    .config_0A0020C0 : {
      KEEP(*(.config_0A0020C0))
    } > config_0A0020C0
    .config_0A0020C4 : {
      KEEP(*(.config_0A0020C4))
    } > config_0A0020C4
    .config_0A0020C8 : {
      KEEP(*(.config_0A0020C8))
    } > config_0A0020C8
    .config_0A0020CC : {
      KEEP(*(.config_0A0020CC))
    } > config_0A0020CC
    .config_0A0020D0 : {
      KEEP(*(.config_0A0020D0))
    } > config_0A0020D0
    .config_0A0020D4 : {
      KEEP(*(.config_0A0020D4))
    } > config_0A0020D4
    .config_0A0020D8 : {
      KEEP(*(.config_0A0020D8))
    } > config_0A0020D8
    .config_0A0020DC : {
      KEEP(*(.config_0A0020DC))
    } > config_0A0020DC
    .config_0A0020E0 : {
      KEEP(*(.config_0A0020E0))
    } > config_0A0020E0
    .config_0A0020E4 : {
      KEEP(*(.config_0A0020E4))
    } > config_0A0020E4
    .config_0A0020E8 : {
      KEEP(*(.config_0A0020E8))
    } > config_0A0020E8
    .config_0A0020EC : {
      KEEP(*(.config_0A0020EC))
    } > config_0A0020EC
    .config_0A0020F0 : {
      KEEP(*(.config_0A0020F0))
    } > config_0A0020F0
    .config_0A0020F4 : {
      KEEP(*(.config_0A0020F4))
    } > config_0A0020F4
    .config_0A0020F8 : {
      KEEP(*(.config_0A0020F8))
    } > config_0A0020F8
    .config_0A0020FC : {
      KEEP(*(.config_0A0020FC))
    } > config_0A0020FC
    .config_0A002100 : {
      KEEP(*(.config_0A002100))
    } > config_0A002100
    .config_0A002110 : {
      KEEP(*(.config_0A002110))
    } > config_0A002110
    .config_0A002114 : {
      KEEP(*(.config_0A002114))
    } > config_0A002114
    .config_0A002118 : {
      KEEP(*(.config_0A002118))
    } > config_0A002118
    .config_0A00211C : {
      KEEP(*(.config_0A00211C))
    } > config_0A00211C
    .config_0A002120 : {
      KEEP(*(.config_0A002120))
    } > config_0A002120
    .config_0A008000 : {
      KEEP(*(.config_0A008000))
    } > config_0A008000
    .config_0A008020 : {
      KEEP(*(.config_0A008020))
    } > config_0A008020
    .config_0A008040 : {
      KEEP(*(.config_0A008040))
    } > config_0A008040
    .config_0A008044 : {
      KEEP(*(.config_0A008044))
    } > config_0A008044
    .config_0A008048 : {
      KEEP(*(.config_0A008048))
    } > config_0A008048
    .config_0A00804C : {
      KEEP(*(.config_0A00804C))
    } > config_0A00804C
    .config_0A008054 : {
      KEEP(*(.config_0A008054))
    } > config_0A008054
    .config_0A008058 : {
      KEEP(*(.config_0A008058))
    } > config_0A008058
    .config_0A00805C : {
      KEEP(*(.config_0A00805C))
    } > config_0A00805C
    .config_0A008060 : {
      KEEP(*(.config_0A008060))
    } > config_0A008060
    .config_0A008064 : {
      KEEP(*(.config_0A008064))
    } > config_0A008064
    .config_0A008080 : {
      KEEP(*(.config_0A008080))
    } > config_0A008080
    .config_0A0080A0 : {
      KEEP(*(.config_0A0080A0))
    } > config_0A0080A0
    .config_0A00A000 : {
      KEEP(*(.config_0A00A000))
    } > config_0A00A000
    .config_0A00A004 : {
      KEEP(*(.config_0A00A004))
    } > config_0A00A004
    .config_0A00A008 : {
      KEEP(*(.config_0A00A008))
    } > config_0A00A008
    .config_0A00A080 : {
      KEEP(*(.config_0A00A080))
    } > config_0A00A080
    .config_0A00A084 : {
      KEEP(*(.config_0A00A084))
    } > config_0A00A084
    .config_0A00A088 : {
      KEEP(*(.config_0A00A088))
    } > config_0A00A088
    .config_0A00A08C : {
      KEEP(*(.config_0A00A08C))
    } > config_0A00A08C
    .config_0A00A090 : {
      KEEP(*(.config_0A00A090))
    } > config_0A00A090
    .config_0A00A094 : {
      KEEP(*(.config_0A00A094))
    } > config_0A00A094
    .config_0A00A098 : {
      KEEP(*(.config_0A00A098))
    } > config_0A00A098
    .config_0A00A09C : {
      KEEP(*(.config_0A00A09C))
    } > config_0A00A09C
    .config_0A00A0A0 : {
      KEEP(*(.config_0A00A0A0))
    } > config_0A00A0A0
    .config_0A00A0A4 : {
      KEEP(*(.config_0A00A0A4))
    } > config_0A00A0A4
    .config_0A00A0A8 : {
      KEEP(*(.config_0A00A0A8))
    } > config_0A00A0A8
    .config_0A00A0AC : {
      KEEP(*(.config_0A00A0AC))
    } > config_0A00A0AC
    .config_0A00A0B0 : {
      KEEP(*(.config_0A00A0B0))
    } > config_0A00A0B0
    .config_0A00A0B4 : {
      KEEP(*(.config_0A00A0B4))
    } > config_0A00A0B4
    .config_0A00A0B8 : {
      KEEP(*(.config_0A00A0B8))
    } > config_0A00A0B8
    .config_0A00A0BC : {
      KEEP(*(.config_0A00A0BC))
    } > config_0A00A0BC
    .config_0A00A0C0 : {
      KEEP(*(.config_0A00A0C0))
    } > config_0A00A0C0
    .config_0A00A0C4 : {
      KEEP(*(.config_0A00A0C4))
    } > config_0A00A0C4
    .config_0A00A0C8 : {
      KEEP(*(.config_0A00A0C8))
    } > config_0A00A0C8
    .config_0A00A0CC : {
      KEEP(*(.config_0A00A0CC))
    } > config_0A00A0CC
    .config_0A00A0D0 : {
      KEEP(*(.config_0A00A0D0))
    } > config_0A00A0D0
    .config_0A00A0D4 : {
      KEEP(*(.config_0A00A0D4))
    } > config_0A00A0D4
    .config_0A00A0D8 : {
      KEEP(*(.config_0A00A0D8))
    } > config_0A00A0D8
    .config_0A00A0DC : {
      KEEP(*(.config_0A00A0DC))
    } > config_0A00A0DC
    .config_0A00A0E0 : {
      KEEP(*(.config_0A00A0E0))
    } > config_0A00A0E0
    .config_0A00A0E4 : {
      KEEP(*(.config_0A00A0E4))
    } > config_0A00A0E4
    .config_0A00A0E8 : {
      KEEP(*(.config_0A00A0E8))
    } > config_0A00A0E8
    .config_0A00A0EC : {
      KEEP(*(.config_0A00A0EC))
    } > config_0A00A0EC
    .config_0A00A0F0 : {
      KEEP(*(.config_0A00A0F0))
    } > config_0A00A0F0
    .config_0A00A0F4 : {
      KEEP(*(.config_0A00A0F4))
    } > config_0A00A0F4
    .config_0A00A0F8 : {
      KEEP(*(.config_0A00A0F8))
    } > config_0A00A0F8
    .config_0A00A0FC : {
      KEEP(*(.config_0A00A0FC))
    } > config_0A00A0FC
    .config_0A00A100 : {
      KEEP(*(.config_0A00A100))
    } > config_0A00A100
    .config_0A00A110 : {
      KEEP(*(.config_0A00A110))
    } > config_0A00A110
    .config_0A00A114 : {
      KEEP(*(.config_0A00A114))
    } > config_0A00A114
    .config_0A00A118 : {
      KEEP(*(.config_0A00A118))
    } > config_0A00A118
    .config_0A00A11C : {
      KEEP(*(.config_0A00A11C))
    } > config_0A00A11C
    .config_0A00A120 : {
      KEEP(*(.config_0A00A120))
    } > config_0A00A120

    /*
     * The linker moves the .vectors section into itcm when itcm is
     * enabled via the -mitcm option, but only when this .vectors output
     * section exists in the linker script.
     */
    .vectors :
    {
        . = ALIGN(4);
        _sfixed = .;
        KEEP(*(.vectors .vectors.* .vectors_default .vectors_default.*))
        KEEP(*(.isr_vector))
        KEEP(*(.reset*))
        KEEP(*(.after_vectors))
    } > VECTOR_REGION

    .privileged_functions :
    {
        . = ALIGN(4);
        *(privileged_functions privileged_functions.*)

        /* Non privileged code is after _Privileged_Functions_Region_Size. */
        __privileged_functions_actual_end__ = .;

        /*If it is zero, then exit the linker with an error code, and print message*/
        ASSERT(!(__privileged_functions_actual_end__ > _Privileged_Functions_Region_Size), "privileged_functions exceeded size defined by the _Privileged_Functions_Region_Size macro");

        . = _Privileged_Functions_Region_Size;

    } > CODE_REGION

    /* FreeRTOS System calls - Section needs to be 32 byte aligned to satisfy
     * MPU requirements. */
    .freertos_system_calls : ALIGN(32)
    {
        . = ALIGN(32);
        __syscalls_flash_start__ = .;
        *(freertos_system_calls freertos_system_calls.*)
        . = ALIGN(32);
        /* End address must be the last address in the region, therefore, -1. */
        __syscalls_flash_actual_end__ = .;
        __syscalls_flash_end__ = . - 1;
    } > CODE_REGION

    /*
     * Code Sections - Note that standard input sections such as
     * *(.text), *(.text.*), *(.rodata), & *(.rodata.*)
     * are not mapped here. The best-fit allocator locates them,
     * so that input sections may flow around absolute sections
     * as needed.
     */
    .text :
    {
        . = ALIGN(4);
        *(.glue_7t) *(.glue_7)
        *(.gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)

        /* Support C constructors, and C destructors in both user code
           and the C library. This also provides support for C++ code. */
        . = ALIGN(4);
        KEEP(*(.init))
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(.preinit_array))
        __preinit_array_end = .;

        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;

        . = ALIGN(0x4);
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))

        . = ALIGN(4);
        KEEP(*(.fini))

        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;

        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))

        . = ALIGN(4);
        _efixed = .;            /* End of text section */
    } > CODE_REGION

    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > CODE_REGION
    PROVIDE_HIDDEN (__exidx_end = .);

    . = ALIGN(4);
    _etext = .;

    privileged_data :
    {
        *(privileged_data.*)
        /* Non kernel data is kept out of the first _Privileged_Data_Region_Size
        bytes of SRAM. */
        __privileged_data_actual_end__ = .;
        . = _Privileged_Data_Region_Size;
    } > ram


    /*
     *  Align here to ensure that the .bss section occupies space up to
     *  _end.  Align after .bss to ensure correct alignment even if the
     *  .bss section disappears because there are no input sections.
     *
     *  Note that input sections named .bss* are no longer mapped here.
     *  The best-fit allocator locates them, so that they may flow
     *  around absolute sections as needed.
     */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        _sbss = . ;
        _szero = .;
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
        _ebss = . ;
        _ezero = .;
    } > DATA_REGION

    . = ALIGN(4);
    _end = . ;
    _ram_end_ = ORIGIN(ram) + LENGTH(ram) -1 ;

}

