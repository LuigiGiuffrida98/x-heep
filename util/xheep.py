from system_gen.system import System
from system_gen.bus_type import BusType
from system_gen.memory_ss.memory_ss import MemorySS
from system_gen.peripherals.abstractions import PeripheralDomain
from system_gen.peripherals.base_peripherals_domain import BasePeripheralDomain
from system_gen.peripherals.user_peripherals_domain import UserPeripheralDomain
from system_gen.pads.PadRing import PadRing


class XHeep(System):
    """
    Represents the whole X-HEEP system.

    An instance of this class is passed to the mako templates.

    :param BusType bus_type: The bus type chosen for this mcu.
    :raise TypeError: when parameters are of incorrect type.
    """

    IL_COMPATIBLE_BUS_TYPES = [BusType.NtoM]
    """Constant set of bus types that support interleaved memory banks"""

    def __init__(
        self,
        bus_type: BusType,
    ):
        super().__init__()
        if not type(bus_type) is BusType:
            raise TypeError(
                f"XHeep.bus_type should be of type BusType not {type(self._bus_type)}"
            )

        self._bus_type: BusType = bus_type

        self._memory_ss = None

        self._padring: PadRing = None

    # ------------------------------------------------------------
    # Bus
    # ------------------------------------------------------------

    def set_bus_type(self, bus_type: BusType):
        """
        Sets the bus type of the system.

        :param BusType bus_type: The bus type to set.
        :raise TypeError: when bus_type is of incorrect type.
        """
        if not type(bus_type) is BusType:
            raise TypeError(
                f"XHeep.bus_type should be of type BusType not {type(self._bus_type)}"
            )
        self._bus_type = bus_type

    def bus_type(self) -> BusType:
        """
        :return: the configured bus type
        :rtype: BusType
        """
        return self._bus_type

    # ------------------------------------------------------------
    # Memory
    # ------------------------------------------------------------

    def set_memory_ss(self, memory_ss: MemorySS):
        """
        Sets the memory subsystem of the system.

        :param MemorySS memory_ss: The memory subsystem to set.
        :raise TypeError: when memory_ss is of incorrect type.
        """
        if not isinstance(memory_ss, MemorySS):
            raise TypeError(
                f"XHeep.memory_ss should be of type MemorySS not {type(self._memory_ss)}"
            )
        self._memory_ss = memory_ss

    def memory_ss(self) -> MemorySS:
        """
        :return: the configured memory subsystem
        :rtype: MemorySS
        """
        return self._memory_ss

    # ------------------------------------------------------------
    # Peripherals
    # ------------------------------------------------------------

    def are_base_peripherals_configured(self) -> bool:
        """
        :return: `True` if the base peripherals are configured, `False` otherwise.
        :rtype: bool
        """
        return self.has_peripheral_domain("base")

    def are_user_peripherals_configured(self) -> bool:
        """
        :return: `True` if the user peripherals are configured, `False` otherwise.
        :rtype: bool
        """
        return self.has_peripheral_domain("user")

    def are_peripherals_configured(self) -> bool:
        """
        :return: `True` if both base and user peripherals are configured, `False` otherwise.
        :rtype: bool
        """
        return (
            self.are_base_peripherals_configured()
            and self.are_user_peripherals_configured()
        )

    def add_peripheral_domain(self, domain: PeripheralDomain):
        """
        Add a peripheral domain to the system. XHeep expects base and user domains only.

        :param PeripheralDomain domain: The domain to add.
        """
        if isinstance(domain, BasePeripheralDomain):
            super().add_peripheral_domain(domain, name="base")
        elif isinstance(domain, UserPeripheralDomain):
            super().add_peripheral_domain(domain, name="user")
        else:
            raise ValueError(
                "Domain is neither a BasePeripheralDomain nor a UserPeripheralDomain"
            )

    def get_user_peripheral_domain(self):
        """
        Returns a deepcopy of the user peripheral domain.

        :return: The user peripheral domain.
        :rtype: UserPeripheralDomain
        """
        return self.get_peripheral_domain("user")

    def get_base_peripheral_domain(self):
        """
        Returns a deepcopy of the base peripheral domain.

        :return: The base peripheral domain.
        :rtype: BasePeripheralDomain
        """
        return self.get_peripheral_domain("base")

    # ------------------------------------------------------------
    # Build and Validate
    # ------------------------------------------------------------

    def build(self):
        """
        Makes the system ready to be used.
        """

        if self.memory_ss():
            self.memory_ss().build()
        for domain in self._peripheral_domains.values():
            domain.build()

    def validate(self) -> bool:
        """
        Does some basics checks on the configuration

        This should be called before using the XHeep object to generate the project.

        :return: the validity of the configuration
        :rtype: bool
        """
        if not self.cpu():
            print("A CPU must be configured")
            return False

        if not self.memory_ss():
            print("A memory subsystem must be configured")
            return False
        else:
            if not self.memory_ss().validate():
                return False
            if self.memory_ss().has_il_ram() and (
                self._bus_type not in self.IL_COMPATIBLE_BUS_TYPES
            ):
                raise RuntimeError(
                    f"This system has a {self._bus_type} bus, one of {self.IL_COMPATIBLE_BUS_TYPES} is required for interleaved memory"
                )

        # Check that each peripheral domain is valid
        ret = True
        for domain in self._peripheral_domains.values():
            domain.validate()

        # Check that peripherals domains do not overlap
        domains = [(name, domain) for name, domain in self._peripheral_domains.items()]
        domains.sort(key=lambda entry: entry[1].get_start_address())
        prev_name = None
        prev_end = None
        for name, domain in domains:
            start = domain.get_start_address()
            end = start + domain.get_length()
            if prev_end is not None and start < prev_end:
                print(
                    "The peripheral domain '{}' (starts at {:#08X}) overflows over '{}' (ends at {:#08X}).".format(
                        name, start, prev_name, prev_end
                    )
                )
                ret = False
            if prev_end is None or end > prev_end:
                prev_end = end
                prev_name = name

        if self.are_base_peripherals_configured():
            base_domain = self.get_base_peripheral_domain()
            if base_domain is not None and base_domain.get_start_address() < 0x10000:
                print(
                    "Always on peripheral start address must be greater than 0x10000, current address is {:#08X}.".format(
                        base_domain.get_start_address()
                    )
                )
                ret = False
        return ret
