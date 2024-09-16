import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
import numpy as np
# import oct2py

maxCycles = 50
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
    
    # ena_write = []
    # cuenta_master = []

    # dut.ADDR_WIDTH.value = 8

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    await RisingEdge(dut.clk)

    dut.ena.value = 1
    dut.rst.value = 0

    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        # cuenta_master.append(int(dut.counter1_1.cuenta.value))
        # ena_write.append(int(dut.ena_write.value))
        dut._log.info("CLK")

    # print(ena_write)
    # print(cuenta_master)

    # plt.plot(np.array(ena_write)*int(max(cuenta_master)))
    # plt.plot(cuenta_master)
    # plt.show()
