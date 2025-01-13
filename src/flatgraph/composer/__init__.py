import warnings

import clingo

from .base import *
from .partial_order import *

ENCODING = "encodings/order_test.lp"


def compute_instance(instance_path: str):
    print(f"Computing {instance_path}")

    ctl = clingo.Control()
    ctl.load(ENCODING)
    ctl.load(instance_path)
    ctl.ground([("base", [])])

    with ctl.solve(yield_=True) as solve_handle:
        model = solve_handle.model()
        if model is None:
            warnings.warn("No model to solve")
            return
        model_atoms = {str(a) for a in model.symbols(atoms=True)}
        print(model_atoms)

        composer = ComposerPartialOrder(model_atoms)
        composer.compose()
