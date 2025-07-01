# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""
import inspect
import sys
import logging

from os import pardir
from os.path import join, abspath, dirname, normpath

import __builtin__
__builtin__.Database = Database
__builtin__.Log = Log

# Ensure __file__ is defined for path manipulations
if '__file__' not in locals():
    __file__ = normpath(abspath(inspect.currentframe().f_code.co_filename))

# Add the 'py_packages' directory to sys.path for module imports
sys.path.append(normpath(join(__file__, pardir, pardir, pardir, pardir, 'py_packages')))

# --- h3_classes removed ---


class C_DVFS(object):  # Changed base class to object
    def __init__(self):
        # Initialize with a list of dependent components
        # If you need to keep track of dependent_components, add as an attribute
        self.dependent_components = ["temp_sensor", "secumod", "drv_i2c", "mcp16502"]

        # Default configuration constants as instance attributes
        self.TEMP_MONITORING_PERIOD_MS = 3000
        self.DVFS_TEMP_THRESHOLDS = [(-40, -30), (-25, -20), (-15, 0), (0, 80), (85, 90), (95, 100), (105, 110)]
        self.DVFS_VOLT_THRESHOLDS = [   1030,       1050,      1100,     1120,    1100,      1050,      1030]
        self.DVFS_FREQ_THRESHOLDS = [      0,          4,        11,       15,      11,         4,        0 ]
        self.DVFS_FREQ_VALUE      = [     50,        250,       600,      800,     600,       250,       50 ]
        self.unique_freq_values = sorted(set(self.DVFS_FREQ_VALUE))  # This removes duplicates and sorts the list
        self.CRITICAL_TEMP_THRESHOLD = [105, 120]  # Use integers
        self.CRITICAL_TEMP_BEHAVIOR = ["shutdown", "low power"]
        self.component = None
        self.pac_created = False

    def create_ui(self):
        """
        Create the user interface symbols for the DVFS component in the configuration tool.
        """
        # Option to enable PAC193x power monitor if available
        self.pac_enable = self.component.createBooleanSymbol("dvfs_pac_enable", None)
        self.pac_enable.setLabel("Enable access to PAC193x if available")
        self.pac_enable.setDefaultValue(False)
        self.pac_enable.setDependencies(self.activate_pac, ["dvfs_pac_enable"])

#        # Enable/disable thermal management service
#        self.enable_thermal_mngt = self.component.createBooleanSymbol("dvfs_enable_thermal_mngt", None)
#        self.enable_thermal_mngt.setLabel("Enable thermal management service")
#        self.enable_thermal_mngt.setDefaultValue(True)

        # Option to enable show thermal metadata
        self.show_metadata = self.component.createBooleanSymbol("dvfs_show_thermal_metadata", None)
        self.show_metadata.setLabel("Show thermal metadata")
        self.show_metadata.setDefaultValue(False)
        self.show_metadata.setDescription("Display the temperature and DVFS state periodically; useful for creating a CSV file.")
        self.show_metadata.setDependencies(self.show_metadata, ["dvfs_show_thermal_metadata"])

        # Set temperature monitoring period
        self.thermal_monitor_period_ms = self.component.createIntegerSymbol("dvfs_thermal_monitor_period_ms", None)
        self.thermal_monitor_period_ms.setLabel("Temperature monitoring period (in ms)")
        self.thermal_monitor_period_ms.setDescription("Specify the period in milliseconds the temperature is monitored and DVFS state is adjusted")
        self.thermal_monitor_period_ms.setMin(1000)
        self.thermal_monitor_period_ms.setMax(60000)
        self.thermal_monitor_period_ms.setDefaultValue(self.TEMP_MONITORING_PERIOD_MS)

        # --- DVFS neg3 thresholds  ---
        self.dvfs_neg3_menu = self.component.createMenuSymbol("dvfs_neg3_menu", None)
        self.dvfs_neg3_menu.setLabel("DVFS NEG3 thresholds")
        self.dvfs_neg3_menu.setDescription("Specify the temperature threshold for DVFS neg3")
        self.dvfs_neg3_menu.setVisible(True)

        self.dvfs_neg3_threshold_down = self.component.createIntegerSymbol("dvfs_neg3_threshold_down", self.dvfs_neg3_menu)
        self.dvfs_neg3_threshold_down.setLabel("Down temperature")
        self.dvfs_neg3_threshold_down.setDescription("Define the down threshold value for the DVFS neg3")
        self.dvfs_neg3_threshold_down.setReadOnly(True)
        self.dvfs_neg3_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[0][0])
        self.dvfs_neg3_threshold_down.setMin(-40)
        self.dvfs_neg3_threshold_down.setMax(110)

        self.dvfs_neg3_threshold_up = self.component.createIntegerSymbol("dvfs_neg3_threshold_up", self.dvfs_neg3_menu)
        self.dvfs_neg3_threshold_up.setLabel("Up temperature")
        self.dvfs_neg3_threshold_up.setDescription("Define the up threshold value for the DVFS 0")
        self.dvfs_neg3_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[0][1])
        self.dvfs_neg3_threshold_up.setMin(-40)
        self.dvfs_neg3_threshold_up.setMax(110)

        self.dvfs_neg3_frequency = self.component.createComboSymbol(
            "dvfs_neg3_frequency", self.dvfs_neg3_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_neg3_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_neg3_frequency.setDescription("Select frequency to be set for DVFS NEG3")
        self.dvfs_neg3_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[0]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_neg3_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_neg3_freq_threshold", self.dvfs_neg3_menu
        )
        self.dvfs_neg3_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_neg3_freq_threshold.setVisible(False)
        self.dvfs_neg3_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[0])

#        def update_freq_threshold(symbol, event):
#            freq_value = int(event["value"])
#            threshold = freq_to_threshold.get(freq_value, 0)
#            symbol.setValue(threshold, 2)  # 2 = force update

#        self.dvfs_neg3_freq_threshold.setDependencies(
#            update_freq_threshold, ["dvfs_neg3_frequency"]
#        )

        self.dvfs_neg3_voltage = self.component.createIntegerSymbol("dvfs_neg3_voltage", self.dvfs_neg3_menu)
        self.dvfs_neg3_voltage.setLabel("Set voltage in mV")
        self.dvfs_neg3_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_neg3_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[0])
        self.dvfs_neg3_voltage.setMin(1030)
        self.dvfs_neg3_voltage.setMax(1300)

        # --- DVFS neg2 thresholds ---
        self.dvfs_neg2_menu = self.component.createMenuSymbol("dvfs_neg2_menu", None)
        self.dvfs_neg2_menu.setLabel("DVFS NEG2 thresholds")
        self.dvfs_neg2_menu.setDescription("Specify the temperature threshold for DVFS neg2")
        self.dvfs_neg2_menu.setVisible(True)

        self.dvfs_neg2_threshold_down = self.component.createIntegerSymbol("dvfs_neg2_threshold_down", self.dvfs_neg2_menu)
        self.dvfs_neg2_threshold_down.setLabel("Down temperature")
        self.dvfs_neg2_threshold_down.setDescription("Define the down threshold value for the DVFS neg2")
        self.dvfs_neg2_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[1][0])
        self.dvfs_neg2_threshold_down.setMin(-40)
        self.dvfs_neg2_threshold_down.setMax(110)

        self.dvfs_neg2_threshold_up = self.component.createIntegerSymbol("dvfs_neg2_threshold_up", self.dvfs_neg2_menu)
        self.dvfs_neg2_threshold_up.setLabel("Up temperature")
        self.dvfs_neg2_threshold_up.setDescription("Define the up threshold value for the DVFS neg2")
        self.dvfs_neg2_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[1][1])
        self.dvfs_neg2_threshold_up.setMin(-40)
        self.dvfs_neg2_threshold_up.setMax(110)

        self.dvfs_neg2_frequency = self.component.createComboSymbol(
            "dvfs_neg2_frequency", self.dvfs_neg2_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_neg2_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_neg2_frequency.setDescription("Select frequency to be set for DVFS NEG2")
        self.dvfs_neg2_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[1]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_neg2_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_neg2_freq_threshold", self.dvfs_neg2_menu
        )
        self.dvfs_neg2_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_neg2_freq_threshold.setVisible(False)
        self.dvfs_neg2_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[1])

        self.dvfs_neg2_voltage = self.component.createIntegerSymbol("dvfs_neg2_voltage", self.dvfs_neg2_menu)
        self.dvfs_neg2_voltage.setLabel("Set voltage in mV")
        self.dvfs_neg2_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_neg2_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[1])
        self.dvfs_neg2_voltage.setMin(1030)
        self.dvfs_neg2_voltage.setMax(1300)

        # --- DVFS neg1 thresholds ---
        self.dvfs_neg1_menu = self.component.createMenuSymbol("dvfs_neg1_menu", None)
        self.dvfs_neg1_menu.setLabel("DVFS NEG1 thresholds")
        self.dvfs_neg1_menu.setDescription("Specify the temperature threshold for DVFS neg1")
        self.dvfs_neg1_menu.setVisible(True)

        self.dvfs_neg1_threshold_down = self.component.createIntegerSymbol("dvfs_neg1_threshold_down", self.dvfs_neg1_menu)
        self.dvfs_neg1_threshold_down.setLabel("Down temperature")
        self.dvfs_neg1_threshold_down.setDescription("Define the down threshold value for the DVFS neg1")
        self.dvfs_neg1_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[2][0])
        self.dvfs_neg1_threshold_down.setMin(-40)
        self.dvfs_neg1_threshold_down.setMax(110)

        self.dvfs_neg1_threshold_up = self.component.createIntegerSymbol("dvfs_neg1_threshold_up", self.dvfs_neg1_menu)
        self.dvfs_neg1_threshold_up.setLabel("Up temperature")
        self.dvfs_neg1_threshold_up.setDescription("Define the up threshold value for the DVFS neg1")
        self.dvfs_neg1_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[2][1])
        self.dvfs_neg1_threshold_up.setMin(-40)
        self.dvfs_neg1_threshold_up.setMax(110)

        self.dvfs_neg1_frequency = self.component.createComboSymbol(
            "dvfs_neg1_frequency", self.dvfs_neg1_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_neg1_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_neg1_frequency.setDescription("Select frequency to be set for DVFS NEG1")
        self.dvfs_neg1_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[2]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_neg1_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_neg1_freq_threshold", self.dvfs_neg1_menu
        )
        self.dvfs_neg1_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_neg1_freq_threshold.setVisible(False)
        self.dvfs_neg1_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[2])

        self.dvfs_neg1_voltage = self.component.createIntegerSymbol("dvfs_neg1_voltage", self.dvfs_neg1_menu)
        self.dvfs_neg1_voltage.setLabel("Set voltage in mV")
        self.dvfs_neg1_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_neg1_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[2])
        self.dvfs_neg1_voltage.setMin(1030)
        self.dvfs_neg1_voltage.setMax(1300)

        # --- DVFS 0 thresholds ---
        self.dvfs_0_menu = self.component.createMenuSymbol("dvfs_0_menu", None)
        self.dvfs_0_menu.setLabel("DVFS 0 thresholds")
        self.dvfs_0_menu.setDescription("Specify the temperature threshold for DVFS 0")

        self.dvfs_0_threshold_down = self.component.createIntegerSymbol("dvfs_0_threshold_down", self.dvfs_0_menu)
        self.dvfs_0_threshold_down.setLabel("Down temperature")
        self.dvfs_0_threshold_down.setDescription("Define the down threshold value for the DVFS 0")
        self.dvfs_0_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[3][0])
        self.dvfs_0_threshold_down.setDependencies(self.validate_dvfs_thresholds, ["dvfs_0_threshold_down"])
        self.dvfs_0_threshold_down.setMin(-40)
        self.dvfs_0_threshold_down.setMax(110)

        self.dvfs_0_threshold_up = self.component.createIntegerSymbol("dvfs_0_threshold_up", self.dvfs_0_menu)
        self.dvfs_0_threshold_up.setLabel("Up temperature")
        self.dvfs_0_threshold_up.setDescription("Define the up threshold value for the DVFS 0")
        self.dvfs_0_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[3][1])
        self.dvfs_0_threshold_up.setDependencies(self.validate_dvfs_thresholds, ["dvfs_0_threshold_up"])
        self.dvfs_0_threshold_up.setMin(-40)
        self.dvfs_0_threshold_up.setMax(110)

        self.dvfs_0_frequency = self.component.createComboSymbol(
            "dvfs_0_frequency", self.dvfs_0_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_0_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_0_frequency.setDescription("Select frequency to be set for DVFS 0")
        self.dvfs_0_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[3]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_0_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_0_freq_threshold", self.dvfs_0_menu
        )
        self.dvfs_0_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_0_freq_threshold.setVisible(False)
        self.dvfs_0_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[3])

        self.dvfs_0_voltage = self.component.createIntegerSymbol("dvfs_0_voltage", self.dvfs_0_menu)
        self.dvfs_0_voltage.setLabel("Set voltage in mV")
        self.dvfs_0_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_0_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[3])
        self.dvfs_0_voltage.setMin(1030)
        self.dvfs_0_voltage.setMax(1300)

       # --- DVFS 1 thresholds ---
        self.dvfs_1_menu = self.component.createMenuSymbol("dvfs_1_menu", None)
        self.dvfs_1_menu.setLabel("DVFS 1 thresholds")
        self.dvfs_1_menu.setDescription("Specify the temperature threshold for DVFS 1")

        self.dvfs_1_threshold_down = self.component.createIntegerSymbol("dvfs_1_threshold_down", self.dvfs_1_menu)
        self.dvfs_1_threshold_down.setLabel("Down temperature")
        self.dvfs_1_threshold_down.setDescription("Define the down threshold value for the DVFS 1")
        self.dvfs_1_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[4][0])
        self.dvfs_1_threshold_down.setDependencies(self.validate_dvfs_thresholds, ["dvfs_1_threshold_down"])
        self.dvfs_1_threshold_down.setMin(-40)
        self.dvfs_1_threshold_down.setMax(110)

        self.dvfs_1_threshold_up = self.component.createIntegerSymbol("dvfs_1_threshold_up", self.dvfs_1_menu)
        self.dvfs_1_threshold_up.setLabel("Up temperature")
        self.dvfs_1_threshold_up.setDescription("Define the up threshold value for the DVFS 1")
        self.dvfs_1_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[4][1])
        self.dvfs_1_threshold_up.setDependencies(self.validate_dvfs_thresholds, ["dvfs_1_threshold_up"])
        self.dvfs_1_threshold_up.setMin(-40)
        self.dvfs_1_threshold_up.setMax(110)

        self.dvfs_1_frequency = self.component.createComboSymbol(
            "dvfs_1_frequency", self.dvfs_1_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_1_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_1_frequency.setDescription("Select frequency to be set for DVFS 1")
        self.dvfs_1_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[4]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_1_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_1_freq_threshold", self.dvfs_1_menu
        )
        self.dvfs_1_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_1_freq_threshold.setVisible(False)
        self.dvfs_1_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[4])

        self.dvfs_1_voltage = self.component.createIntegerSymbol("dvfs_1_voltage", self.dvfs_1_menu)
        self.dvfs_1_voltage.setLabel("Set voltage in mV")
        self.dvfs_1_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_1_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[4])
        self.dvfs_1_voltage.setMin(1030)
        self.dvfs_1_voltage.setMax(1300)

        # --- DVFS 2 thresholds ---
        self.dvfs_2_menu = self.component.createMenuSymbol("dvfs_2_menu", None)
        self.dvfs_2_menu.setLabel("DVFS 2 thresholds")
        self.dvfs_2_menu.setDescription("Specify the temperature threshold for DVFS 2")

        self.dvfs_2_threshold_down = self.component.createIntegerSymbol("dvfs_2_threshold_down", self.dvfs_2_menu)
        self.dvfs_2_threshold_down.setLabel("Down temperature")
        self.dvfs_2_threshold_down.setDescription("Define the down threshold value for the DVFS 2")
        self.dvfs_2_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[5][0])
        self.dvfs_2_threshold_down.setDependencies(self.validate_dvfs_thresholds, ["dvfs_2_threshold_down"])
        self.dvfs_2_threshold_down.setMin(-40)
        self.dvfs_2_threshold_down.setMax(110)

        self.dvfs_2_threshold_up = self.component.createIntegerSymbol("dvfs_2_threshold_up", self.dvfs_2_menu)
        self.dvfs_2_threshold_up.setLabel("Up temperature")
        self.dvfs_2_threshold_up.setDescription("Define the up threshold value for the DVFS 2")
        self.dvfs_2_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[5][1])
        self.dvfs_2_threshold_up.setDependencies(self.validate_dvfs_thresholds, ["dvfs_2_threshold_up"])
        self.dvfs_2_threshold_up.setMin(-40)
        self.dvfs_2_threshold_up.setMax(110)

        self.dvfs_2_frequency = self.component.createComboSymbol(
            "dvfs_2_frequency", self.dvfs_2_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_2_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_2_frequency.setDescription("Select frequency to be set for DVFS 2")
        self.dvfs_2_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[5]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_2_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_2_freq_threshold", self.dvfs_2_menu
        )
        self.dvfs_2_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_2_freq_threshold.setVisible(False)
        self.dvfs_2_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[5])

        self.dvfs_2_voltage = self.component.createIntegerSymbol("dvfs_2_voltage", self.dvfs_2_menu)
        self.dvfs_2_voltage.setLabel("Set voltage in mV")
        self.dvfs_2_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_2_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[5])
        self.dvfs_2_voltage.setMin(1030)
        self.dvfs_2_voltage.setMax(1300)

        # --- DVFS 3 thresholds ---
        self.dvfs_3_menu = self.component.createMenuSymbol("dvfs_3_menu", None)
        self.dvfs_3_menu.setLabel("DVFS 3 thresholds")
        self.dvfs_3_menu.setDescription("Specify the temperature threshold for DVFS 3")

        self.dvfs_3_threshold_down = self.component.createIntegerSymbol("dvfs_3_threshold_down", self.dvfs_3_menu)
        self.dvfs_3_threshold_down.setLabel("Down temperature")
        self.dvfs_3_threshold_down.setDescription("Define the down threshold value for the DVFS 3")
        self.dvfs_3_threshold_down.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[6][0])
        self.dvfs_3_threshold_down.setDependencies(self.validate_dvfs_thresholds, ["dvfs_3_threshold_down"])
        self.dvfs_3_threshold_down.setMin(-40)
        self.dvfs_3_threshold_down.setMax(110)

        self.dvfs_3_threshold_up = self.component.createIntegerSymbol("dvfs_3_threshold_up", self.dvfs_3_menu)
        self.dvfs_3_threshold_up.setLabel("Up temperature")
        self.dvfs_3_threshold_up.setDescription("Define the up threshold value for the DVFS 3")
        self.dvfs_3_threshold_up.setDefaultValue(self.DVFS_TEMP_THRESHOLDS[6][1])
        self.dvfs_3_threshold_up.setDependencies(self.validate_dvfs_thresholds, ["dvfs_3_threshold_up"])
        self.dvfs_3_threshold_up.setMin(-40)
        self.dvfs_3_threshold_up.setMax(110)

        self.dvfs_3_frequency = self.component.createComboSymbol(
            "dvfs_3_frequency", self.dvfs_3_menu, [str(f) for f in self.unique_freq_values]
        )
        self.dvfs_3_frequency.setLabel("Set frequency (MHz)")
        self.dvfs_3_frequency.setDescription("Select frequency to be set for DVFS 3")
        self.dvfs_3_frequency.setDefaultValue(str(self.DVFS_FREQ_VALUE[6]))

        # Create a mapping from frequency value to threshold
        freq_to_threshold = dict(zip(self.DVFS_FREQ_VALUE, self.DVFS_FREQ_THRESHOLDS))

        self.dvfs_3_freq_threshold = self.component.createIntegerSymbol(
            "dvfs_3_freq_threshold", self.dvfs_3_menu
        )
        self.dvfs_3_freq_threshold.setLabel("Frequency Threshold (hidden)")
        self.dvfs_3_freq_threshold.setVisible(False)
        self.dvfs_3_freq_threshold.setDefaultValue(self.DVFS_FREQ_THRESHOLDS[6])

        self.dvfs_3_voltage = self.component.createIntegerSymbol("dvfs_3_voltage", self.dvfs_3_menu)
        self.dvfs_3_voltage.setLabel("Set voltage in mV")
        self.dvfs_3_voltage.setDescription("Define voltage to be set for DVFS <br>600MHz: 1030-1210mV<br>800MHz: 1120-1210mV<br>1GHz: 1220-1300mV")
        self.dvfs_3_voltage.setDefaultValue(self.DVFS_VOLT_THRESHOLDS[6])
        self.dvfs_3_voltage.setMin(1030)
        self.dvfs_3_voltage.setMax(1300)

        # --- Critical temperature threshold and behavior ---
        self.dvfs_critical_menu = self.component.createMenuSymbol("dvfs_critical_menu", None)
        self.dvfs_critical_menu.setLabel("DVFS critical")
        self.dvfs_critical_menu.setDescription("Specify behavior when critical temperature is reached")

        self.critical_temperature = self.component.createComboSymbol("critical_temperature", self.dvfs_critical_menu, [str(x) for x in self.CRITICAL_TEMP_THRESHOLD])
        self.critical_temperature.setLabel("Specify critical temperature value")
        self.critical_temperature.setDefaultValue(str(self.CRITICAL_TEMP_THRESHOLD[1]))
        self.critical_temperature.setDependencies(self.validate_dvfs_thresholds, ["critical_temperature"])

        self.behavior_when_critical = self.component.createComboSymbol("behavior_when_critical", self.dvfs_critical_menu, self.CRITICAL_TEMP_BEHAVIOR)
        self.behavior_when_critical.setLabel("CPU mode when temperature is critical")
        self.behavior_when_critical.setDefaultValue(self.CRITICAL_TEMP_BEHAVIOR[0])

    def create_files(self):
        """
        Create the necessary source and header files for the DVFS service.
        """
        template_dir = join("libraries", "dvfs", "templates")
        dst_path = join("library", "dvfs")
        prj_path = join("config", Variables.get("__CONFIGURATION_NAME"), dst_path)

        # Create header file from template
        header_file = self.component.createFileSymbol("SRV_THERMAL_MNGT_HEADER", None)
        header_file.setMarkup(True)
        header_file.setSourcePath(join(template_dir, "srv_dvfs.h.ftl"))
        header_file.setOutputName("srv_dvfs.h")
        header_file.setDestPath(dst_path)
        header_file.setProjectPath(prj_path)
        header_file.setType("HEADER")
        header_file.setOverwrite(True)

        # Create source file from template
        source_file = self.component.createFileSymbol("SRV_DVFS_SOURCE", None)
        source_file.setMarkup(True)
        source_file.setSourcePath(join(template_dir, "srv_dvfs.c.ftl"))
        source_file.setOutputName("srv_dvfs.c")
        source_file.setDestPath(dst_path)
        source_file.setProjectPath(prj_path)
        source_file.setType("SOURCE")
        source_file.setOverwrite(True)

        # Add include to system definitions
        sys_def_inc_file = self.component.createListEntrySymbol("SRV_DVFS_SYS_DEF_INC", None)
        sys_def_inc_file.setTarget("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
        sys_def_inc_file.addValue('#include "library/dvfs/srv_dvfs.h"')
        sys_def_inc_file.setVisible(False)

        # Add initialization call to system init
        sys_init_file = self.component.createListEntrySymbol("SRV_DVFS_SYS_INT", None)
        sys_init_file.setTarget("core.LIST_SYSTEM_INIT_C_INITIALIZE_MIDDLEWARE")
        sys_init_file.addValue('    DVFS_Initialize();')
        sys_init_file.setVisible(False)

        # Add task call to system tasks
        sys_call_file = self.component.createListEntrySymbol("SRV_DVFS_SYS_CALL", None)
        sys_call_file.setTarget("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
        sys_call_file.addValue('DVFS_Task();')
        sys_call_file.setVisible(False)


    def after_create(self):
        """
        Called after the component is created. Used to modify parameters of other components
        based on DVFS configuration.
        """
        # Modify parameters of the SECUMOD component
        secumod_comp = Database.getComponentByID("secumod")
        if secumod_comp is None:
            Database.activateComponents(["secumod"])
            secumod_comp = Database.getComponentByID("secumod")
            if secumod_comp is None:
                logging.warning("SECUMOD component not found; skipping SECUMOD configuration.")
                return
        
        # Set SECUMOD threshold to match critical temperature
        sym = secumod_comp.getSymbolByID("tpmh_threshold_value")
        sym.setValue(self.critical_temperature.getValue())

        # Enable SECUMOD normal mode and interrupt
        sym = secumod_comp.getSymbolByID("tpmh_normal_enable")
        sym.setValue(True)

        sym = secumod_comp.getSymbolByID("tpmh_normal_enable_interrupt")
        sym.setValue(True)

        # Modify parameters of the core component (to parametrize SECUMOD interrupt)
        core_comp = Database.getComponentByID("core")
        if core_comp is None:
            raise Exception("Failed to find external component 'core'")  # Replaced h3c.raise_exception

        sym = core_comp.getSymbolByID("SECUMOD_INTERRUPT_ENABLE")
        sym.setValue(True)

        sym = core_comp.getSymbolByID("SECUMOD_INTERRUPT_HANDLER")
        if sym.getValue() != "SECUMOD_Handler":
            sym.setValue("SECUMOD_Handler")

        # Modify parameters of the drv_i2c component
        i2c_comp = Database.getComponentByID("drv_i2c")
        if i2c_comp is not None:
            sym = i2c_comp.getSymbolByID("DRV_I2C_MODE")
            if sym.getValue() != "Synchronous":
                sym.setValue("Synchronous")

    def activate_pac(self, symbol, event):
        """
        Callback to activate or deactivate the PAC193x component based on user selection.
        """
        pac_id = "pac193x"
        if event["value"]:
            # Activate PAC193X if not already active
            if pac_id not in Database.getActiveComponentIDs():
                self.pac_created = True
                Database.activateComponents([pac_id])
        elif getattr(self, "pac_created", None):
            # Deactivate PAC193X if it was created by this script
            Database.deactivateComponents([pac_id])

    def validate_dvfs_thresholds(self, symbol, event):
        # Retrieve the initial 'up' and 'down' thresholds for DVFS index 0
        #prev_up_tshd = self.component.getSymbolByID("dvfs_0_threshold_up")
        #prev_down_tshd = self.component.getSymbolByID("dvfs_0_threshold_down")
        prev_up_tshd = self.dvfs_0_threshold_up
        prev_down_tshd = self.dvfs_0_threshold_down

        # Iterate through all DVFS temperature thresholds starting from index 1
        for i in range(1, len(self.DVFS_TEMP_THRESHOLDS)):
            # Retrieve the current 'up' and 'down' thresholds for DVFS index i
#            up_tshd = self.component.getSymbolByID("dvfs_%d_threshold_up" % i)
#            down_tshd = self.component.getSymbolByID("dvfs_%d_threshold_down" % i)
            up_tshd = getattr(self, "dvfs_%d_threshold_up" % i)
            down_tshd = getattr(self, "dvfs_%d_threshold_down" % i)

            # Check if the 'down' threshold is not less than the 'up' threshold for the current DVFS
            if down_tshd.getValue() >= up_tshd.getValue():
                raise Exception(
                    "Invalid temperature thresholds for DVFS %d: up threshold (%d) must be greater than down threshold (%d)" 
                    % (i, up_tshd.getValue(), down_tshd.getValue())
                )
            # Check if the current 'up' threshold is not greater than the previous 'up' threshold
            elif prev_up_tshd.getValue() >= up_tshd.getValue():
                raise Exception(
                    "Invalid temperature thresholds: up threshold of DVFS %d (%d) must be greater than up threshold of DVFS %d (%d)" 
                    % (i, up_tshd.getValue(), i-1, prev_up_tshd.getValue())
                )
            # Check if the current 'down' threshold is not greater than the previous 'down' threshold
            elif prev_down_tshd.getValue() >= down_tshd.getValue():
                raise Exception(
                    "Invalid temperature thresholds: up threshold of DVFS %d (%d) must be greater than up threshold of DVFS %d (%d)" 
                    % (i, up_tshd.getValue(), i-1, prev_up_tshd.getValue())
                )
            # Update previous thresholds for the next iteration
            prev_up_tshd = up_tshd
            prev_down_tshd = down_tshd

        # Retrieve the critical temperature threshold
#        critical_tshd = self.component.getSymbolByID("critical_temperature")
        critical_tshd = getattr(self, "critical_temperature")
        # Check if the last 'up' threshold is not greater than or equal to the critical threshold
        if prev_up_tshd.getValue() >= int(critical_tshd.getValue()):
            raise Exception(
                "Invalid temperature thresholds: down threshold of DVFS %d (%d) must be greater than down threshold of DVFS %d (%d)" 
                % (i, down_tshd.getValue(), i-1, prev_down_tshd.getValue())
            )
        else:
            # Log that the critical temperature threshold is valid
            logging.info("Critical temperature threshold (%s) is valid" % critical_tshd.getValue())

    def instantiate_component(self, component):
        self.component = component
        self.create_ui()
        self.create_files()
        self.after_create()

    def finalize_component(self, component):
        # Implement any cleanup or finalization logic if needed
        pass

    def destroy_component(self, component):
        # Implement any destruction logic if needed
        pass

# Instantiate the local component object
local_component = C_DVFS()

# Functions required by the configuration tool to instantiate/finalize/destroy the component
def instantiateComponent(component):
    local_component.instantiate_component(component)

def finalizeComponent(component):
    local_component.finalize_component(component)

def destroyComponent(component):
    local_component.destroy_component(component)
