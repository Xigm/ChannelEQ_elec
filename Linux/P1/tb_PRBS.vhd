library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PRBS_tb is
end;

architecture bench of PRBS_tb is

  component PRBS
      port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      ena : in std_ulogic;
      signo : out std_ulogic
    );
  end component;

  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics

  -- Ports
  signal clk : std_ulogic;
  signal rst : std_ulogic;
  signal ena : std_ulogic;
  signal signo : std_ulogic;

    -- Simulation control
  signal endsim : boolean := false;

begin

  PRBS_inst : PRBS
    port map (
      clk => clk,
      rst => rst,
      ena => ena,
      signo => signo
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
        rst <= '1';
        ena <= '0';
        wait for 2 * clk_period;
        rst <= '0';
        ena <= '1';
        wait for 100 * clk_period;
        endsim <= true;
        wait;
    end process;
end;
