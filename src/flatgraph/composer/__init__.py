import time
import warnings
import logging

import clingo

from .base import *
from .partial_order import *

ENCODING = "encodings/order_test.lp"
ENCODING_CONNECTIONS = "encodings/back_connections.lp"


def compute_instance(instance_path: str, timed: bool = False) -> None:
    start_t = time.perf_counter()
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
    end_t = time.perf_counter()
    if timed:
        print("[Time elapsed: %.4fs]" % (end_t - start_t))
