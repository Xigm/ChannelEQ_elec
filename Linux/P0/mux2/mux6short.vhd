library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity mux6short is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
end mux6short;

architecture mux6short_arch of mux6short is

begin

    salida <= entradas(to_integer(unsigned(sel)));

end mux6short_arch;
