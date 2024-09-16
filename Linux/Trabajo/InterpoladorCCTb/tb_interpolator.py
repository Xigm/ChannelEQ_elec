import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from interpolador import interpoladorGold
import numpy as np

maxCycles = 200
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
    """Try accessing the design."""
    dataVer = np.zeros([144,2,2])
    await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    
    dut.rst.value = 1

    # await Timer(1, units="ps")  # wait a bit (of time, not a '0' or '1')
    
    await RisingEdge(dut.clk)
    print(dut.estim_re)
    print(dut.i)

    dut.rst.value = 0


    inf_re = int(np.round((np.random.rand())*2**9))
    inf_im = int(np.round((np.random.rand())*2**9))
    sup_re = int(np.round((np.random.rand())*2**9))
    sup_im = int(np.round((np.random.rand())*2**9))

    posPy = 0
    posVHDL = 0

    while currentCycle < maxCycles-12:
       
        dut.valid.value = 1
        dut.inf_re.value = inf_re
        dut.inf_im.value = inf_im
        dut.sup_re.value = sup_re
        dut.sup_im.value = sup_im
        
        
        for i in range(15):
            await RisingEdge(dut.clk)  # wait for falling edge/"negedge"
            estim_re_vhd,estim_im_vhd = dut.estim_re.value,dut.estim_im.value
            estim_re_py,estim_im_py = interpoladorGold(inf_re,inf_im,sup_re,sup_im,i)
            
            if not ((i < 0) or (i > 11)):
                dataVer[posPy,0,:] = np.array([estim_re_py,estim_im_py])
                posPy += 1

            if dut.estim_valid.value == 1:
                dataVer[posVHDL,1,:] = np.array([[int(estim_re_vhd),int(estim_im_vhd)]])
                posVHDL += 1

            if posVHDL >= 143:
                break

            dut._log.info("CLK\n")
            dut.valid.value = 0
 
            


        inf_re = sup_re
        inf_im = sup_im
        sup_re = int(np.round((np.random.rand())*2**9))
        sup_im = int(np.round((np.random.rand())*2**9))
        currentCycle += 1

    plt.subplot(221)
    plt.title("Real GOLD")
    plt.plot(dataVer[:,0,0])
    plt.subplot(222)
    plt.title("Imag GOLD")
    plt.plot(dataVer[:,0,1])
    plt.subplot(223)
    plt.title("Real VHDL")
    plt.plot(dataVer[:,1,0])
    plt.subplot(224)
    plt.title("Imag VHDL")
    plt.plot(dataVer[:,1,1])
    # plt.show()
    plt.savefig('imgs/interpolador_real_imag_sub_rand.png')
    # plt.close()

    plt.subplot(211)
    plt.title("Real")
    plt.plot(dataVer[:,0,0])
    plt.plot(dataVer[:,1,0])
    plt.subplot(212)
    plt.title("Imag")
    plt.plot(dataVer[:,0,1])
    plt.plot(dataVer[:,1,1])
    # plt.show()
    plt.savefig('imgs/interpolador_real_imag_sub_rand_superpuestas.png')
    # plt.close()