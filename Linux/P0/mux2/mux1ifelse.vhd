library IEEE;
use IEEE.std_logic_1164.all;

entity mux1ifelse is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
end mux1ifelse;

architecture mux1ifelse_arch of mux1ifelse is

begin

    process (sel)
    begin
        if sel = "00" then
            salida <= entradas(0);
        elsif sel = "01" then
            salida <= entradas(1);
        elsif sel = "10" then
            salida <= entradas(2);
        else
            salida <= entradas(3);
        end if;
    end process;

end mux1ifelse_arch;
