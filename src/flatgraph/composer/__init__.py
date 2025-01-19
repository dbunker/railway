import warnings
import logging

import clingo

from .base import *
from .partial_order import *

ENCODING = "encodings/order_test.lp"
ENCODING_CONNECTIONS = "encodings/connection.lp"


def compute_instance(instance_path: str):
    ctl = clingo.Control(["--warn=none"])
    ctl.load(ENCODING)
    ctl.load(ENCODING_CONNECTIONS)
    ctl.load(instance_path)
    ctl.ground([("base", [])])

    logging.info("Find Partial Ordering")
    with ctl.solve(yield_=True) as solve_handle:
        model = solve_handle.model()
        if model is None:
            warnings.warn("No model to solve")
            return
        model_atoms = {str(a) for a in model.symbols(atoms=True)}
        composer = ComposerPartialOrder(model_atoms)
        composer.compose()
