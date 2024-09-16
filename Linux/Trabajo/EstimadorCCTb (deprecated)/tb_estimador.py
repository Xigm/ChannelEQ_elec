import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
import numpy as np
# import oct2py

maxCycles = 20
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
    dut.y_re.value = 10
    dut.y_im.value = 10
    dut.y_valid.value = 0

    ## Valores indeterminados por ahora
    # dut.estim_re.value
    # dut.estim_im.value
    # print(dut.estim_valid.value)

    await RisingEdge(dut.clk)

    dut.rst.value = 0

    dut.y_valid.value = 1
    
    await RisingEdge(dut.clk) # contador = 11

    dut.y_valid.value = 1

    await RisingEdge(dut.clk) 

    dut.y_valid.value = 1

    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        dut._log.info('CLK')

    # for i in range(5):
        
    #     for j in range(13):
    #         # if j == 0:
    #         #     dut.y_valid.value = 1
    #         # else:
    #         #     dut.y_valid.value = 0

    #         await RisingEdge(dut.clk)

    # dut.y_valid.value = 1
    
    # while currentCycle < maxCycles-1:
    #     await RisingEdge(dut.clk)