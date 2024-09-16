# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def my_first_test(dut):
    """Try accessing the design."""

    for cycle in range(10):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

    dut._log.info("my_signal_1 is %s", dut.signo.value)
    # assert dut.my_signal_2.value[0] == 0, "my_signal_2[0] is not 0!"


# test_my_design.py (extended)

import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
import matplotlib.pyplot as plt


async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(100):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")


@cocotb.test()
async def my_second_test(dut):
    """Try accessing the design."""

    signos = []

    clockcr = await cocotb.start(generate_clock(dut))  # run the clock "in the background"

    dut.rst.value = 1
    dut.ena.value = 0

    await Timer(5, units="ns")  # wait a bit (of time, not a '0' or '1')

    dut.rst.value = 0
    dut.ena.value = 1

    for cycle in range(70):
        await FallingEdge(dut.clk)  # wait for falling edge/"negedge"
        # dut._log.info("cuentavalues int is %s", int(dut.signo.value))
        signos.append(int(dut.signo.value))

    dut._log.info(signos)
    plt.stem(signos)
    plt.show()


    # assert dut.my_signal_2.value[0] == 0, "my_signal_2[0] is not 0!"
