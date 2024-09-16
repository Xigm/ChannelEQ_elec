import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt
import numpy as np
# import oct2py

# this tb tests if the block works properly
# it main task is to serve pilots to the interpolator,
# but only pilots. All other samples must be isolated 
# from interpolator.

# this test has some interesting things.

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

    dut.write_enable.value = 0

    await RisingEdge(dut.clk)

    dut.rst.value = 0

    # while currentCycle < maxCycles-1:
    #     await RisingEdge(dut.clk)
    #     dut._log.info("CLK")

    # let some cylces run

    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.write_enable.value = 1

    dut.piloto_y_re.value = 10
    dut.piloto_y_im.value = 100
    
    # no PRBS needed
    dut.PRBS.value = 1

    for i in range(5):
        for j in range(12):
            await RisingEdge(dut.clk)

            if j == 11:
                dut.write_enable.value = 1
                dut.piloto_y_re.value = 10 + (i+1)*5
                dut.piloto_y_im.value = 100 + (i+1)*10
            else:
                dut.write_enable.value = 0
                dut.piloto_y_re.value = 69
                dut.piloto_y_im.value = 69

            # check if incorrect value is propagated

            # try avoids int(XXX) or int(uuu) case
            # this could be avoided by cocotb's 
            # resolve u, which would change u bit values to
            # one at our choice, but we would lose some sight of 
            # what is happening.
            try:
                int(dut.inf_re.value)
                int(dut.inf_im.value)
                int(dut.sup_re.value)
                int(dut.sup_im.value)
            except:
                pass
            else:
                # if pilots values are correctly casted into int, check if they got wrong values (samples values are represented by 69)
                if dut.inf_re.value == 69 or dut.inf_im.value == 69 or dut.sup_re.value == 69 or dut.sup_im.value == 69:        
                    raise "El valor incorrecto ha sido propagaddo!"

    # for _ in range(40):
    #     await RisingEdge(dut.clk)

