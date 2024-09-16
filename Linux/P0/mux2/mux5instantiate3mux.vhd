library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity mux5instantiate3mux is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
end mux5instantiate3mux;

architecture mux5instantiate3mux_arch of mux5instantiate3mux is

component mux is 
    generic (N: integer := 8);
    port ( entrada : in  std_logic_vector(N-1 downto 0);
           salida  : out std_logic;
           selector : in std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0));
end component;

signal inJ: std_logic_vector(1 downto 0);
begin
    mux_inst1 : mux
    generic map ( N => 2)
    port map (
                entrada => entradas(3 downto 2),
                salida => inj(1),
                selector => sel(0 downto 0)
                );

    mux_inst2 : mux
    generic map ( N => 2)
    port map (
                entrada => entradas(1 downto 0),
                salida => inJ(0),
                selector => sel(0 downto 0)
                );

    mux_instJoin : mux
    generic map ( N => 2)
    port map (
                --entrada => [mux_inst1.salida,mux_inst2.salida], MATLAB
                --entrada => np.r_[mux_inst1.salida,mux_inst2.salida],  Python
                entrada => inJ,
                salida => salida,
                selector => sel(1 downto 1)
                );

end mux5instantiate3mux_arch;
