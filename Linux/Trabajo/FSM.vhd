library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- fake FSM. Just a sinc block that manages data, PRBS and interpolator.

entity FSM is
    port (
        clk   : in std_logic;
        rst : in std_logic;

        -- write enable tells if FSM must work this cycle
        write_enable : in std_logic;
        piloto_y_re, piloto_y_im: in signed(9 downto 0);
        PRBS : in std_logic;

        inf_re,inf_im, sup_re, sup_im : out signed(9 downto 0);
        valid_out : out std_logic

    );
end entity FSM;

architecture FSM_arch of FSM is

    -- signals definitions
    signal h_inf_re,h_inf_im,h_sup_re,h_sup_im : signed(9 downto 0);
    signal p_h_inf_re,p_h_inf_im,p_h_sup_re,p_h_sup_im : signed(9 downto 0);
    signal valid, p_valid : std_logic;
    
begin

    -- concurrent assignments of sinc signals
    inf_re <= h_inf_re;
    inf_im <= h_inf_im;
    sup_re <= h_sup_re;
    sup_im <= h_sup_im;
    valid_out <= valid;
    
    sinc: process(clk,rst)
    begin
        if rst = '1' then
            valid <= '0';
            -- there is no need to init h_inf_re/im. If something fails, this is the cause.
            h_inf_re <= (others => '0'); 
            h_inf_im <= (others => '0');
            h_sup_re <= (others => '0');
            h_sup_im <= (others => '0');
        elsif rising_edge(clk) then
            valid <= p_valid;
            h_inf_re <= p_h_inf_re;
            h_inf_im <= p_h_inf_im;
            h_sup_re <= p_h_sup_re;
            h_sup_im <= p_h_sup_im;
        end if;
    end process;

    main : process (write_enable,PRBS,piloto_y_re,piloto_y_im)
        
    begin
        -- only advance when enable = 1
        if write_enable = '1' then
            
            -- if so, systems keep working
            p_valid <= '1';

            -- changing sign depending on PRBS
            if PRBS = '1' then
                p_h_sup_re <= piloto_y_re;
                p_h_sup_im <= piloto_y_im;
                p_h_inf_re <= h_sup_re;
                p_h_inf_im <= h_sup_im;
            else
                p_h_sup_re <= -piloto_y_re;
                p_h_sup_im <= -piloto_y_im;
                p_h_inf_re <= h_sup_re;
                p_h_inf_im <= h_sup_im;
            end if;
            
        else

            p_valid <= '0';
            p_h_inf_re <= h_inf_re;
            p_h_inf_im <= h_inf_im;
            p_h_sup_re <= h_sup_re;
            p_h_sup_im <= h_sup_im;

        end if;

    end process;

end architecture;