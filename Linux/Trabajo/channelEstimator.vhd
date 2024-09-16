library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.interpolator;
use work.contador;
use work.PRBS;

entity channelEstimator is
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        y_re, y_im : in signed(9 downto 0);
        y_valid : in std_logic;

        estim_re, estim_im : out signed(9 downto 0);
        estim_valid : out std_logic
    );
end entity;

architecture CE_arch of channelEstimator is

    signal enaPRBS : std_logic;
    signal cuenta_value : unsigned(3 downto 0);
    signal enaFSM : std_logic;
    signal signo : std_logic;
    signal h_inf_re, h_inf_im, h_sup_re, h_sup_im : signed(9 downto 0);
    -- signal valid : std_logic;
    signal y_re_delay2fsm, y_im_delay2fsm : signed(9 downto 0);
    signal y_valid_delayed_1,y_valid_delayed_2,y_valid_delayed_3 : std_logic;
    -- signal y_valid_delayed : std_logic;

begin

    enaPRBS <=  '1' when cuenta_value = "1011" else '0';
    enaFSM <=  '1' when cuenta_value = "0000" else '0';

    y_valid_delayed_1 <= y_valid;
    
    sinc : process (clk,rst)
    begin
        if rst = '1' then
            y_valid_delayed_2 <= '0';
            y_valid_delayed_3 <= '0';
        elsif rising_edge(clk) then
            -- y_valid_delayed_1 <= y_valid;
            y_valid_delayed_2 <= y_valid_delayed_1;
            y_valid_delayed_3 <= y_valid_delayed_2;
        end if;
    end process;

    delayer_inst_re: entity work.delayer
        port map (
            clk => clk,
            rst => rst,
            data_in => y_re,
            data_out => y_re_delay2fsm
    );

    delayer_inst_im: entity work.delayer
    port map (
        clk => clk,
        rst => rst,
        data_in => y_im,
        data_out => y_im_delay2fsm
    );

    cont_12 : entity work.contador1_12
        generic map (
            start => 10
        )
        port map (
                rst    => rst,
                clk    => clk,
                ena    => y_valid,
                cuenta => cuenta_value
    );

    prbs_inst : entity work.prbs
        port map(
            clk => clk,
            rst => rst,
            ena => enaPRBS,
            signo => signo
    );

    FSM_inst : entity work.fsm
        port map (
                clk   => clk,
                rst   => rst,
                write_enable => enaFSM,
                piloto_y_re => y_re_delay2fsm,
                piloto_y_im => y_im_delay2fsm,
                prbs => signo,
                inf_re => h_inf_re,
                inf_im => h_inf_im,
                sup_re => h_sup_re,
                sup_im => h_sup_im,
                valid_out => open
    );
    
    interpolador_inst : entity work.interpolatorMig
        port map(
            clk => clk,
            rst => rst,
            inf_re => h_inf_re,
            inf_im => h_inf_im,
            sup_re => h_sup_re,
            sup_im => h_sup_im,
            valid  => y_valid_delayed_3,
            estim_re => estim_re,
            estim_im => estim_im,
            estim_valid => estim_valid
    );








end architecture;

