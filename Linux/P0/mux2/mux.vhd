library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity mux is
    generic (N: integer := 2);
    port ( entrada : in  std_logic_vector(N-1 downto 0);
           salida  : out std_logic;
           selector : in std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0)
       );
end mux;

architecture mux_arch of mux is

begin

    process (selector,entrada)
    begin
        salida <= entrada(to_integer(unsigned(selector)));
    end process;

end mux_arch;
