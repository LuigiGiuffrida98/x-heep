from .cpu import CPU

class cv32e40x(CPU):

    def __init__(self, x_ext=None, num_mhpmcounters=None):
        super().__init__("cv32e40x")
        
        if x_ext is not None:
            if isinstance(x_ext, str):
                if x_ext.lower() not in ("true", "false", "1", "0"):
                    raise ValueError(f"X_EXT must be 0, 1, True, or False, got '{x_ext}'")
                x_ext = x_ext.lower() in ("true", "1")

            if x_ext not in (0, 1, True, False):
                raise ValueError(f"X_EXT must be 0, 1, True, or False, got '{x_ext}'")
            
            self.params["x_ext"] = bool(x_ext)
        
        if num_mhpmcounters is not None:
            if isinstance(num_mhpmcounters, str):
                try:
                    num_mhpmcounters = int(num_mhpmcounters.lower())
                except:
                    raise ValueError(
                        f"NUM_MHPMCOUNTERS must be a number, got '{num_mhpmcounters}'"
                    )

            if num_mhpmcounters < 0:
                raise ValueError(
                    f"NUM_MHPMCOUNTERS must be a positive number, got '{num_mhpmcounters}'"
                )

            self.params["num_mhpmcounters"] = num_mhpmcounters

    def get_sv_str(self, param_name: str) -> str:
        """
        Get the string representation of the param_name parameter to be used in the SystemVerilog templates.
        :param param_name: Name of the parameter.
        :return: String representation of the parameter for SystemVerilog or an empty string if not defined.
        """
        if not self.is_defined(param_name):
            return ""
        
        value = self.params.get(param_name)
        if param_name == "x_ext":
            return "1" if value else "0"
        elif param_name == "num_mhpmcounters":
            return str(value)
        else:
            return str(value)