library IEEE;
use IEEE.std_logic_1164.all;

entity mux3when is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
end mux3when;

architecture mux3when_arch of mux3when is

begin
    salida <=   entradas(0) when sel = "00" else
                entradas(1) when sel = "01" else
                entradas(2) when sel = "10" else
                entradas(3);

end mux3when_arch;
