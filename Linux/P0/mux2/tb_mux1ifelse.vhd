library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux1ifelse is
end tb_mux1ifelse;

architecture tb_mux1ifelse_arch of tb_mux1ifelse is

  -- Declaramos leds como component
  component mux1ifelse is
    port ( entradas : in  std_logic_vector(3 downto 0);
           salida  : out std_logic;
           sel : in std_logic_vector(1 downto 0)
       );
  end component;

  -- Declaramos los signals que necesitamos para conectar
  -- la instancia del contador
  signal entradas : std_logic_vector(3 downto 0) := "0101";
  signal sel : std_logic_vector(1 downto 0) := "00";
  signal salida: std_logic;

  -- Control de la simulacion
  constant clk_period : time := 10 ns;
  signal clk: std_logic := '0';
  signal endsim : boolean := false;

begin

  -- Instanciamos leds
  mux1ifelse_inst: mux1ifelse
  port map (
    entradas => entradas,
    salida => salida,
    sel => sel
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
        sel <= "00";
    wait for 4*clk_period;
        sel <= "01";
    wait for 6*clk_period;
        sel <= "10";
    wait for 5*clk_period;
        sel <= "11";
    wait for 4*clk_period;
        endsim <= true;
    wait;
  end process;

end tb_mux1ifelse_arch;
