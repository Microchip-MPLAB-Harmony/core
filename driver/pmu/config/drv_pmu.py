# coding: utf-8
"""
Copyright (C) 2025, Microchip Technology Inc., and its subsidiaries. All rights reserved.

The software and documentation is provided by Microchip and its contributors "as is" and any express,
implied or statutory warranties, including, but not limited to, the implied warranties of merchantability,
fitness for a particular purpose and non-infringement of third party intellectual property rights are
disclaimed to the fullest extent permitted by law. In no event shall Microchip or its contributors be
liable for any direct, indirect, incidental, special,exemplary, or consequential damages (including,
but not limited to, procurement of substitute goods or services; loss of use, data, or profits;
or business interruption) however caused and on any theory of liability, whether in contract, strict liability,
or tort (including negligence or otherwise) arising in any way out of the use of the software and documentation,
even if advised of the possibility of such damage.

Except as expressly permitted hereunder and subject to the applicable license terms for any third-party software
incorporated in the software and any applicable open source software license terms, no license or other rights,
whether express or implied, are granted under any patent or other intellectual property rights of Microchip or any third party.
"""

# Import necessary modules for introspection, system operations, and path manipulations
import inspect
import sys
import __builtin__
from os.path import join, abspath, normpath, pardir

# Expose Harmony's Database and Log objects to the script's global namespace
__builtin__.Database = Database
__builtin__.Log = Log

# Ensure the special variable __file__ is defined for path manipulations
if '__file__' not in locals():
    # Get the absolute, normalized path of the current script file
    __file__ = normpath(abspath(inspect.currentframe().f_code.co_filename))

# Add the 'py_packages' directory (four levels up from this file) to sys.path for module imports
py_packages_path = normpath(join(__file__, pardir, pardir, pardir, pardir, 'py_packages'))
if py_packages_path not in sys.path:
    sys.path.append(py_packages_path)

class C_LIB_PMU(object):
    """
    Class to handle PMU (Power Management Unit) library file generation and component instantiation.
    """
    def __init__(self, args=None):
        # Store any arguments and initialize the component reference
        self.args = args
        self.component = None

    def create_files(self):
        """
        Create and configure the necessary PMU driver files and project entries.
        """
        # Define template and destination directories for PMU files
        template_dir = join("driver", "pmu", "templates")
        dst_path = join("driver", "pmu")
        # Retrieve the current configuration name from the Variables environment
        config_name = Variables.get("__CONFIGURATION_NAME")
        if config_name is None:
            # Warn and exit if configuration name is not set
            Log.writeWarningMessage("Warning: __CONFIGURATION_NAME is not set. Deferring file creation.")
            return
        # Construct the project path for the generated files
        prj_path = join("config", config_name, dst_path)

        # Create and configure the PMU header file symbol
        header_file = self.component.createFileSymbol("LIB_PMU_HEADER", None)
        header_file.setMarkup(True)
        header_file.setSourcePath(join(template_dir, "plib_pmu.h.ftl"))
        header_file.setOutputName("plib_pmu.h")
        header_file.setDestPath(dst_path)
        header_file.setProjectPath(prj_path)
        header_file.setType("HEADER")
        header_file.setOverwrite(True)

        # Create and configure the PMU source file symbol
        source_file = self.component.createFileSymbol("LIB_PMU_SOURCE", None)
        source_file.setMarkup(True)
        source_file.setSourcePath(join(template_dir, "plib_pmu.c.ftl"))
        source_file.setOutputName("plib_pmu.c")
        source_file.setDestPath(dst_path)
        source_file.setProjectPath(prj_path)
        source_file.setType("SOURCE")
        source_file.setOverwrite(True)

        # Add an include entry for the PMU header in the system definitions
        inc_def_file = self.component.createListEntrySymbol("LIB_PMU_SYS_DEF_INC", None)
        inc_def_file.setTarget("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
        inc_def_file.addValue('#include "driver/pmu/plib_pmu.h"')
        inc_def_file.setVisible(False)

        # Add initialization call to system init
        sys_init_file = self.component.createListEntrySymbol("LIB_PMU_SYS_DEF_INT", None)
        sys_init_file.setTarget("core.LIST_SYSTEM_INIT_C_INITIALIZE_MIDDLEWARE")
        sys_init_file.addValue('    PMU_Enable();')
        sys_init_file.setVisible(False)


    def instantiate_component(self, component):
        """
        Store the component reference and trigger file creation.
        """
        self.component = component
        self.create_files()

# Instantiate the component object at module level for possible later use
local_component = C_LIB_PMU()

def instantiateComponent(component):
    """
    Harmony framework entry point for component instantiation.
    """
    local_component.instantiate_component(component)
