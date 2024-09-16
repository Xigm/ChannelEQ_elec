library IEEE;
use IEEE.std_logic_1164.all;

entity tb_contadorbyme is
    
end tb_contadorbyme;

architecture tb_contadorbyme_arch of tb_contadorbyme is

  -- Declaramos leds como component
  component contadorbyme is
    generic(N : integer := 8);
    port ( enable : in  std_logic;
           updown  : in std_logic;
           clk : in  std_logic;
           cont: out std_logic_vector(N-1 downto 0);
           rst : in std_logic;
           sat : out std_logic
       );
  end component;

  -- Declaramos los signals que necesitamos para conectar
  -- la instancia del contador
  constant N: integer := 8;
  signal enable : std_logic := '0';
  signal updown : std_logic := '1';
  signal clk : std_logic;
  signal cont: std_logic_vector(N-1 downto 0) := "00000000";
  signal rst : std_logic := '0';
  

  -- Control de la simulacion
  constant clk_period : time := 1 ns;
  signal endsim : boolean := false;

begin

  -- Instanciamos leds
  contadorbyme_inst: contadorbyme
  port map (
    enable => enable,
    updown => updown,
    clk => clk,
    rst => rst
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
          updown <= '1';
	  wait for 4*clk_period;
	  wait for 4*clk_period;
      enable <= '0';
    wait for 2*clk_period;
      enable <= '1';
    wait for 4*clk_period;
      updown <= '0';
    wait for 8*clk_period;
      -- updown <= '1';
    wait for 4*clk_period;
    wait for 400*clk_period;
          endsim <= true;
	  wait;
  end process;

end tb_contadorbyme_arch;
