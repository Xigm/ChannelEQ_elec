library IEEE;
use IEEE.std_logic_1164.all;

entity tb_contador is
  generic (N : integer := 8);
end tb_contador;

architecture tb_contador_arch of tb_contador is

  -- Declaramos el contador como component
  component contador is
    generic( N : integer := 8 );
    port (
      rst    : in  std_logic;
      clk    : in  std_logic;
      ena    : in  std_logic;
      cuenta : out std_logic_vector(N-1 downto 0)
     );
  end component;

  -- Declaramos los signals que necesitamos para conectar
  -- la instancia del contador
  signal rst : std_logic := '0';
  signal clk : std_logic := '0';
  signal ena : std_logic := '0';
  signal cuenta: std_logic_vector(N-1 downto 0);

  -- Control de la simulacion
  constant clk_period : time := 10 ns;
  signal endsim : boolean := false;

begin

  -- Instanciamos el contador
  contador_inst : contador
  generic map ( N => N )
  port map (
    rst => rst,
    clk => clk,
    ena => ena,
    cuenta => cuenta
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
	  wait for 4*clk_period;
	  rst <= '0';
	  wait for 10*clk_period;
	  ena <= '1';
	  --wait for (2**N)*clk_period;
	  wait for 300*clk_period;
	  wait for 10*clk_period;
	  endsim <= true;
	  wait;
  end process;

end tb_contador_arch;
