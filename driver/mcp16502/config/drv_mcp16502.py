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
import inspect
import sys
import logging

from os import pardir
from os.path import join, abspath, dirname, normpath
from collections import OrderedDict

import __builtin__
__builtin__.Database = Database
__builtin__.Log = Log

# Ensure __file__ is defined for path calculations (important for Harmony scripting)
if '__file__' not in locals():
    __file__ = normpath(abspath(inspect.currentframe().f_code.co_filename))

# Add the custom Harmony 3 Python packages directory to sys.path
sys.path.append(normpath(join(__file__, pardir, pardir, pardir, pardir, 'py_packages')))
# import h3_classes as h3c  # REMOVED

# If CAbstractComponent is not needed, remove inheritance or replace with object
class C_DRV_MCP16502(object):
    """
    Harmony 3 scripting component for the MCP16502 PMIC driver.
    """

    # Define available PMIC ports and their display names
    PMIC_PORTS = OrderedDict([
        ("PMIC_BUCK1", "BUCK1"),
        ("PMIC_BUCK2", "BUCK2"),
        ("PMIC_BUCK3", "BUCK3"),
        ("PMIC_BUCK4", "BUCK4"),
        ("PMIC_LDO1", "LDO1"),
        ("PMIC_LDO2", "LDO2")
    ])
    PMIC_PORTS_DEFAULT_INDEX = 3  # Default: BUCK4 (0-based index)

    def __init__(self, dependencies=None):
        self.dependencies = dependencies or []
        self.component = None

    def instantiate_component(self, component):
        self.component = component
        self.create_ui()
        self.create_files()
        self.after_create()

    def finalize_component(self, component):
        pass  # Implement as needed

    def destroy_component(self, component):
        pass  # Implement as needed

    def create_ui(self):
        """
        Create UI symbols for the MCP16502 driver configuration in MHC.
        """
        # Allows user to specify I2C device address
        self.i2c_address = self.component.createHexSymbol("DRV_MCP16502_I2C_ADDRESS", None)
        self.i2c_address.setLabel("I2C address")
        self.i2c_address.setDefaultValue(0x5B)
        self.i2c_address.setMin(0x00)
        self.i2c_address.setMax(0x7F)

        # KeyValueSet for CPU port
        self.cpu_port = self.component.createKeyValueSetSymbol("DRV_MCP16502_cpu_port", None)
        self.cpu_port.setLabel("PMIC port supplying CPU power")
        self.cpu_port.setOutputMode("Key")
        self.cpu_port.setDisplayMode("Value")
        self.cpu_port.setDefaultValue(self.PMIC_PORTS_DEFAULT_INDEX)  # Default to BUCK4
        for k, v in self.PMIC_PORTS.items():
            self.cpu_port.addKey(k, v, "PMIC port is %s" % v)

        # Option to enable UNIT TESTS
        self.mcp_unittest = self.component.createBooleanSymbol("DRV_MCP16502_mcp_unittest", None)
        self.mcp_unittest.setLabel("Add MCP16502 Unit Tests")
        self.mcp_unittest.setDefaultValue(False)
        self.mcp_unittest.setDescription("Add all functions needed for unit tests.")

    def create_files(self):
        """
        Create source/header and system files for the MCP16502 driver.
        """
        # Template and destination paths for generated files
        template_dir = join("driver", "mcp16502", "templates")
        dst_path = join("driver", "mcp16502")
        prj_path = join("config", Variables.get("__CONFIGURATION_NAME"), dst_path)

        # Generate header file from template
        header_file = self.component.createFileSymbol("MSCP16502_HEADER", None)
        header_file.setMarkup(True)
        header_file.setSourcePath(join(template_dir, "mcp16502.h.ftl"))
        header_file.setOutputName("mcp16502.h")
        header_file.setDestPath(dst_path)
        header_file.setProjectPath(prj_path)
        header_file.setType("HEADER")
        header_file.setOverwrite(True)

        # Generate source file from template
        source_file = self.component.createFileSymbol("MSCP16502_SOURCE", None)
        source_file.setMarkup(True)
        source_file.setSourcePath(join(template_dir, "mcp16502.c.ftl"))
        source_file.setOutputName("mcp16502.c")
        source_file.setDestPath(dst_path)
        source_file.setProjectPath(prj_path)
        source_file.setType("SOURCE")
        source_file.setOverwrite(True)

        # Add include to system definitions header
        system_def_inc_file = self.component.createListEntrySymbol("MCP16502_SYS_DEF_INC", None)
        system_def_inc_file.setTarget("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
        system_def_inc_file.addValue('#include "driver/mcp16502/mcp16502.h"')
        system_def_inc_file.setVisible(False)

    def after_create(self):
        """
        Ensure I2C driver is in Synchronous mode for MCP16502 operation.
        """
        try:
            # Get the I2C driver component
            i2c_comp = Database.getComponentByID("drv_i2c")
            if i2c_comp is not None:
                # Get the I2C mode symbol
                sym = i2c_comp.getSymbolByID("DRV_I2C_MODE")
                # Set to Synchronous if not already set
                if sym.getValue() != "Synchronous":
                    sym.setValue("Synchronous")
        except Exception as e:
            logging.error("Exception in after_create: %s", e, exc_info=True)
            # If you had a custom traceback reporter, call it here

local_component = C_DRV_MCP16502(["drv_i2c"])

# Harmony 3 scripting lifecycle hooks
def instantiateComponent(component):
    """
    Called by Harmony when the component is instantiated.
    """
    local_component.instantiate_component(component)

def finalizeComponent(component):
    """
    Called by Harmony when the component is finalized.
    """
    local_component.finalize_component(component)

def destroyComponent(component):
    """
    Called by Harmony when the component is destroyed.
    """
    local_component.destroy_component(component)
