library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- getting together all blocks to estimate the channel 

entity toplevel is
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        y_re, y_im : in signed(9 downto 0);
        y_valid : in std_logic;

        valid : out std_logic;
        out_re,out_im : out signed(9 downto 0)

    );
end entity;

architecture toplevel_arch of toplevel is

    -- many signals defined, maybe these ones could be reduced
    signal cuenta_value : unsigned(3 downto 0);
    signal enaPRBS,enaFSm : std_logic;
    signal y_valid_delayed_1,y_valid_delayed_2,y_valid_delayed_3 : std_logic;
    signal y_re_delay2fsm, y_im_delay2fsm : signed(9 downto 0);
    signal y_re_delayfsm, y_im_delayfsm : signed(9 downto 0);
    signal signo : std_logic;

    signal inf_re,inf_im,sup_re,sup_im : signed(9 downto 0);

    signal estim_re, estim_im : signed(9 downto 0);
    signal estim_valid : std_logic;

begin

    -- adding "and y_valid_delayed" becouse if we stop and cuenta value is 11 we get many prbs
    -- enaPRBS <=  '1' when (cuenta_value = "1011" and y_valid_delayed_1 = '1')  else '0';
    -- hpgm didnt like PRBS the way i did it, fixed
    enaPRBS <=  '1' when (y_valid_delayed_1 = '1')  else '0';
    
    -- same with FSM
    enaFSM <=  '1' when (cuenta_value = "0000" and y_valid_delayed_2 = '1') else '0';

    y_valid_delayed_1 <= y_valid;
    valid <= y_valid_delayed_3;

    out_re <= estim_re;
    out_im <= estim_im;
    
    -- useful signal delaying technique
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


    cont_12 : entity work.contador1_12
        generic map (
            start => 11
        )
        port map (
                rst    => rst,
                clk    => clk,
                ena    => y_valid,
                cuenta => cuenta_value
    );

    -- delayer_inst_re1: entity work.delayer
    -- port map (
    --     clk => clk,
    --     rst => rst,
    --     data_in => y_re,
    --     data_out => y_re_delayfsm
    -- );

    -- delayer_inst_im1: entity work.delayer
    -- port map (
    --     clk => clk,
    --     rst => rst,
    --     data_in => y_im,
    --     data_out => y_im_delayfsm
    -- );

    delayer_inst_re2: entity work.delayer
    port map (
        clk => clk,
        rst => rst,
        data_in => y_re,
        data_out => y_re_delay2fsm
    );

    delayer_inst_im2: entity work.delayer
    port map (
        clk => clk,
        rst => rst,
        data_in => y_im,
        data_out => y_im_delay2fsm
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

    interpolador_inst : entity work.interpolatorMig
    port map(
        clk => clk,
        rst => rst,
        inf_re => inf_re,
        inf_im => inf_im,
        sup_re => sup_re,
        sup_im => sup_im,
        valid  => y_valid_delayed_3,
        estim_re => estim_re,
        estim_im => estim_im,
        estim_valid => estim_valid
    );

end architecture;