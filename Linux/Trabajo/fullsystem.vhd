library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- toplevel of estimator + eq + register

entity fullsystem is
    generic (
        output_prec : Integer := 23
    );
    port (
        -- inputs are the same as in estimator
        clk   : in std_logic;
        rst : in std_logic;

        y_re, y_im : in signed(9 downto 0);
        y_valid : in std_logic;

        -- and outputs the same as eq
        x_eq_out_re : out signed(output_prec-1 downto 0);
        x_eq_out_im : out signed(output_prec-1 downto 0);
        eq_valid_out : out std_logic
    );
end entity;

architecture arch_fullsystem of fullsystem is

    signal estim_valid : std_logic;
    signal out_estim_re, out_estim_im : signed(9 downto 0);
    signal y_re_delayed_1,y_re_delayed_2,y_re_delayed_3,y_re_delayed_4 : signed(9 downto 0);
    signal y_im_delayed_1,y_im_delayed_2,y_im_delayed_3,y_im_delayed_4 : signed(9 downto 0);
    signal data_in_eq_re, data_in_eq_im : signed(9 downto 0);
begin

   
    -- y_re_delayed_1 <= y_re;
    -- y_im_delayed_1 <= y_im;
    
    -- -- big process to create flipflops and get those signals delayed
    -- sinc : process (clk,rst)
    -- begin
    --     if rst = '1' then
    --         y_re_delayed_2 <= (others => '0');
    --         y_re_delayed_3 <= (others => '0');
    --         y_re_delayed_4 <= (others => '0');
    --         y_im_delayed_2 <= (others => '0');
    --         y_im_delayed_3 <= (others => '0');
    --         y_im_delayed_4 <= (others => '0');
    --     elsif rising_edge(clk) then
    --         y_re_delayed_2 <= y_re_delayed_1;
    --         y_re_delayed_3 <= y_re_delayed_2;
    --         y_re_delayed_4 <= y_re_delayed_3;
    --         y_im_delayed_2 <= y_im_delayed_1;
    --         y_im_delayed_3 <= y_im_delayed_2;
    --         y_im_delayed_4 <= y_im_delayed_3;
    --     end if;
    -- end process;

    estimador : entity work.toplevel
    port map (
        clk   => clk,
        rst   => rst,
        y_re   => y_re,
        y_im   => y_im,
        y_valid => y_valid,

        valid => estim_valid,
        out_re => out_estim_re,
        out_im => out_estim_im
    );

    reg_re: entity work.registro
    generic map (
        delay => 14
    )
    port map (
        clk   => clk,
        rst => rst,
        ena => y_valid,
        input => y_re,

        output => data_in_eq_re
    );

    reg_im: entity work.registro
    generic map (
        delay => 14
    )
    port map (
        clk   => clk,
        rst => rst,
        ena => y_valid,
        input => y_im,

        output => data_in_eq_im
    );
    
    eq : entity work.eq
    generic map (
        output_prec => output_prec
    )
    port map (
        clk  => clk,
        rst  => rst,
        h_re => out_estim_re,
        h_im => out_estim_im,
        y_re => data_in_eq_re,
        y_im => data_in_eq_im,
        valid => estim_valid,

        x_eq_re => x_eq_out_re,
        x_eq_im => x_eq_out_im,
        eq_valid => eq_valid_out
    );

end architecture;