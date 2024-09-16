library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_tb is
end;

architecture bench of contador_tb is

  component contador
      port (
      clk : in std_logic;
      reset : in std_logic;
      enable : in std_logic;
      cont : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics

  -- Ports
  signal clk : std_logic;
  signal reset : std_logic;
  signal enable : std_logic;
  signal cont : std_logic_vector(7 downto 0);

  -- Simulation control
  signal endsim : boolean := false;

begin

  contador_inst : contador
    port map (
      clk => clk,
      reset => reset,
      enable => enable,
      cont => cont
    );

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
        
    stim_process : process
        begin
        reset <= '1';
        enable <= '0';
        wait for 2 * clk_period;
        reset <= '0';
        enable <= '1';
        wait for 100 * clk_period;
        endsim <= true;
        wait;
    end process;
          
end;
