import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
import matplotlib.pyplot as plt
import oct2py

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(150):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")


@cocotb.test()
async def testOtave(dut):
    """Try accessing the design."""

    signos = []

    clockcr = await cocotb.start(generate_clock(dut))  # run the clock "in the background"

    dut.rst.value = 1
    dut.ena.value = 0
    await Timer(1,units="ps")
    print(dut.rst.value)
    await Timer(3, units="ns")  # wait a bit (of time, not a '0' or '1')
    dut.rst.value = 0
    dut.ena.value = 1

    for cycle in range(143):
        await FallingEdge(dut.clk)  # wait for falling edge/"negedge"
        # dut._log.info("cuentavalues int is %s", int(dut.signo.value))
        signos.append(int(dut.signo.value))

    from oct2py import octave
    goldenSignos = octave.PRBS(1,1705)
    goldenSignos = (goldenSignos[0,:]+1)/2
    # dut._log.info(signos)
    dut._log.info(goldenSignos.shape)
    # print(goldenSignos.shape)

    plt.subplot(211)
    plt.stem(signos)
    plt.subplot(212)
    plt.stem(goldenSignos)
    plt.show()