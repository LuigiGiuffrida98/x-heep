from .cv32e40p import cv32e40p


class cv32e40px(cv32e40p):

    def __init__(
        self,
        fpu=None,
        fpu_addmul_lat=None,
        fpu_others_lat=None,
        zfinx=None,
        corev_pulp=None,
        num_mhpmcounters=None,
        corev_x_if=None,
    ):
        super().__init__(
            fpu, fpu_addmul_lat, fpu_others_lat, zfinx, corev_pulp, num_mhpmcounters
        )
        self.name = "cv32e40px"

        if corev_x_if is not None:
            if isinstance(corev_x_if, str):
                if corev_x_if.lower() not in ("true", "false", "1", "0"):
                    raise ValueError(
                        f"COREV_X_IF must be 0, 1, True, or False, got '{corev_x_if}'"
                    )
                corev_x_if = corev_x_if.lower() in ("true", "1")

            if corev_x_if not in (0, 1, True, False):
                raise ValueError(
                    f"COREV_X_IF must be 0, 1, True, or False, got '{corev_x_if}'"
                )

            self.params["corev_x_if"] = bool(corev_x_if)

    def get_sv_str(self, param_name: str) -> str:
        """
        Get the SystemVerilog string representation of a parameter.
        :param param_name: Name of the parameter.
        :return: SystemVerilog string representation of the parameter.
        """
        if not self.is_defined(param_name):
            return ""

        value = self.params[param_name]
        if param_name == "corev_x_if":
            return "1" if value else "0"
        else:
            return super().get_sv_str(param_name)
