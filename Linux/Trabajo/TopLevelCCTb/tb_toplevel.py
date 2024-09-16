import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from oct2py import octave
from numpy.linalg import norm

maxCyclesMaster = 1800
currentCycle = 0
useCarrierMaster = 1705

skip1 = False
skip2 = False
skip3 = False
skip4 = False

def fromsigned2int(bits,base):
    v = base**np.arange(bits.shape[1],0,-1)
    v[0] = -v[0]
    return np.sum(bits*np.kron(np.ones((bits.shape[0],1)),v),axis=1)

# much much faster (halves time to compute)
def fromsigned2intv2(bits):
    return np.array([value.signed_integer for value in bits])

def NMSE(x,y):
    return 10*np.log10((norm(x-y))/len(x))

# using norm instead of square
def RMSE(x,y):
    return 10*np.log10(np.sqrt(norm(((x-y)))/len(x)))

def MAE(x,y):
    return np.mean(np.abs(x-y))

async def generate_clock(dut):
    """Generate clock pulses."""
    global maxCyclesMaster,currentCycle
    for cycle in range(maxCyclesMaster):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        currentCycle += 1


@cocotb.test(skip = skip1)
async def testIfWorks(dut):
    global maxCyclesMaster,currentCycle

    maxCycles = maxCyclesMaster

    out_re = []
    out_im = []
    pilotos_re = []
    pilotos_im = []
    # PRBS.m was define for old PRBS mode
    goldenSignos = octave.PRBS(1,1705*(20))[0,:]

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    await RisingEdge(dut.clk)

    dut.y_re.value = int(10*goldenSignos[0])
    dut.y_im.value = int(10*goldenSignos[0])
    dut.y_valid.value = 1
    dut.rst.value = 0

    # akward how it does not show errors if using for in range (fixed (-1)*piltoo >= -piloto)
    # for i in range(200):
    #     await RisingEdge(dut.clk)
    #     dut._log.info('CLK')

    i = 0
    j = 0
    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        # dut._log.info("CLK")

        if i >= 142:
            i = 142

        if j%12 == 0:

            piloto_re = int(np.random.rand()*200*goldenSignos[j+12])
            piloto_im = int(np.random.rand()*200*goldenSignos[j+12])

            dut.y_re.value = piloto_re
            dut.y_im.value = piloto_im

            pilotos_re.append(piloto_re*goldenSignos[j+12])
            pilotos_im.append(piloto_im*goldenSignos[j+12])

            i += 1

        try:
            int(dut.out_re.value)
            int(dut.out_im.value)
        except:
            pass
        else:
            out_re.append(int(dut.out_re.value))
            out_im.append(int(dut.out_im.value))

        j += 1

    # print(out_re.shape)
    plt.plot(out_re)
    plt.plot(np.arange(27,(len(pilotos_re))*12,12),pilotos_re[:-2])
    plt.xlim([300, 600])
    plt.savefig('imgs/pilotos.png')
    plt.close()

@cocotb.test(skip = skip2)
async def testReset(dut):
    global maxCyclesMaster,currentCycle

    maxCycles = maxCyclesMaster


    currentCycle = 0
    out_re = []
    out_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,1705)[0,:]

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    await RisingEdge(dut.clk)

    dut.y_re.value = int(10*goldenSignos[0])
    dut.y_im.value = int(10*goldenSignos[0])
    dut.y_valid.value = 1
    dut.rst.value = 0

    # akward how it does not show errors if using for in range (fixed (-1)*piltoo >= -piloto)
    # for i in range(200):
    #     await RisingEdge(dut.clk)
    #     dut._log.info('CLK')

    i = 0
    j = 0
    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        # dut._log.info("CLK")

        if i >= 142:
            i = 142

        if j%12 == 0:

            piloto_re = int(np.random.rand()*200*goldenSignos[i])
            piloto_im = int(np.random.rand()*200*goldenSignos[i])

            dut.y_re.value = piloto_re
            dut.y_im.value = piloto_im

            pilotos_re.append(piloto_re*goldenSignos[i])
            pilotos_im.append(piloto_im*goldenSignos[i])

            i += 1

        try:
            int(dut.out_re.value)
            int(dut.out_im.value)
        except:
            pass
        else:
            out_re.append(int(dut.out_re.value))
            out_im.append(int(dut.out_im.value))

        j += 1

    # print(out_re.shape)
    plt.plot(out_re)
    plt.plot(np.arange(27,(len(pilotos_re))*12,12),pilotos_re[:-2])
    plt.savefig('imgs/pilotos_rst.png')
    plt.xlim([0, 1705])
    plt.close()

@cocotb.test(skip = skip3)
async def testVsOctaveMode2(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster

    mode = 2
    CONSTEL = '16QAM'   # Constelación utilizada BPSK, QPSK, 16QAM
    SNR = 60
    noiseON = 1
    canalON = 1
    NUM_SYMB = 1
    SEED = 100

    maxCycles = maxCyclesMaster*int(mode/2)
    useCarrier = useCarrierMaster*int(mode/2)

    octave.addpath('../../../Matlab/OctaveIt')
    muestras, hest, v, PRBS_matlab = octave.GoldenChannelEstim(mode, CONSTEL, SNR, noiseON, canalON,NUM_SYMB, SEED,nout=4)
    
    muestras = np.array(muestras)
    hest = np.array(hest)
    v = np.array(v)
    PRBS_matlab = np.array(PRBS_matlab)[0,:]

    print(muestras.shape)
    print(hest.shape)
    print(v.shape)
    print("Shape prbs matlab",PRBS_matlab.shape)
    
    escala = 10-np.ceil(np.log2(max([max(abs(muestras.real)),max(abs(muestras.imag))]).astype(int))+1)
    print("Escalado = 2**%d" % int(escala))
    muestras = muestras*(2**escala)
    
    muestras_re = np.squeeze(np.real(muestras).astype(int)).tolist()
    muestras_im = np.squeeze(np.imag(muestras).astype(int)).tolist()


    currentCycle = 0
    out_re = []
    out_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,useCarrier*20)[0,:]
    goldenSignos = np.array(goldenSignos)

    ## Data generated, start clk

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    # await RisingEdge(dut.clk)

    # dut.y_re.value = muestras_re[0]
    # dut.y_im.value = muestras_im[0]
    # dut.y_valid.value = 1
    # dut.rst.value = 0

    # akward how it does not show errors if using for in range (fixed (-1)*piltoo >= -piloto)
    # for i in range(200):
    #     await RisingEdge(dut.clk)
    #     dut._log.info('CLK')

    i = 0
    j = 0
    while currentCycle < maxCyclesMaster-1:
        await RisingEdge(dut.clk)
        # dut._log.info("CLK")

        if i >= 142*int(mode/2):
            i = 142*int(mode/2)-1

        if j >= useCarrier-1:
            j = useCarrier-1
            dut.y_valid.value = 0

        piloto_re = muestras_re[j]
        piloto_im = muestras_im[j]

        # dut.y_re.value = piloto_re
        # dut.y_im.value = piloto_im

        dut.y_re.value = piloto_re
        dut.y_im.value = piloto_im
        dut.y_valid.value = 1
        dut.rst.value = 0

        if j%12 == 0:

            pilotos_re.append(piloto_re*goldenSignos[j])
            pilotos_im.append(piloto_im*goldenSignos[j])

            i += 1

        try:
            int(dut.out_re.value)
            int(dut.out_im.value)
        except:
            pass
        else:
            # black magic C_{2}^{N}=2^{n}-N
            out_re.append(dut.out_re.value)
            out_im.append(dut.out_im.value)

        j += 1
  
    out_re_int = fromsigned2intv2(out_re[3:useCarrier+3])
    out_im_int = fromsigned2intv2(out_im[3:useCarrier+3])
    # print(out_re_int.shape)
    # print(np.real(v)[:,0].shape)
    # corr_re = sum((out_re_int/(np.mean(out_re_int)))*(np.real(v)[:,0]/(np.mean(np.real(v)[:,0]))))
    # corr_im = sum((out_im_int/(np.mean(out_im_int)))*(np.imag(v)[:,0]/(np.mean(np.imag(v)[:,0]))))
    

    # print("Correlación re ",corr_re)
    # print("Correlación im ",corr_im)

    N = np.squeeze(out_re).shape[0]
    plt.figure(figsize=(16, 9), dpi=100)
    plt.subplot(211)
    plt.plot(out_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(12,(len(pilotos_re))*12,12),pilotos_re[:-1])
    plt.xlim([0, 1705])
    plt.title('Parte real')
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.subplot(212)
    plt.plot(out_im_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(12,(len(pilotos_im))*12,12),pilotos_im[:-1])
    plt.xlim([0, 1705])
    plt.title('Parte imaginaria')
    plt.savefig('imgs/vsOctave2.png')
    plt.close()

    # plt.plot(np.sqrt(np.abs(out_re_int**2)+np.abs(out_im_int**2))/norm(np.sqrt(np.abs(out_re_int**2)+np.abs(out_im_int**2))))
    # plt.title("Comparación con matlab")
    # plt.plot(np.sqrt(2)*(2**escala)*np.abs(v[:N])/norm(np.sqrt(2)*(2**escala)*np.abs(v[:N])))
    # plt.savefig('imgs/absvsoctave2.png')
    # plt.close()

    out_re_norm = out_re_int[12:]/norm(out_re_int[12:])
    out_im_norm = out_im_int[12:]/norm(out_im_int[12:])
    hest_re_norm = v.real[:len(out_re_norm)]/norm(v.real[:len(out_re_norm)])
    hest_im_norm = v.imag[:len(out_im_norm)]/norm(v.imag[:len(out_im_norm)])
    out_norm = (out_re_norm + 1j*out_im_norm)/norm((out_re_norm + 1j*out_im_norm))
    hest_norm = (hest_re_norm + 1j*hest_im_norm)/norm(hest_re_norm + 1j*hest_im_norm)

    plt.plot(out_re_norm)
    plt.plot(hest_re_norm)
    plt.show()
    NMSEcomplex = NMSE(out_norm,hest_norm)
    print("NMSE real flat :",NMSE(out_re_norm,hest_re_norm))
    print("NMSE imag flat :",NMSE(out_im_norm,hest_im_norm))
    print("RMSE real flat :",RMSE(out_re_norm,hest_re_norm))
    print("RMSE imag flat :",RMSE(out_im_norm,hest_im_norm))
    print("MAE real flat :",MAE(out_re_norm,hest_re_norm))
    print("MAE imag flat :",MAE(out_im_norm,hest_im_norm))

    print("NMSE complex flat :",NMSEcomplex)
    print("RMSE complex flat :",RMSE(out_norm,hest_norm))
    print("MAE complex flat :",MAE(out_norm,hest_norm))


    # plt.plot(np.sqrt((np.square(out_re_int)+np.sign(out_im_int)*np.square(out_im_int)).astype(float)))
    # plt.title("Comparación con matlab")
    # plt.plot(np.sqrt(2)*(2**escala)*np.abs(v[:N]))
    # plt.show()

    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()

@cocotb.test(skip = skip4)
async def testVsOctaveMode8(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster

    mode = 8
    CONSTEL = '16QAM'   # Constelación utilizada BPSK, QPSK, 16QAM
    SNR = 60
    noiseON = 1
    canalON = 1
    NUM_SYMB = 1
    SEED = 100

    maxCycles = maxCyclesMaster*int(mode/2)
    maxCyclesMaster = maxCyclesMaster*int(mode/2)
    useCarrier = useCarrierMaster*int(mode/2)

    octave.addpath('../../../Matlab/OctaveIt')
    muestras, hest, v, PRBS_matlab = octave.GoldenChannelEstim(mode, CONSTEL, SNR, noiseON, canalON,NUM_SYMB, SEED,nout=4)
    
    muestras = np.array(muestras)
    hest = np.array(hest)
    v = np.array(v)
    PRBS_matlab = np.array(PRBS_matlab)[0,:]

    print(muestras.shape)
    print(hest.shape)
    print(v.shape)
    print("Shape prbs matlab",PRBS_matlab.shape)
    
    escala = 10-np.ceil(np.log2(max([max(abs(muestras.real)),max(abs(muestras.imag))]).astype(int))+1)
    print("Escalado = 2**%d" % int(escala))
    muestras = muestras*(2**escala)
    
    muestras_re = np.squeeze(np.real(muestras).astype(int)).tolist()
    muestras_im = np.squeeze(np.imag(muestras).astype(int)).tolist()


    currentCycle = 0
    out_re = []
    out_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,useCarrier*80)[0,:]
    goldenSignos = np.array(goldenSignos)

    ## Data generated, start clk

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    # await RisingEdge(dut.clk)

    # dut.y_re.value = muestras_re[0]
    # dut.y_im.value = muestras_im[0]
    # dut.y_valid.value = 1
    # dut.rst.value = 0

    # akward how it does not show errors if using for in range (fixed (-1)*piltoo >= -piloto)
    # for i in range(200):
    #     await RisingEdge(dut.clk)
    #     dut._log.info('CLK')

    i = 0
    j = 0
    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        # dut._log.info("CLK")

        if i >= 142*int(mode/2):
            i = 142*int(mode/2)-1

        piloto_re = muestras_re[i]
        piloto_im = muestras_im[i]

        # dut.y_re.value = piloto_re
        # dut.y_im.value = piloto_im

        dut.y_re.value = piloto_re
        dut.y_im.value = piloto_im
        dut.y_valid.value = 1
        dut.rst.value = 0

        if j%12 == 0:

            pilotos_re.append(piloto_re*goldenSignos[j])
            pilotos_im.append(piloto_im*goldenSignos[j])

            i += 1

        try:
            int(dut.out_re.value)
            int(dut.out_im.value)
        except:
            pass
        else:
            # black magic C_{2}^{N}=2^{n}-N
            out_re.append(dut.out_re.value)
            out_im.append(dut.out_im.value)

        j += 1

    # out_re_int = fromsigned2int(np.squeeze(out_re)[:useCarrier],2)
    # out_im_int = fromsigned2int(np.squeeze(out_im)[:useCarrier],2)   
    out_re_int = fromsigned2intv2(out_re[3:useCarrier+3])
    out_im_int = fromsigned2intv2(out_im[3:useCarrier+3])
    # print(out_re_int.shape)
    # print(np.real(v)[:,0].shape)
    # corr_re = sum((out_re_int[3:]/(np.mean(out_re_int)))*(np.real(v)[:,0]/(np.mean(np.real(v)[:,0]))))
    # corr_im = sum((out_im_int[3:]/(np.mean(out_im_int)))*(np.imag(v)[:,0]/(np.mean(np.imag(v)[:,0]))))
    

    # print("Correlación re ",corr_re)
    # print("Correlación im ",corr_im)

    N = np.squeeze(out_re).shape[0]
    plt.figure(figsize=(16, 9), dpi=100)
    plt.subplot(211)
    plt.plot(out_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(12,(len(pilotos_re))*12,12),pilotos_re[:-1])
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.xlim([0,1705*4])
    plt.title('Parte real')
    plt.subplot(212)
    plt.plot(out_im_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(12,(len(pilotos_im))*12,12),pilotos_im[:-1])
    plt.xlim([0,1705*4])
    plt.title('Parte imaginaria')
    plt.savefig('imgs/vsOctave8.png')
    plt.close()
    
    # np.save('dataabs.npy',[out_re_int,out_im_int,v])

    # plt.plot((np.abs(out_re_int)+np.abs(out_im_int)))
    # plt.title("Comparación con matlab")
    # plt.plot(np.sqrt(2)*(2**escala)*np.abs(v[:N]))
    # plt.savefig('imgs/absvsoctave8.png')
    # plt.close()


    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()