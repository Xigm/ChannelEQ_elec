import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
import numpy as np
from oct2py import octave

# main test of this block in fullSystem

maxCyclesMaster = 100
currentCycle = 0
# useCarrierMaster = 1705

# def fromsigned2int(bits,base):
#     v = base**np.arange(bits.shape[1],0,-1)
#     v[0] = -v[0]
#     return np.sum(bits*np.kron(np.ones((bits.shape[0],1)),v),axis=1)

async def generate_clock(dut):
    """Generate clock pulses."""
    global maxCyclesMaster,currentCycle
    for cycle in range(maxCyclesMaster):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        currentCycle += 1

@cocotb.test()
async def test1(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1
    dut.h_re.value = 10
    dut.h_im.value = 0
    dut.y_re.value = 100
    dut.y_im.value = 100

    while currentCycle < maxCyclesMaster-1:
        await RisingEdge(dut.clk)
        dut._log.info("CLK")

    
