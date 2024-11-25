from typing import Literal

CLK_20HZ = 0.2e-6

units = {
    "us": 1e6,
    "ms": 1e3,
    "s": 1
}

def calc_sleep_2(a: int, b: int, output: Literal["us", "ms", "s"]) -> float:
    t =  (b * ((3 * a) + 1) + (3 * b) + 3) * 0.2e-6
    return t * units[output]
    
def calc_sleep_3(a: int, b: int, c: int, output: Literal["us", "ms", "s"]) -> float:
    t = c * (b * (a + 1) + (3 * b) + 1) + (3 * c) + 3
    return t * 0.2e-6 * units[output]

def calc_timer0(clock: float, pre: int, start_value: int, output: Literal["us", "ms", "s"] = "ms") -> int:
    return clock * pre * (255 - start_value) * units[output]

def calc_timer1(clock: float, pre: int, start_value: int, output: Literal["us", "ms", "s"] = "ms") -> int:
    return clock * pre * (65536 - start_value) * units[output]

def get_duty(percentage: int, pwm = 15_000) -> int:
    return (percentage * pwm) // 100
