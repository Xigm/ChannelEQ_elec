library IEEE;
use IEEE.std_logic_1164.all;

entity tb_leds is
end tb_leds;

architecture tb_leds_arch of tb_leds is

  -- Declaramos leds como component
  component leds is
    port( entrada1 : in  std_logic;
          salida1  : out std_logic;
          entrada2 : in  std_logic;
          led1     : out std_logic;
          led2     : out std_logic;
          led3     : out std_logic
    );
  end component;

  -- Declaramos los signals que necesitamos para conectar
  -- la instancia del contador
  signal entrada1 : std_logic := '0';
  signal entrada2 : std_logic := '0';
  signal salida1 : std_logic;
  signal led1 : std_logic;
  signal led2 : std_logic;
  signal led3 : std_logic;

  -- Control de la simulacion
  constant clk_period : time := 10 ns;
  signal clk: std_logic := '0';
  signal endsim : boolean := false;

begin

  -- Instanciamos leds
  leds_inst: leds
  port map (
    entrada1 => entrada1,
    salida1 => salida1,
    entrada2 => entrada2,
    led1 => led1,
    led2 => led2,
    led3 => led3
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
          entrada1 <= '1';
	  wait for 4*clk_period;
	  entrada2 <= '1';
	  wait for 6*clk_period;
          entrada1 <= '0';
          wait for 5*clk_period;
          entrada2 <= '0';
          wait for 4*clk_period;
          endsim <= true;
	  wait;
  end process;

end tb_leds_arch;
