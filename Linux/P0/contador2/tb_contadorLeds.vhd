library IEEE;
use IEEE.std_logic_1164.all;

entity tb_contadorLeds is
    
end tb_contadorLeds;

architecture tb_contadorLeds_arch of tb_contadorLeds is

  -- Declaramos leds como component
  component contadorLeds is
    port ( enable : in  std_logic;
           clk : in  std_logic;
           cont: out std_logic_vector(2**8-1 downto 0);
           rst : in std_logic;
           sat : out std_logic
       );
  end component;

  -- Declaramos los signals que necesitamos para conectar
  -- la instancia del contador
  constant N: integer := 8;
  signal enable : std_logic := '0';
  signal clk : std_logic;
  signal cont: std_logic_vector(2**8-1 downto 0) := (others => '0');
  signal rst : std_logic := '0';
  signal sat : std_logic := '0';

  -- Control de la simulacion
  constant clk_period : time := 1 ns;
  signal endsim : boolean := false;

begin

  -- Instanciamos leds
  contadorbyme_inst: contadorLeds
  port map (
    enable => enable,
    clk => clk,
    rst => rst,
    cont => cont,
    sat => sat
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
    rst <= '1';
    enable <= '0';
    wait for clk_period;
          rst <= '0';
          enable <= '1';
	wait for 400*clk_period;
          endsim <= true;
    wait;
  end process;

end tb_contadorLeds_arch;
