library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eq is
    generic (
        output_prec : Integer := 32 
    );
    port (
        clk   : in std_logic;
        rst : in std_logic;
        h_re : in signed(9 downto 0);
        h_im : in signed(9 downto 0);
        y_re : in signed(9 downto 0);
        y_im : in signed(9 downto 0);
        valid : in std_logic;

        -- output is the x with the channel effects reverted
        -- size of output is too large, in future updates should consider using a smaller vector, maximizing range usage
        x_eq_re : out signed(output_prec-1 downto 0);
        x_eq_im : out signed(output_prec-1 downto 0);
        eq_valid : out std_logic
    );
end entity;

architecture arch_eq of eq is

    signal conj_h_im : signed(9 downto 0);
    signal divisor : signed(19 downto 0);
    signal div_re, div_im :  signed(9 downto 0);
    signal sq_y_re, sq_y_im : signed(19 downto 0);
    signal sq_y_im_trunc, sq_y_re_trunc: signed(9 downto 0);
    signal num_re,num_im : signed(19 downto 0);
    signal num_re_long, num_im_long : signed(output_prec-1 downto 0) := (others => '0'); 
    
    
begin

    -- much past code is commented below, even if this is the final version, i like keeping old strats on how to approach the problem around, you never know when it may come handy
    -- tho, some cleaning would be nice

    -- valid signal connected through th block
    eq_valid <= valid;

    -- y_re_delayed should be very delayed (future me: not that delayed, just three cycles if comb eq)

    -- squared abs of estimated channel
    sq_y_re <= h_re*h_re;
    sq_y_im <= h_im*h_im;

    -- embarrasing workaround, dangerous if sq_y_re and sq_y_im take its max values, safe any other case
    divisor <= sq_y_re + sq_y_im + to_signed(1,divisor'length);

    -- applying complex multiplication formulae, in this case (a+b*i)*(c-d*i) = (e +f*i)
    -- e = a*c + b*d
    -- f = b*c - a*d
    num_re <= h_re*y_re + y_im*h_im;
    num_im <= y_im*h_re - y_re*h_im;

    -- aplying scale of 2¹² bits, maybe too much...
    num_re_long(output_prec-1 downto output_prec-20) <= num_re;
    num_im_long(output_prec-1 downto output_prec-20) <= num_im;

    -- comb division, unadvised because large area usage. 
    x_eq_re <= num_re_long/divisor(18 downto 0);
    x_eq_im <= num_im_long/divisor(18 downto 0);

    

    -- conj_h_im <= -h_im;

    -- -- sq_y_re_trunc <= if sq_y_re(19 downto 10) = (others => '0') then (0 => '1', (others => '0')) else sq_y_re(19 downto 10);
    -- -- sq_y_im_trunc <= if sq_y_im(19 downto 10) = (others => '0') then (0 => '1', (others => '0')) else sq_y_im(19 downto 10);

    -- with sq_y_re(19 downto 10) select
    --     sq_y_re_trunc <= "0000000001" when (others => '0'), 
    --                     sq_y_re(19 downto 10) when others;

    -- with sq_y_im(19 downto 10) select
    --     sq_y_im_trunc <= "0000000001" when (others => '0'), 
    --                     sq_y_im(19 downto 10) when others;
    
    -- divisor <= sq_y_re_trunc + sq_y_im_trunc;

    -- -- div_re2 <= h_re/divisor2;
    -- -- div_im2 <= conj_h_im/divisor2;

    -- div_re <= h_re/divisor;
    -- div_im <= conj_h_im/divisor;

    -- x_eq_re <= y_re*div_re + y_im*div_im;
    -- x_eq_im <= y_im*div_re - y_re*div_im;

end architecture;