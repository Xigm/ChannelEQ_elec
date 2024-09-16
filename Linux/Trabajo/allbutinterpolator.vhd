library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity allbutinterpolator is
    port (
        clk   : in std_logic;
        rst   : in std_logic;

        -- y is divided into real and imag parts, as cctb does not deal with records
        y_re, y_im : in signed(9 downto 0);
        y_valid : in std_logic;

        -- same case with upper and lower pilots, into real and imag
        inf_re, inf_im : out signed(9 downto 0);
        sup_re, sup_im : out signed(9 downto 0);
        valid : out std_logic

        -- valid signals (y_valid and valid) tell when signal has to be taken into account, input or output respectively
    );
end entity;

architecture allbutinterpolator_arch of allbutinterpolator is

    -- signals to carry inputs/outputs of blocks between them
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
    -- adding "and y_valid_delayed" becouse if we stop and cuenta value is 11 we get many *undesirable* prbs
    enaPRBS <=  '1' when (cuenta_value = "1011" and y_valid_delayed_2 = '1')  else '0';
    
    -- same with FSM
    enaFSM <=  '1' when (cuenta_value = "0000" and y_valid_delayed_3 = '1') else '0';

    -- delayed valid data signal following scheme
    y_valid_delayed_1 <= y_valid;
    valid <= y_valid_delayed_3;

    -- this procces is in charge of delaying the data valid signal so it is used by the interpolator correctly
    sinc : process (clk,rst)
    begin
        if rst = '1' then
            y_valid_delayed_2 <= '0';
            y_valid_delayed_3 <= '0';
        elsif rising_edge(clk) then
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
                inf_re => inf_re,
                inf_im => inf_im,
                sup_re => sup_re,
                sup_im => sup_im,
                valid_out => open
    );
    




end architecture;

