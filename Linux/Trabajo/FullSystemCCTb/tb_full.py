import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
# import matplotlib
# matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from oct2py import octave
from numpy.linalg import norm

# some global vars
maxCyclesMaster = 1800
currentCycle = 0
useCarrierMaster = 1705

# define whether if the test is gonna be run.
skipTest1 = False
skipTest2 = False
skipTest3 = False
skipTest4 = False
skipTest5 = False
skipTest6 = False

# this function will be very useful as it will convert from cocotbs signals return value
# to int. It is design to hanlde bits representing signed of any size.
def fromsigned2int(bits,base):
    v = base**np.arange(bits.shape[1],0,-1)
    v[0] = -v[0]
    return np.sum(bits*np.kron(np.ones((bits.shape[0],1)),v),axis=1)

# much much faster (halves time to compute)
def fromsigned2intv2(bits):
    return np.array([value.signed_integer for value in bits])

def MSE(x,y):
    return 10*np.log10((norm(x-y)/len(x)))

# using norm instead of mean square
def RMSE(x,y):
    return 10*np.log10(np.sqrt((norm(((x-y)))/len(x))))

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


@cocotb.test(skip = skipTest1)
async def testFlatChannel(dut):
    # global makes the function able to access vars from outside
    global maxCyclesMaster,currentCycle
    maxCycles = maxCyclesMaster
    out_re = []
    out_im = []
    signos = []
    L = 50 # segments of 12 data
    data_re = (np.round(np.random.rand(12*L)))*200-100
    data_im = (np.round(np.random.rand(12*L)))*200-100
    pilotos_re = data_re[::12]/data_re[::12]*100
    pilotos_im = data_im[::12]/data_im[::12]*0
    data_re[::12] = pilotos_re
    data_im[::12] = pilotos_im

    # workdir for the octave codes
    octave.addpath('../../../Matlab/OctaveIt')
    # octave engine runs the PRBS file 
    goldenSignos = octave.PRBS(1,200*L+10)[0,:]
    # goldenSignos = np.ones(12*L)
    pilotos_re = pilotos_re*goldenSignos[:len(pilotos_re)]

    await cocotb.start(generate_clock(dut))

    dut.rst.value = 1

    await RisingEdge(dut.clk)

    dut.y_re.value = int(data_re[0])*int(goldenSignos[0])
    dut.y_im.value = int(data_im[0])*int(goldenSignos[0])
    signos.append(dut.estimador.prbs_inst.signo)
    dut.y_valid.value = 1
    dut.rst.value = 0

    # akward how it does not show errors if using for in range (fixed (-1)*piltoo >= -piloto)
    # for i in range(200):
    #     await RisingEdge(dut.clk)
    #     dut._log.info('CLK')

    i = 0
    j = 1
    while currentCycle < L*12:
        await RisingEdge(dut.clk)
        # dut._log.info("CLK")

        # protection, if number of pilots are exceeded
        if i >= 142:
            i = 142
        
        if j >= L*12-1:
            j = L*12-1

        if j%12 == 0:   

            # random data is generated, PRBS is applied
            # data is generated only each 12 cycles, so pilots are only taken into account
            # this would be a problem if FSM would not work as expected, but, as 
            # its functionability has been assured by its own verification, there is no problem


            # piloto_re = int(np.random.rand()*100*goldenSignos[i])
            # piloto_im = int(np.random.rand()*100*goldenSignos[i])

            dut.y_re.value = int(data_re[j])*int(goldenSignos[j])
            dut.y_im.value = int(data_im[j])*int(goldenSignos[j])
            signos.append(int(dut.estimador.prbs_inst.signo))
            # print(signos)

            # pilotos_re.append(piloto_re*goldenSignos[i])
            # pilotos_im.append(piloto_im*goldenSignos[i])

            i += 1
        else:
            dut.y_re.value = int(data_re[j])
            dut.y_im.value = int(data_im[j])

        # the try trick
        try:
            int(dut.x_eq_out_re.value)
            int(dut.x_eq_out_im.value)
        except:
            pass
        else:
            out_re.append((dut.x_eq_out_re.value))
            out_im.append((dut.x_eq_out_im.value))

        j += 1

    # print(out_re.shape)
    # out_re = np.array(fromsigned2int(np.squeeze(out_re[14:]),2)*2**-0)
    out_re = np.array(fromsigned2intv2(out_re[14:]))
    out_im = np.array(fromsigned2intv2(out_im[14:]))
    # figs are saved, later they will be part of the artifact returned
    plt.figure(dpi = 300)
    plt.plot(0.9*out_re*max(data_re)/max(out_re))
    data_re[0::12] = data_re[0::12]*goldenSignos[:len(pilotos_re)*12:12]
    plt.plot(data_re)
    plt.xlim([100,300])
    # plt.show()
    plt.savefig('imgs/eq.png')
    # signos = np.array(signos[1:])
    plt.close()

    data_re = data_re[:-14]
    data_im = data_im[:-14]
    out_re_norm = out_re/norm(out_re)
    out_im_norm = out_im/norm(out_im)
    data_re_norm = data_re/norm(data_re)
    data_im_norm = data_im/norm(data_im)
    out_norm = (out_re_norm + 1j*out_im_norm)/norm((out_re_norm + 1j*out_im_norm))
    data_norm = (data_re_norm + 1j*data_im_norm)/norm(data_re_norm + 1j*data_im_norm)

    print("MSE real flat :",MSE(out_re_norm,data_re_norm))
    print("MSE imag flat :",MSE(out_im_norm,data_im_norm))
    print("RMSE real flat :",RMSE(out_re_norm,data_re_norm))
    print("RMSE imag flat :",RMSE(out_im_norm,data_im_norm))
    print("MAE real flat :",MAE(out_re_norm,data_re_norm))
    print("MAE imag flat :",MAE(out_im_norm,data_im_norm))

    print("MSE complex flat :",MSE(out_norm,data_norm))
    print("RMSE complex flat :",RMSE(out_norm,data_norm))
    print("MAE complex flat :",MAE(out_norm,data_norm))

    # print(signos)
    # # np.save('sig.npy',signos)
    # plt.plot(np.squeeze(signos))
    # plt.plot(goldenSignos)
    # plt.show()

@cocotb.test(skip = skipTest2)
async def testReset(dut):

    global maxCyclesMaster,currentCycle
    maxCycles = maxCyclesMaster

    #clk refreshed
    currentCycle = 0

    out_re = []
    out_im = []
    pilotos_re = []
    pilotos_im = []

    octave.addpath('../../../Matlab/OctaveIt')
    goldenSignos = octave.PRBS(1,1705*20)[0,:]

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
    j = 1
    while currentCycle < maxCycles-1:
        await RisingEdge(dut.clk)
        # dut._log.info("CLK")

        if i >= 142:
            i = 142

        if j%12 == 0:

            piloto_re = int(np.random.rand()*200*goldenSignos[j])
            piloto_im = int(np.random.rand()*200*goldenSignos[j])

            dut.y_re.value = piloto_re
            dut.y_im.value = piloto_im

            pilotos_re.append(piloto_re*goldenSignos[j])
            pilotos_im.append(piloto_im*goldenSignos[j])

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
    plt.savefig('imgs/eq_rst.png')


@cocotb.test(skip = skipTest3)
async def testVsOctaveFlatMode2(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster
    
    #  mode is defined, along other parameters
    mode = 2
    CONSTEL = '16QAM'   # Constelación utilizada BPSK, QPSK, 16QAM
    SNR = 60
    noiseON = 1
    canalON = 0
    NUM_SYMB = 1
    SEED = 100

    maxCycles = maxCyclesMaster*int(mode/2)
    # maxCycles = 300
    useCarrier = useCarrierMaster*int(mode/2)

    octave.addpath('../../../Matlab/OctaveIt')
    
    # this octave/matlab code returns everything we need to compare
    muestras, hest, v, PRBS_matlab, ofdm_eq_matlab = octave.GoldenChannelEstim2(mode, CONSTEL, SNR, noiseON, canalON,NUM_SYMB, SEED,nout=5)
    
    # bring arrays to the numpy world
    muestras = np.array(muestras)
    hest = np.array(hest)
    v = np.array(v)
    PRBS_matlab = np.array(PRBS_matlab)[0,:]
    ofdm_eq_matlab = np.array(ofdm_eq_matlab)

    print(muestras.shape)
    print(hest.shape)
    print(v.shape)
    print("Shape prbs matlab",PRBS_matlab.shape)
    
    # compute the scale to take benefit of the whole range.
    # commented line was my approach, it was fine, but far from perfect, could be losing up to 2^N -1 range if conditions met
    # the used method is better, as it scales better the samples. Proposed by Elias in class.
    # escala = 10-np.ceil(np.log2(max([max(abs(muestras.real)),max(abs(muestras.imag))]).astype(int))+1)
    escala = np.log2(511/max([max(abs(muestras.real)),max(abs(muestras.imag))]))
    print("Escalado = 2**%d" % int(escala))
    muestras = muestras*(2**escala)
    ofdm_eq_matlab = ofdm_eq_matlab*(2**escala)

    # squeeze gets rid of the extra dimensions
    muestras_re = np.squeeze(np.real(muestras).astype(int)).tolist()
    muestras_im = np.squeeze(np.imag(muestras).astype(int)).tolist()
    ofdm_eq_matlab_re = np.squeeze(np.real(ofdm_eq_matlab).astype(int)).tolist()
    ofdm_eq_matlab_im = np.squeeze(np.imag(ofdm_eq_matlab).astype(int)).tolist()


    currentCycle = 0
    y_re = []
    y_im = []
    out_re = []
    out_im = []
    h_est_re = []
    h_est_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,useCarrier*22)[0,:]
    goldenSignos = np.array(goldenSignos)
    # goldenSignos = goldenSignos

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

        # more protection
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
            int(dut.x_eq_out_re.value)
            int(dut.x_eq_out_im.value)
        except:
            pass
        else:
            
            out_re.append(dut.x_eq_out_re.value)
            out_im.append(dut.x_eq_out_im.value)
            y_re.append(dut.eq.y_re.value)
            y_im.append(dut.eq.y_im.value)

        try:
            int(dut.estimador.out_re.value)
            int(dut.estimador.out_im.value)
        except:
            pass
        else:
            
            h_est_re.append(dut.estimador.out_re.value)
            h_est_im.append(dut.estimador.out_im.value)

        j += 1

    # conversions to int
    out_re_int = fromsigned2intv2(out_re[15:useCarrier])*4/9*(2**(escala-3))
    out_im_int = fromsigned2intv2(out_im[15:useCarrier])*4/9*(2**(escala-3))
    h_re_int = fromsigned2intv2(h_est_re[15:useCarrier])
    h_im_int = fromsigned2intv2(h_est_im[15:useCarrier])
    y_re_int = fromsigned2intv2(y_re[:useCarrier])
    y_im_int = fromsigned2intv2(y_im[:useCarrier])

    # print(out_re_int.shape)
    # print(np.real(v)[:,0].shape)
    # corr_re = sum((out_re_int/(np.mean(out_re_int)))*(np.real(v)[:,0]/(np.mean(np.real(v)[:,0]))))
    # corr_im = sum((out_im_int/(np.mean(out_im_int)))*(np.imag(v)[:,0]/(np.mean(np.imag(v)[:,0]))))
    
    # print(out_re_int.shape)
    # print(len(ofdm_eq_matlab_re))
    # print(MSE(ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]),out_re_int/norm(out_re_int)))
    # print(norm(out_re_int))
    # print(norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # print(MSE(ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]),out_im_int/norm(out_im_int)))
    # print(norm(out_im_int))
    # print(norm(ofdm_eq_matlab_im[:len(out_im_int)]))
    #TODO: bits of error

    # print("Correlación re ",corr_re)
    # print("Correlación im ",corr_im)

    N = np.squeeze(out_re).shape[0]
    plt.figure(figsize = (16,9),dpi = 300)

    plt.title("Parte Real")
    plt.subplot(211)
    plt.plot(out_re_int/norm(out_re_int),linewidth=3)
    # plt.plot(y_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(len(out_re_int)),ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.subplot(212)
    plt.plot(h_re_int)
    ## add 3 bc of the delays of the system
    print(len(pilotos_re))
    print(len(goldenSignos[:len(pilotos_re)*12:12]))
    # pilotos_re = pilotos_re*goldenSignos[:len(pilotos_re)*12:12]
    plt.plot(np.arange(0,useCarrier,12),pilotos_re[:int(useCarrier/12)+1])
    # plt.plot(ofdm_eq_matlab_im)
    # plt.show()
    plt.savefig('imgs/vsOctave2flatre.png')
    # plt.close()

    plt.figure(figsize = (16,9),dpi = 300)
    plt.title("Parte Imag")
    plt.subplot(211)
    plt.plot(out_im_int/norm(out_im_int),linewidth=3)
    # plt.plot(y_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(len(out_im_int)),ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]))
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.subplot(212)
    plt.plot(h_im_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(0,useCarrier,12),pilotos_im[:int(useCarrier/12)+1])
    # plt.plot(ofdm_eq_matlab_im)
    # plt.show()
    plt.savefig('imgs/vsOctave2flatim.png')

    data_re = ofdm_eq_matlab_re[:len(out_re_int)]
    data_re[::12] = np.zeros(len(data_re[::12]))  # n
    data_im = ofdm_eq_matlab_im[:len(out_im_int)]
    out_re_int[::12] = np.zeros(len(out_re_int[::12])) # n
    out_re_norm = out_re_int/norm(out_re_int)
    out_im_norm = out_im_int/norm(out_im_int)
    data_re_norm = data_re/norm(data_re)
    data_im_norm = data_im/norm(data_im)
    out_norm = (out_re_norm + 1j*out_im_norm)/norm((out_re_norm + 1j*out_im_norm))
    data_norm = (data_re_norm + 1j*data_im_norm)/norm(data_re_norm + 1j*data_im_norm)

    MSEcomplex = MSE(out_norm,data_norm)
    print("MSE real flat :",MSE(out_re_norm,data_re_norm))
    print("MSE imag flat :",MSE(out_im_norm,data_im_norm))
    print("RMSE real flat :",RMSE(out_re_norm,data_re_norm))
    print("RMSE imag flat :",RMSE(out_im_norm,data_im_norm))
    print("MAE real flat :",MAE(out_re_norm,data_re_norm))
    print("MAE imag flat :",MAE(out_im_norm,data_im_norm))

    print("MSE complex flat :",MSEcomplex)
    print("RMSE complex flat :",RMSE(out_norm,data_norm))
    print("MAE complex flat :",MAE(out_norm,data_norm))
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()

    if MSEcomplex >= -20:
        raise NameError("El error es mayor que el límite establecido, %d > -20 dB" % MSEcomplex)


@cocotb.test(skip = skipTest4)
async def testVsOctaveMode2(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster
    
    #  mode is defined, along other parameters
    mode = 2
    CONSTEL = '16QAM'   # Constelación utilizada BPSK, QPSK, 16QAM
    SNR = 60
    noiseON = 0
    canalON = 1
    NUM_SYMB = 1
    SEED = 100

    maxCycles = maxCyclesMaster*int(mode/2)
    # maxCycles = 1300
    useCarrier = useCarrierMaster*int(mode/2)

    octave.addpath('../../../Matlab/OctaveIt')
    
    # this octave/matlab code returns everything we need to compare
    muestras, hest, v, PRBS_matlab, ofdm_eq_matlab = octave.GoldenChannelEstim2(mode, CONSTEL, SNR, noiseON, canalON,NUM_SYMB, SEED,nout=5)
    
    # bring arrays to the numpy world
    muestras = np.array(muestras)
    hest = np.array(hest)
    v = np.array(v)
    PRBS_matlab = np.array(PRBS_matlab)[0,:]
    ofdm_eq_matlab = np.array(ofdm_eq_matlab)

    print(muestras.shape)
    print(hest.shape)
    print(v.shape)
    print("Shape prbs matlab",PRBS_matlab.shape)
    
    # compute the scale to take benefit of the whole range.
    # commented line was my approach, it was fine, but far from perfect, could be losing up to 2^N -1 range if conditions met
    # the used method is better, as it scales better the samples. Proposed by Elias in class.
    # escala = 10-np.ceil(np.log2(max([max(abs(muestras.real)),max(abs(muestras.imag))]).astype(int))+1)
    escala = np.log2(511/max([max(abs(muestras.real)),max(abs(muestras.imag))]))
    print("Escalado = 2**%d" % int(escala))
    muestras = muestras*(2**escala)
    ofdm_eq_matlab = ofdm_eq_matlab*(2**escala)

    # squeeze gets rid of the extra dimensions
    muestras_re = np.squeeze(np.real(muestras).astype(int)).tolist()
    muestras_im = np.squeeze(np.imag(muestras).astype(int)).tolist()
    ofdm_eq_matlab_re = np.squeeze(np.real(ofdm_eq_matlab).astype(int)).tolist()
    ofdm_eq_matlab_im = np.squeeze(np.imag(ofdm_eq_matlab).astype(int)).tolist()


    currentCycle = 0
    y_re = []
    y_im = []
    out_re = []
    out_im = []
    h_est_re = []
    h_est_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,useCarrier)[0,:]
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

        # more protection
        if i >= 142*int(mode/2):
            i = 142*int(mode/2)-1
        
        if j >= useCarrier-1:
            j = useCarrier-1
            dut.y_valid.value =0

        piloto_re = muestras_re[j]
        piloto_im = muestras_im[j]

        # dut.y_re.value = piloto_re
        # dut.y_im.value = piloto_im

        dut.y_re.value = piloto_re
        dut.y_im.value = piloto_im
        dut.y_valid.value = 1
        dut.rst.value = 0

        if j%12 == 0:

            pilotos_re.append(piloto_re*goldenSignos[i])
            pilotos_im.append(piloto_im*goldenSignos[i])

            i += 1

        try:
            int(dut.x_eq_out_re.value)
            int(dut.x_eq_out_im.value)
        except:
            pass
        else:
            
            out_re.append(dut.x_eq_out_re.value)
            out_im.append(dut.x_eq_out_im.value)
            y_re.append(dut.eq.y_re.value)
            y_im.append(dut.eq.y_im.value)

        try:
            int(dut.estimador.out_re.value)
            int(dut.estimador.out_im.value)
        except:
            pass
        else:
            
            h_est_re.append(dut.estimador.out_re.value)
            h_est_im.append(dut.estimador.out_im.value)

        j += 1

    # conversions to int
    out_re_int = fromsigned2intv2(out_re[15:useCarrier])*4/9*(2**(escala-3))
    out_im_int = fromsigned2intv2(out_im[15:useCarrier])*4/9*(2**(escala-3))
    h_re_int = fromsigned2intv2(h_est_re[15:useCarrier])
    h_im_int = fromsigned2intv2(h_est_im[15:useCarrier])
    y_re_int = fromsigned2intv2(y_re[:useCarrier])
    y_im_int = fromsigned2intv2(y_im[:useCarrier])

    # print(out_re_int.shape)
    # print(np.real(v)[:,0].shape)
    # corr_re = sum((out_re_int/(np.mean(out_re_int)))*(np.real(v)[:,0]/(np.mean(np.real(v)[:,0]))))
    # corr_im = sum((out_im_int/(np.mean(out_im_int)))*(np.imag(v)[:,0]/(np.mean(np.imag(v)[:,0]))))
    
    # print(out_re_int.shape)
    # print(len(ofdm_eq_matlab_re))
    # print(MSE(ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]),out_re_int/norm(out_re_int)))
    # print(norm(out_re_int))
    # print(norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # print(MSE(ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]),out_im_int/norm(out_im_int)))
    # print(norm(out_im_int))
    # print(norm(ofdm_eq_matlab_im[:len(out_im_int)]))
    #TODO: bits of error

    # print("Correlación re ",corr_re)
    # print("Correlación im ",corr_im)

    N = np.squeeze(out_re).shape[0]
    plt.figure(figsize=(16,9),dpi=300)
    plt.subplot(211)
    plt.plot(out_re_int/norm(out_re_int),linewidth=3)
    # plt.plot(y_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(len(out_re_int)),ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.xlim([550,1250])
    plt.subplot(212)
    plt.plot(h_re_int)
    ## add 3 bc of the delays of the system
    # plt.plot(np.arange(0,useCarrier,12),pilotos_re[:int(useCarrier/12)+1])
    # plt.plot(ofdm_eq_matlab_im)
    # plt.title("parte real")
    plt.xlim([550,1250])
    # plt.show()
    plt.savefig('imgs/vsOctave2re.png')
    plt.close()

    plt.figure(figsize=(16,9),dpi=300)
    plt.subplot(211)
    plt.plot(out_im_int/norm(out_im_int),linewidth=3)
    # plt.plot(y_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(len(out_im_int)),ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]))
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.xlim([550,1250])
    plt.subplot(212)
    plt.plot(h_im_int)
    ## add 3 bc of the delays of the system
    # plt.plot(np.arange(0,useCarrier,12),pilotos_im[:int(useCarrier/12)+1])
    # plt.plot(ofdm_eq_matlab_im)
    plt.xlim([550,1250])
    # plt.title("parte imag")
    # plt.show()
    plt.savefig('imgs/vsOctave2im.png')
    plt.close()
    
    data_re = ofdm_eq_matlab_re[:len(out_re_int)]
    data_re[::12] = np.zeros(len(data_re[::12]))  # n
    data_im = ofdm_eq_matlab_im[:len(out_im_int)]
    out_re_int[::12] = np.zeros(len(out_re_int[::12])) # n
    out_re_norm = out_re_int/norm(out_re_int)
    out_im_norm = out_im_int/norm(out_im_int)
    data_re_norm = data_re/norm(data_re)
    data_im_norm = data_im/norm(data_im)
    out_norm = (out_re_norm + 1j*out_im_norm)/norm((out_re_norm + 1j*out_im_norm))
    data_norm = (data_re_norm + 1j*data_im_norm)/norm(data_re_norm + 1j*data_im_norm)

    MSEcomplex = MSE(out_norm,data_norm)
    print("MSE real flat :",MSE(out_re_norm,data_re_norm))
    print("MSE imag flat :",MSE(out_im_norm,data_im_norm))
    print("RMSE real flat :",RMSE(out_re_norm,data_re_norm))
    print("RMSE imag flat :",RMSE(out_im_norm,data_im_norm))
    print("MAE real flat :",MAE(out_re_norm,data_re_norm))
    print("MAE imag flat :",MAE(out_im_norm,data_im_norm))

    print("MSE complex flat :",MSEcomplex)
    print("RMSE complex flat :",RMSE(out_norm,data_norm))
    print("MAE complex flat :",MAE(out_norm,data_norm))
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()

    if MSEcomplex >= -20:
        raise NameError("El error es mayor que el límite establecido, %d > -20 dB" % MSEcomplex)


@cocotb.test(skip = skipTest5)
async def testVsOctaveMode8(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster

    # use mode 8
    mode = 8
    CONSTEL = '16QAM'   # Constelación utilizada BPSK, QPSK, 16QAM
    SNR = 60
    noiseON = 0
    canalON = 1
    NUM_SYMB = 1
    SEED = 100

    maxCycles = maxCyclesMaster*int(mode/2)
    maxCyclesMaster = maxCyclesMaster*int(mode/2)
    useCarrier = useCarrierMaster*int(mode/2)-3

    octave.addpath('../../../Matlab/OctaveIt')
    muestras, hest, v, PRBS_matlab, ofdm_eq_matlab = octave.GoldenChannelEstim2(mode, CONSTEL, SNR, noiseON, canalON,NUM_SYMB, SEED,nout=5)
    
    muestras = np.array(muestras)
    hest = np.array(hest)
    v = np.array(v)
    PRBS_matlab = np.array(PRBS_matlab)[0,:]
    ofdm_eq_matlab = np.array(ofdm_eq_matlab)

    print(muestras.shape)
    print(hest.shape)
    print(v.shape)
    print("Shape prbs matlab",PRBS_matlab.shape)
    
    # escala = 10-np.ceil(np.log2(max([max(abs(muestras.real)),max(abs(muestras.imag))]).astype(int))+1)
    escala = np.log2(511/max([max(abs(muestras.real)),max(abs(muestras.imag))]))
    print("Escalado = 2**%d" % int(escala))
    muestras = muestras*(2**escala)
    ofdm_eq_matlab = ofdm_eq_matlab*(2**escala)
    
    muestras_re = np.squeeze(np.real(muestras).astype(int)).tolist()
    muestras_im = np.squeeze(np.imag(muestras).astype(int)).tolist()
    ofdm_eq_matlab_re = np.squeeze(np.real(ofdm_eq_matlab).astype(int)).tolist()
    ofdm_eq_matlab_im = np.squeeze(np.imag(ofdm_eq_matlab).astype(int)).tolist()


    currentCycle = 0
    y_re = []
    y_im = []
    out_re = []
    out_im = []
    h_est_re = []
    h_est_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,useCarrier)[0,:]
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

            pilotos_re.append(piloto_re*goldenSignos[i])
            pilotos_im.append(piloto_im*goldenSignos[i])

            i += 1

        try:
            int(dut.x_eq_out_re.value)
            int(dut.x_eq_out_im.value)
        except:
            pass
        else:
            
            out_re.append(dut.x_eq_out_re.value)
            out_im.append(dut.x_eq_out_im.value)
            y_re.append(dut.eq.y_re.value)
            y_im.append(dut.eq.y_im.value)

        try:
            int(dut.estimador.out_re.value)
            int(dut.estimador.out_im.value)
        except:
            pass
        else:
            
            h_est_re.append(dut.estimador.out_re.value)
            h_est_im.append(dut.estimador.out_im.value)

        j += 1

   # conversions to int
    out_re_int = fromsigned2intv2(out_re[15:useCarrier])*4/9*(2**(escala-3))
    out_im_int = fromsigned2intv2(out_im[15:useCarrier])*4/9*(2**(escala-3))
    h_re_int = fromsigned2intv2(h_est_re[15:useCarrier])
    h_im_int = fromsigned2intv2(h_est_im[15:useCarrier])
    y_re_int = fromsigned2intv2(y_re[:useCarrier])
    y_im_int = fromsigned2intv2(y_im[:useCarrier])

    # print(out_re_int.shape)
    # print(np.real(v)[:,0].shape)
    # corr_re = sum((out_re_int[3:]/(np.mean(out_re_int)))*(np.real(v)[:,0]/(np.mean(np.real(v)[:,0]))))
    # corr_im = sum((out_im_int[3:]/(np.mean(out_im_int)))*(np.imag(v)[:,0]/(np.mean(np.imag(v)[:,0]))))
    # print(out_re_int.shape)
    # print(len(ofdm_eq_matlab_re))
    # print(MSE(ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]),out_re_int/norm(out_re_int)))
    # print(norm(out_re_int))
    # print(norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # print(MSE(ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]),out_im_int/norm(out_im_int)))
    # print(norm(out_im_int))
    # print(norm(ofdm_eq_matlab_im[:len(out_im_int)]))

    # print("Correlación re ",corr_re)
    # print("Correlación im ",corr_im)

    N = np.squeeze(out_re).shape[0]
    plt.subplot(211)
    plt.plot(out_re_int/norm(out_re_int),linewidth=3)
    # plt.plot(y_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(len(out_re_int)),ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.subplot(212)
    plt.plot(h_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(0,useCarrier,12),pilotos_re[:int(useCarrier/12)+1])
    # plt.plot(ofdm_eq_matlab_im)
    plt.title("parte real")
    # plt.show()
    plt.savefig('imgs/vsOctave8re.png')

    plt.subplot(211)
    plt.plot(out_im_int/norm(out_im_int),linewidth=3)
    # plt.plot(y_re_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(len(out_im_int)),ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]))
    # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    plt.subplot(212)
    plt.plot(h_im_int)
    ## add 3 bc of the delays of the system
    plt.plot(np.arange(0,useCarrier,12),pilotos_im[:int(useCarrier/12)+1])
    # plt.plot(ofdm_eq_matlab_im)
    plt.title("parte imag")
    # plt.show()
    plt.savefig('imgs/vsOctave8im.png')

    data_re = ofdm_eq_matlab_re[:len(out_re_int)]
    data_re[::12] = np.zeros(len(data_re[::12]))  # n
    data_im = ofdm_eq_matlab_im[:len(out_im_int)]
    out_re_int[::12] = np.zeros(len(out_re_int[::12])) # n
    out_re_norm = out_re_int/norm(out_re_int)
    out_im_norm = out_im_int/norm(out_im_int)
    data_re_norm = data_re/norm(data_re)
    data_im_norm = data_im/norm(data_im)
    out_norm = (out_re_norm + 1j*out_im_norm)/norm((out_re_norm + 1j*out_im_norm))
    data_norm = (data_re_norm + 1j*data_im_norm)/norm(data_re_norm + 1j*data_im_norm)

    MSEcomplex = MSE(out_norm,data_norm)
    print("MSE real flat :",MSE(out_re_norm,data_re_norm))
    print("MSE imag flat :",MSE(out_im_norm,data_im_norm))
    print("RMSE real flat :",RMSE(out_re_norm,data_re_norm))
    print("RMSE imag flat :",RMSE(out_im_norm,data_im_norm))
    print("MAE real flat :",MAE(out_re_norm,data_re_norm))
    print("MAE imag flat :",MAE(out_im_norm,data_im_norm))

    print("MSE complex flat :",MSEcomplex)
    print("RMSE complex flat :",RMSE(out_norm,data_norm))
    print("MAE complex flat :",MAE(out_norm,data_norm))
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()

    if MSEcomplex >= -20:
        raise NameError("El error es mayor que el límite establecido, %d > -20 dB" % MSEcomplex)

    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()


@cocotb.test(skip = skipTest6)
async def testVsOctaveNoisy(dut):
    global maxCyclesMaster,currentCycle,useCarrierMaster

    # use mode x
    mode = 8
    CONSTEL = '16QAM'   # Constelación utilizada BPSK, QPSK, 16QAM
    SNR = 60
    noiseON = 1
    canalON = 1
    NUM_SYMB = 1
    SEED = 100

    maxCycles = maxCyclesMaster*int(mode/2)
    maxCyclesMaster = maxCyclesMaster*int(mode/2)
    useCarrier = useCarrierMaster*int(mode/2)-3

    octave.addpath('../../../Matlab/OctaveIt')
    muestras, hest, v, PRBS_matlab, ofdm_eq_matlab = octave.GoldenChannelEstim2(mode, CONSTEL, SNR, noiseON, canalON,NUM_SYMB, SEED,nout=5)
    
    muestras = np.array(muestras)
    hest = np.array(hest)
    v = np.array(v)
    PRBS_matlab = np.array(PRBS_matlab)[0,:]
    ofdm_eq_matlab = np.array(ofdm_eq_matlab)

    print(muestras.shape)
    print(hest.shape)
    print(v.shape)
    print("Shape prbs matlab",PRBS_matlab.shape)
    
    # escala = 10-np.ceil(np.log2(max([max(abs(muestras.real)),max(abs(muestras.imag))]).astype(int))+1)
    escala = np.log2(511/max([max(abs(muestras.real)),max(abs(muestras.imag))]))
    print("Escalado = 2**%d" % int(escala))
    muestras = muestras*(2**escala)
    ofdm_eq_matlab = ofdm_eq_matlab*(2**escala)
    
    muestras_re = np.squeeze(np.real(muestras).astype(int)).tolist()
    muestras_im = np.squeeze(np.imag(muestras).astype(int)).tolist()
    ofdm_eq_matlab_re = np.squeeze(np.real(ofdm_eq_matlab).astype(int)).tolist()
    ofdm_eq_matlab_im = np.squeeze(np.imag(ofdm_eq_matlab).astype(int)).tolist()


    currentCycle = 0
    y_re = []
    y_im = []
    out_re = []
    out_im = []
    h_est_re = []
    h_est_im = []
    pilotos_re = []
    pilotos_im = []
    goldenSignos = octave.PRBS(1,useCarrier)[0,:]
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

            pilotos_re.append(piloto_re*goldenSignos[i])
            pilotos_im.append(piloto_im*goldenSignos[i])

            i += 1

        try:
            int(dut.x_eq_out_re.value)
            int(dut.x_eq_out_im.value)
        except:
            pass
        else:
            
            out_re.append(dut.x_eq_out_re.value)
            out_im.append(dut.x_eq_out_im.value)
            y_re.append(dut.eq.y_re.value)
            y_im.append(dut.eq.y_im.value)

        try:
            int(dut.estimador.out_re.value)
            int(dut.estimador.out_im.value)
        except:
            pass
        else:
            
            h_est_re.append(dut.estimador.out_re.value)
            h_est_im.append(dut.estimador.out_im.value)

        j += 1

   # conversions to int
    out_re_int = fromsigned2intv2(out_re[15:useCarrier])*4/9*(2**(escala-3))
    out_im_int = fromsigned2intv2(out_im[15:useCarrier])*4/9*(2**(escala-3))
    h_re_int = fromsigned2intv2(h_est_re[15:useCarrier])
    h_im_int = fromsigned2intv2(h_est_im[15:useCarrier])
    y_re_int = fromsigned2intv2(y_re[:useCarrier])
    y_im_int = fromsigned2intv2(y_im[:useCarrier])

    # print(out_re_int.shape)
    # print(np.real(v)[:,0].shape)
    # corr_re = sum((out_re_int[3:]/(np.mean(out_re_int)))*(np.real(v)[:,0]/(np.mean(np.real(v)[:,0]))))
    # corr_im = sum((out_im_int[3:]/(np.mean(out_im_int)))*(np.imag(v)[:,0]/(np.mean(np.imag(v)[:,0]))))
    # print(out_re_int.shape)
    # print(len(ofdm_eq_matlab_re))
    # print(MSE(ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]),out_re_int/norm(out_re_int)))
    # print(norm(out_re_int))
    # print(norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # print(MSE(ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]),out_im_int/norm(out_im_int)))
    # print(norm(out_im_int))
    # print(norm(ofdm_eq_matlab_im[:len(out_im_int)]))

    # print("Correlación re ",corr_re)
    # print("Correlación im ",corr_im)

    # N = np.squeeze(out_re).shape[0]
    # plt.subplot(211)
    # plt.plot(out_re_int/norm(out_re_int),linewidth=3)
    # # plt.plot(y_re_int)
    # ## add 3 bc of the delays of the system
    # plt.plot(np.arange(len(out_re_int)),ofdm_eq_matlab_re[:len(out_re_int)]/norm(ofdm_eq_matlab_re[:len(out_re_int)]))
    # # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    # plt.subplot(212)
    # plt.plot(h_re_int)
    # ## add 3 bc of the delays of the system
    # plt.plot(np.arange(0,useCarrier,12),pilotos_re[:int(useCarrier/12)+1])
    # # plt.plot(ofdm_eq_matlab_im)
    # plt.title("parte real")
    # # plt.show()
    # plt.savefig('imgs/vsOctave8re.png')

    # plt.subplot(211)
    # plt.plot(out_im_int/norm(out_im_int),linewidth=3)
    # # plt.plot(y_re_int)
    # ## add 3 bc of the delays of the system
    # plt.plot(np.arange(len(out_im_int)),ofdm_eq_matlab_im[:len(out_im_int)]/norm(ofdm_eq_matlab_im[:len(out_im_int)]))
    # # plt.stem(np.arange(12+3,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)-1])
    # plt.subplot(212)
    # plt.plot(h_im_int)
    # ## add 3 bc of the delays of the system
    # plt.plot(np.arange(0,useCarrier,12),pilotos_im[:int(useCarrier/12)+1])
    # # plt.plot(ofdm_eq_matlab_im)
    # plt.title("parte imag")
    # # plt.show()
    # plt.savefig('imgs/vsOctave8im.png')

    data_re = ofdm_eq_matlab_re[:len(out_re_int)]
    data_re[::12] = np.zeros(len(data_re[::12]))  # n
    data_im = ofdm_eq_matlab_im[:len(out_im_int)]
    out_re_int[::12] = np.zeros(len(out_re_int[::12])) # n
    out_re_norm = out_re_int/norm(out_re_int)
    out_im_norm = out_im_int/norm(out_im_int)
    data_re_norm = data_re/norm(data_re)
    data_im_norm = data_im/norm(data_im)
    out_norm = (out_re_norm + 1j*out_im_norm)/norm((out_re_norm + 1j*out_im_norm))
    data_norm = (data_re_norm + 1j*data_im_norm)/norm(data_re_norm + 1j*data_im_norm)

    MSEcomplex = MSE(out_norm,data_norm)
    print("MSE real flat :",MSE(out_re_norm,data_re_norm))
    print("MSE imag flat :",MSE(out_im_norm,data_im_norm))
    print("RMSE real flat :",RMSE(out_re_norm,data_re_norm))
    print("RMSE imag flat :",RMSE(out_im_norm,data_im_norm))
    print("MAE real flat :",MAE(out_re_norm,data_re_norm))
    print("MAE imag flat :",MAE(out_im_norm,data_im_norm))

    print("MSE complex flat :",MSEcomplex)
    print("RMSE complex flat :",RMSE(out_norm,data_norm))
    print("MAE complex flat :",MAE(out_norm,data_norm))
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()

    if MSEcomplex >= -20:
        raise NameError("El error es mayor que el límite establecido, %d > -20 dB" % MSEcomplex)

    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),PRBS_matlab[:len(pilotos_re)])
    # plt.stem(np.arange(0,(len(pilotos_re))*12,12),pilotos_re)
    # plt.show()