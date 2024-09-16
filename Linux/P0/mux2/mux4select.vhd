library IEEE;
use IEEE.std_logic_1164.all;

entity mux4select is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
end mux4select;

architecture mux4select_arch of mux4select is

begin
    with sel select
                salida <= entradas(0) when "00",
                        entradas(1) when "01",
                        entradas(2) when "10",
                        entradas(3) when others;
end mux4select_arch;
