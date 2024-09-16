library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity tb_mux is
    constant N : integer := 8;
end tb_mux;

architecture tb_mux_arch of tb_mux is

  -- Declaramos leds como component
  component mux is
    generic ( N : integer);
    port ( entrada : in  std_logic_vector(N-1 downto 0);
           salida  : out std_logic;
           selector : in std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0)
       );
  end component;

  -- Declaramos los signals que necesitamos para conectar
  -- la instancia del contador

  signal entrada : std_logic_vector(N-1 downto 0) := "01010101";
  signal salida : std_logic;
  signal selector: std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0) := "000";

  -- Control de la simulacion
  constant clk_period : time := 10 ns;
  signal clk: std_logic := '0';
  signal endsim : boolean := false;

begin

  -- Instanciamos leds
  mux_inst: mux
  generic map(
      N => 8
  )
  port map (
    entrada => entrada,
    salida => salida,
    selector => selector
  );

  -- Generación de reloj
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    if endsim=true then
      wait;
    end if;
  end process;

  -- Proceso de estimulos
  stim_process : process
  begin
	  wait for clk_period;
        selector <= "000";
	  wait for 4*clk_period;
        selector <= "001";
	  wait for 6*clk_period;
        selector <= "010";
      wait for 5*clk_period;
        selector <= "011";
      wait for 4*clk_period;
        endsim <= true;
	  wait;
  end process;

end tb_mux_arch;
