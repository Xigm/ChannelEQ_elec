import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
import numpy as np
# import oct2py

# basic cctb file

maxCycles = 120
currentCycle = 0

async def generate_clock(dut):
    """Generate clock pulses."""
    global maxCycles,currentCycle
    for cycle in range(maxCycles):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        currentCycle += 1


@cocotb.test()
async def test1(dut):
    global maxCycles,currentCycle
    values = []
    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    await RisingEdge(dut.clk)

    dut.ena.value = 1
    dut.rst.value = 0

    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        values.append(int(dut.cuenta))

    print(values)

