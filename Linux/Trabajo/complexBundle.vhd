library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.edc_common.all;

entity complex is
    port (
        din : in complex10;
        dout : out complex10
    );

end complex;

architecture arch_c10 of complex is
    signal data_re,data_im : signed(9 downto 0);

begin
    data_re <= din.re;
    data_re <= data_re and data_re;
    dout.re <= din.re;

    data_im <= din.im;
    dout.im <= din.im;
end arch_c10;
