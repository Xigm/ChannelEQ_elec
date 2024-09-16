library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package edc_common is

    type complex10 is
        record
            re : signed(9 downto 0);
            im : signed(9 downto 0);
        end record;

    type complex15 is
        record
            re : signed(14 downto 0);
            im : signed(14 downto 0);
        end record;

end edc_common;

package body edc_common is

end edc_common;
