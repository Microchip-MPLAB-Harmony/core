# coding: utf-8
##############################################################################
# Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
#
# Subject to your compliance with these terms, you may use Microchip software
# and any derivatives exclusively with Microchip products. It is your
# responsibility to comply with third party license terms applicable to your
# use of third party software (including open source software) that may
# accompany Microchip software.
#
# THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
# EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
# WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
# PARTICULAR PURPOSE.
#
# IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
# INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
# WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
# BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
# FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
# ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
# THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
##############################################################################

# Import standard libraries for inspection, system operations, and logging
import inspect
import sys
import logging

# Import path manipulation utilities from os and os.path
from os import pardir
from os.path import join, abspath, dirname, normpath

# Expose Database and Log objects globally via __builtin__ (for legacy Python 2 compatibility)
import __builtin__
__builtin__.Database = Database
__builtin__.Log = Log

# Ensure __file__ is defined (useful when running in environments where it may not be set)
if '__file__' not in locals():
    __file__ = normpath(abspath(inspect.currentframe().f_code.co_filename))

# Add the 'py_packages' directory (three levels up) to sys.path for module imports
py_packages_path = normpath(join(dirname(__file__), pardir, pardir, pardir, 'py_packages'))
if py_packages_path not in sys.path:
    sys.path.append(py_packages_path)

class C_TEMP_SENSOR(object):
    """
    Handler class for the Temperature Sensor component.
    Responsible for file generation and configuration of dependencies.
    """
    def __init__(self, dependencies):
        self.dependencies = dependencies  # List of dependent components (e.g., ADC)
        self.ID = "C_TEMP_SENSOR"         # Unique identifier for this component
        self.component = None             # Will hold the reference to the instantiated component

    def create_files(self):
        """
        Create and configure the necessary source/header/template files for the temperature sensor driver.
        """
        template_dir = join("driver", "temp_sensor", "templates")
        dst_path = join("driver", "temp_sensor")
        prj_path = join("config", Variables.get("__CONFIGURATION_NAME"), dst_path)

        # Create header file symbol for the temperature sensor
        header_file = self.component.createFileSymbol("TEMP_SENSOR_HEADER", None)
        header_file.setMarkup(True)
        header_file.setSourcePath(join(template_dir, "temp_sensor.h.ftl"))
        header_file.setOutputName("temp_sensor.h")
        header_file.setDestPath(dst_path)
        header_file.setProjectPath(prj_path)
        header_file.setType("HEADER")
        header_file.setOverwrite(True)

        # Create source file symbol for the temperature sensor
        source_file = self.component.createFileSymbol("TEMP_SENSOR_SOURCE", None)
        source_file.setMarkup(True)
        source_file.setSourcePath(join(template_dir, "temp_sensor.c.ftl"))
        source_file.setOutputName("temp_sensor.c")
        source_file.setDestPath(dst_path)
        source_file.setProjectPath(prj_path)
        source_file.setType("SOURCE")
        source_file.setOverwrite(True)

        # Add include entry for the header file in the system definitions
        system_def_inc_file = self.component.createListEntrySymbol("TEMP_SENSOR_SYS_DEF_INC", None)
        system_def_inc_file.setTarget("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
        system_def_inc_file.addValue('#include "driver/temp_sensor/temp_sensor.h"')
        system_def_inc_file.setVisible(False)

        # Add initialization entry for the temperature sensor in system initialization
        sys_init_file = self.component.createListEntrySymbol("TEMP_SENSOR_SYS_INT", None)
        sys_init_file.setTarget("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
        sys_init_file.addValue('    TEMP_Initialize();')
        sys_init_file.setVisible(False)

    def after_create(self):
        """
        Perform post-creation configuration, such as enabling the correct ADC channel for the temperature sensor.
        """
        # Locate the ADC_CDR node in the ATDF to determine the number of ADC channels
        node = ATDF.getNode('/avr-tools-device-file/modules/module@[name="ADC"]/register-group/register@[name="ADC_CDR"]')
        if node is None:
            logging.error("ATDF node for ADC_CDR not found.")
            return
        nb_channels = node.getAttribute("count")
        if nb_channels is None:
            logging.error("Attribute 'count' not found in ADC_CDR node.")
            return
        temp_ch_id = int(nb_channels) - 1  # Use the last channel for temperature sensor

        # Get the ADC component and enable the temperature sensor channel
        adc_comp = Database.getComponentByID("adc")
        if adc_comp is None:
            Log.writeErrorMessage("Failed to find external component 'adc'")
            return
        sym = adc_comp.getSymbolByID("ADC_%d_CHER" % temp_ch_id)
        sym.setValue(True)
        logging.info("In '%s' component, modified parameter '%s' to '%s'" % (self.ID, sym.getLabel(), sym.getValue()))

    # Stub methods for component lifecycle management (can be extended as needed)
    def instantiate_component(self, component):
        self.component = component
        self.create_files()
        self.after_create()

    def finalize_component(self, component):
        # Add any finalization logic here if needed
        pass

    def destroy_component(self, component):
        # Add any destruction logic here if needed
        pass

# Instantiate the temperature sensor component handler with its dependencies
local_component = C_TEMP_SENSOR(["adc", "otpc"])

# Define the entry points expected by the framework for component lifecycle
def instantiateComponent(component):
    local_component.instantiate_component(component)

def finalizeComponent(component):
    local_component.finalize_component(component)

def destroyComponent(component):
    local_component.destroy_component(component)
