import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
import numpy as np
# import oct2py

maxCycles = 100
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
    
    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    dut.valid.value = 0

    dut.inf_re.value = 10
    dut.inf_im.value = 10
    dut.sup_re.value = 10
    dut.sup_im.value = 10

    await RisingEdge(dut.clk)

    dut.rst.value = 0

    dut.valid.value = 1


    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.valid.value = 0

    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.valid.value = 1

    for _ in range(30):
        await RisingEdge(dut.clk)




@cocotb.test()
async def test2(dut):
    global maxCycles,currentCycle
    
    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    dut.valid.value = 0

    dut.inf_re.value = 10
    dut.inf_im.value = 10
    dut.sup_re.value = 10
    dut.sup_im.value = 10

    await RisingEdge(dut.clk)

    dut.rst.value = 0

    dut.valid.value = 1


    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.valid.value = 0

    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.valid.value = 1

