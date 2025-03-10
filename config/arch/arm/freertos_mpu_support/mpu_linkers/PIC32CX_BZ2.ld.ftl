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
<#if LINKER_BOOTROM_ORIGIN??>
#ifndef BOOT_ROM_ORIGIN
#  define BOOT_ROM_ORIGIN 0x0
#endif
#ifndef BOOT_ROM_LENGTH
#  define BOOT_ROM_LENGTH ${LINKER_BOOTROM_LENGTH}
#elif (BOOT_ROM_LENGTH > ${LINKER_BOOTROM_LENGTH})
#  error BOOT_ROM_LENGTH is greater than the max size of ${LINKER_BOOTROM_LENGTH}
#endif
</#if>
#ifndef RAM_ORIGIN
#  define RAM_ORIGIN ${LINKER_RAM_ORIGIN}
#endif
#ifndef RAM_LENGTH
#  define RAM_LENGTH ${LINKER_RAM_LENGTH}
#elif (RAM_LENGTH > ${LINKER_RAM_LENGTH})
#  error RAM_LENGTH is greater than the max size of ${LINKER_RAM_LENGTH}
#endif
<#if LINKER_BACKUPRAM_ORIGIN??>
#ifndef BKUPRAM_ORIGIN
#  define BKUPRAM_ORIGIN ${LINKER_BACKUPRAM_ORIGIN}
#endif
#ifndef BKUPRAM_LENGTH
#  define BKUPRAM_LENGTH ${LINKER_BACKUPRAM_LENGTH}
#elif (BKUPRAM_LENGTH > ${LINKER_BACKUPRAM_LENGTH})
#  error BKUPRAM_LENGTH is greater than the max size of ${LINKER_BACKUPRAM_LENGTH}
#endif
</#if>



/*************************************************************************
 * Memory-Region Definitions
 * The MEMORY command describes the location and size of blocks of memory
 * on the target device. The command below uses the macros defined above.
 *************************************************************************/
MEMORY
{
  <#if LINKER_BOOTROM_ORIGIN??>boot_rom (LRX) : ORIGIN = BOOT_ROM_ORIGIN, LENGTH = BOOT_ROM_LENGTH</#if>
  rom (LRX) : ORIGIN = ROM_ORIGIN, LENGTH = ROM_LENGTH
  ram (WX!R) : ORIGIN = RAM_ORIGIN, LENGTH = RAM_LENGTH
  <#if LINKER_BACKUPRAM_ORIGIN??>bkupram : ORIGIN = BKUPRAM_ORIGIN, LENGTH = BKUPRAM_LENGTH</#if>
  
  config_00045E80 : ORIGIN = 0x00045E80, LENGTH = 0x4
  config_00045E84 : ORIGIN = 0x00045E84, LENGTH = 0x4
  config_00045E88 : ORIGIN = 0x00045E88, LENGTH = 0x4
  config_00045E8C : ORIGIN = 0x00045E8C, LENGTH = 0x4
  config_00045E90 : ORIGIN = 0x00045E90, LENGTH = 0x4
  config_00045E94 : ORIGIN = 0x00045E94, LENGTH = 0x4
  config_00045E98 : ORIGIN = 0x00045E98, LENGTH = 0x4
  config_00045E9C : ORIGIN = 0x00045E9C, LENGTH = 0x4
  config_00045EB0 : ORIGIN = 0x00045EB0, LENGTH = 0x4
  config_00045EB4 : ORIGIN = 0x00045EB4, LENGTH = 0x4
  config_00045EB8 : ORIGIN = 0x00045EB8, LENGTH = 0x4
  config_00045EBC : ORIGIN = 0x00045EBC, LENGTH = 0x4
  config_00045F80 : ORIGIN = 0x00045F80, LENGTH = 0x4
  config_00045F84 : ORIGIN = 0x00045F84, LENGTH = 0x4
  config_00045F88 : ORIGIN = 0x00045F88, LENGTH = 0x4
  config_00045F8C : ORIGIN = 0x00045F8C, LENGTH = 0x4
  config_00045F90 : ORIGIN = 0x00045F90, LENGTH = 0x4
  config_00045F94 : ORIGIN = 0x00045F94, LENGTH = 0x4
  config_00045F98 : ORIGIN = 0x00045F98, LENGTH = 0x4
  config_00045F9C : ORIGIN = 0x00045F9C, LENGTH = 0x4
  config_00045FB0 : ORIGIN = 0x00045FB0, LENGTH = 0x4
  config_00045FB4 : ORIGIN = 0x00045FB4, LENGTH = 0x4
  config_00045FB8 : ORIGIN = 0x00045FB8, LENGTH = 0x4
  config_00045FBC : ORIGIN = 0x00045FBC, LENGTH = 0x4
  
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
# define VECTOR_REGION <#if LINKER_BOOTROM_ORIGIN??>boot_rom<#else>CODE_REGION</#if>
#endif

__rom_end = ORIGIN(rom) + LENGTH(rom);
__ram_end = ORIGIN(ram) + LENGTH(ram);

/*************************************************************************
 * Section Definitions - Map input sections to output sections
 *************************************************************************/
SECTIONS
{
    .config_00045E80 : {
      KEEP(*(.config_00045E80))
    } > config_00045E80
    .config_00045E84 : {
      KEEP(*(.config_00045E84))
    } > config_00045E84
    .config_00045E88 : {
      KEEP(*(.config_00045E88))
    } > config_00045E88
    .config_00045E8C : {
      KEEP(*(.config_00045E8C))
    } > config_00045E8C
    .config_00045E90 : {
      KEEP(*(.config_00045E90))
    } > config_00045E90
    .config_00045E94 : {
      KEEP(*(.config_00045E94))
    } > config_00045E94
    .config_00045E98 : {
      KEEP(*(.config_00045E98))
    } > config_00045E98
    .config_00045E9C : {
      KEEP(*(.config_00045E9C))
    } > config_00045E9C
    .config_00045EB0 : {
      KEEP(*(.config_00045EB0))
    } > config_00045EB0
    .config_00045EB4 : {
      KEEP(*(.config_00045EB4))
    } > config_00045EB4
    .config_00045EB8 : {
      KEEP(*(.config_00045EB8))
    } > config_00045EB8
    .config_00045EBC : {
      KEEP(*(.config_00045EBC))
    } > config_00045EBC
    .config_00045F80 : {
      KEEP(*(.config_00045F80))
    } > config_00045F80
    .config_00045F84 : {
      KEEP(*(.config_00045F84))
    } > config_00045F84
    .config_00045F88 : {
      KEEP(*(.config_00045F88))
    } > config_00045F88
    .config_00045F8C : {
      KEEP(*(.config_00045F8C))
    } > config_00045F8C
    .config_00045F90 : {
      KEEP(*(.config_00045F90))
    } > config_00045F90
    .config_00045F94 : {
      KEEP(*(.config_00045F94))
    } > config_00045F94
    .config_00045F98 : {
      KEEP(*(.config_00045F98))
    } > config_00045F98
    .config_00045F9C : {
      KEEP(*(.config_00045F9C))
    } > config_00045F9C
    .config_00045FB0 : {
      KEEP(*(.config_00045FB0))
    } > config_00045FB0
    .config_00045FB4 : {
      KEEP(*(.config_00045FB4))
    } > config_00045FB4
    .config_00045FB8 : {
      KEEP(*(.config_00045FB8))
    } > config_00045FB8
    .config_00045FBC : {
      KEEP(*(.config_00045FBC))
    } > config_00045FBC
    
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
    
<#if LINKER_BACKUPRAM_ORIGIN??>    
    .bkupram_bss :
    {
        *(.bkupram_bss .bkupram_bss.*)
        *(.pbss .pbss.*)
    } > bkupram
</#if>
}

