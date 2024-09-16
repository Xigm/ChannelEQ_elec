import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
from interpolador import interpoladorGold
import numpy as np
# import oct2py

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

    values_re = []
    values_im = []
    values_i = []
    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    await RisingEdge(dut.clk)

    dut.rst.value = 0
    dut.valid.value = 1
    dut.inf_re.value = 90
    dut.inf_im.value = 79
    dut.sup_re.value = 100
    dut.sup_im.value = 400

    for i in range(14):
        await Timer(2, units="ns")
        values_re.append(dut.estim_re.value)
        values_im.append(dut.estim_im.value)
        values_i.append(dut.i.value)
        print(dut.estim_valid.value)
        dut.valid.value = 0

    print(values_re)
    print(values_im)

    for value in values_re:
        print(int(value))

    for value in values_im:
        print(int(value))

    for value in values_i:
        print(int(value))