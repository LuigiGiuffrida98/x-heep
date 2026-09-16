# Copyright 2026 EPFL
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author(s): Pacsort17, marinPh, David Mallasén
# Description: Base Peripherals (mandatory, always-on peripherals)

from bus_type import BusType
from address_map.address_region import AddressRegion
from peripherals.peripheral_domain import PeripheralDomain
from peripherals.abstractions import BasePeripheral
from copy import deepcopy
from typing import List, Optional

from .base_peripherals import (
    SOC_ctrl,
    Bootrom,
    SPI_flash,
    DMA,
    Power_manager,
    RV_timer_ao,
    Fast_intr_ctrl,
    Ext_peripheral,
    W25Q128JW_Controller,
)


class BasePeripheralDomain(PeripheralDomain):
    """
    Domain for base peripherals (always-on). All base peripherals must be added.
    """

    _peripheral_type = BasePeripheral

    # List of all base peripherals names

    def __init__(
        self,
        peripherals: Optional[List[BasePeripheral]] = None,
    ):
        """
        Initialize the base peripheral domain.

        At the beginning, there are no base peripherals. All missing peripherals will be added during build().

        The base peripheral domain is always-on: it belongs to no switchable power domain and is not clock gated.
        """
        super().__init__(
            power_domain=None,
            clock_gating=False,
            peripherals=peripherals,
            name="base_peripheral_domain",
        )

    def add_missing_peripherals(self):
        """
        Add missing peripherals to the domain.
        """
        # Add all default peripherals
        peripherals_to_add = [deepcopy(p) for p in self._default_base_peripherals]

        # Remove peripherals that are already in the domain to obtain the list of missing peripherals
        for peripheral in self._peripherals:
            for p in peripherals_to_add:
                if type(peripheral) == type(p):
                    peripherals_to_add.remove(p)
                    break

        # Add the missing peripherals
        for p in peripherals_to_add:
            self.add_peripheral(p)

    def validate(self, address_length: Optional[int] = None, bus_type: BusType = None):
        """
        Validate the base peripheral domain. Checks if all base peripherals are added, if they don't
        overlap and if their configuration paths are valid. Checks also if dmas are valid.

        :param int address_length: The length of the address space of the peripheral domain. If `None`, the length given at construction is used.
        :param BusType bus_type: The bus type of the system.
        """

        super().validate(address_length)
