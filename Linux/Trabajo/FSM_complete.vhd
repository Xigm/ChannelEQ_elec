library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FSM is
    port (
        clk   : in std_logic;
        rst : in std_logic;
        write_enable : in std_logic;
        piloto_y_re, piloto_y_im: in signed(9 downto 0);
        PRBS : in std_logic;

        h_inf_re,h_inf_im, h_sup_re, h_sup_im : out signed(9 downto 0);
        valid : out std_logic

    );
end entity FSM;

architecture FSM_arch of FSM is

    -- signals definitions

    signal data_in_re, data_in_im, data_FSM_re, data_FSM_im, inf_re, inf_im, sup_re, sup_im, estim_re_FSM, estim_im_FSM : signed(9 downto 0) := (others => '0');
    signal ena_PRBS, valid, estim_valid_CE, rst_counter, rst_interpolator, rst_prbs,signo : std_logic := '0';
    signal addr_in, addr_FSM : unsigned(7 downto 0) := (others => '0');
    -- signal cuenta_out : std_logic_vector(7 downto 0);
    
    signal y_full, data_out_mem : std_logic_vector(19 downto 0) := (others => '0');
    signal p_addr_to_read,addr_to_read : unsigned(7 downto 0) := (others => '0') ;

    type estado_t is (init,safe_init,idle,callPRBSnPilot, obtainPRBSnPilot,feedInterpolate,interpolate);
    signal state,p_state : estado_t;

    signal h_estim_re, h_estim_im : signed(9 downto 0);

begin

    sinc: process(clk,rst)
    begin
        if rst = '1' then
            valid <= '0';
        elsif rising_edge(clk) then
            keep_h_e_re <= h_estim_re;
            keep_h_e_im <= h_estim_im;
        end if;
    end process;

    -- FSM_proc : process (state,write_enable,PRBS,piloto_y_re,piloto_y_im)
        
    -- begin
        
    --     case state is
            
    --         when init => 
    --             valid <= '0';
    --             p_state <= safe_init;

    --         when safe_init =>
    --             p_state <= idle;

    --         when idle =>
                
    --         if write_enable = '1' then
    --             p_state <= obtainPRBSnPilot;
    --             valid <= '1';

    --             if PRBS = '1' then
    --                 h_estim_re <= piloto_y_re;
    --                 h_estim_im <= piloto_y_im;
    --             else
    --                 h_estim_re <= (-1)*piloto_y_re;
    --                 h_estim_im <= (-1)*piloto_y_im;
    --             end if;
    --         else 

    --             p_state <= idle;

    --         end if;
                
    --         when obtainPRBSnPilot =>

    --             addr_FSM <= addr_to_read;

    --             p_addr_to_read <= addr_to_read +1;

    --             ena_PRBS <= '1';

    --             p_state <= obtainPRBSnPilot;

    --         when callPRBSnPilot =>
                
    --             addr_to_read <= p_addr_to_read;
    --             ena_PRBS <= '0';

    --             data_FSM_re <= signed(data_out_mem(19 downto 10));
    --             data_FSM_im <= signed(data_out_mem(9 downto 0));
                
    --             p_state <= feedInterpolate;

    --         when feedInterpolate =>

    --             if addr_to_read = 1 then
    --                 -- Extremadamente dudoso esto
    --                 -- inf_re <= signo*data_FSM_re;
    --                 -- inf_im <= signo*data_FSM_im;
    --                 inf_re <= (9 => signo and data_FSM_re(9), 8 downto 0 => data_FSM_re(8 downto 0));
    --                 inf_im <= (9 => signo and data_FSM_im(9), 8 downto 0 => data_FSM_im(8 downto 0));

    --                 p_state <= idle;
    --             else
    --                 -- Sigue siendo igual de dudoso
    --                 -- sup_re <= inf_re;
    --                 -- inf_re <= signo*data_FSM_re;

    --                 -- sup_im <= inf_im;
    --                 -- inf_im <= signo*data_FSM_im;

    --                 sup_re <= inf_re;
    --                 inf_re <= (9 => signo and data_FSM_re(9), 8 downto 0 => data_FSM_re(8 downto 0));

    --                 sup_im <= inf_im;
    --                 inf_im <= (9 => signo and data_FSM_im(9), 8 downto 0 => data_FSM_im(8 downto 0));

    --                 valid <= '1';

    --                 p_state <= idle;
    --             end if;
                
    --         when others =>
    --             null;
    --     end case;
        
    -- end process;


    main : process (write_enable,PRBS,piloto_y_re,piloto_y_im)
        
    begin

        if write_enable = '1' then
            
            valid <= '1';

            if PRBS = '1' then
                h_estim_re <= piloto_y_re;
                h_estim_im <= piloto_y_im;
            else
                h_estim_re <= (-1)*piloto_y_re;
                h_estim_im <= (-1)*piloto_y_im;
            end if;
            
        else

            valid <= '0';
            h_estim_re <= keep_h_e_re;
            h_estim_im <= keep_h_e_im;

        end if;

end architecture;