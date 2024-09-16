library IEEE;
use IEEE.std_logic_1164.all;

entity mux2case is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
end mux2case;

architecture mux2case_arch of mux2case is

begin

    process (sel)
    begin
        case sel is
            when "00" =>
            salida <= entradas(0);
            when "01" =>
            salida <= entradas(1);
            when "10" =>
            salida <= entradas(2);
            when others =>
            salida <= entradas(3);
        end case;
    end process;

end mux2case_arch;
