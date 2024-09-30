from typing import Literal

units = {
    "us": 1e6,
    "ms": 1e3,
    "s": 1
}

def calc_sleep_2(a: int, b: int, output: Literal["us", "ms", "s"]) -> float:
    t =  (b * ((3 * a) + 1) + (3 * b) + 3) * 0.2e-6
    return t * units[output]
    