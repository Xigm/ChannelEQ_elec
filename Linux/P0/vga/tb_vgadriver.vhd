library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity tb_vgadriver is
end tb_vgadriver;

architecture tb_vgadriver_arch of tb_vgadriver is

  -- Signals for the UUT
  signal clk, rst, hs, vs : std_logic;
  signal r, g, b          : std_logic;
  signal button_left, button_center, button_right: std_logic;
  signal aux : real;

  -- Simulation control
  -- clk freq is 25 MHz
  constant NCYCLES    : integer := 2*640*480+1000;
  constant clk_period : time    := 40 ns;
  signal endsim       : boolean := false;

  procedure uniform2(variable SEED1, SEED2 : inout POSITIVE; signal button : out std_logic) is
      begin
        uniform(seed1,seed2,aux);
        button <= std_logic_vector((round(aux)));
  end procedure;

begin

  -- Instance of the UUT
  vgadriver_inst : entity work.vgadriver
    port map (
      clk => clk,
      rst => rst,
      button_left => button_left,
      button_center => button_center,
      button_right => button_right,
      hs  => hs,
      vs  => vs,
      r   => r,
      g   => g,
      b   => b
      );

  -- clk generation
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    if endsim = true then
      wait;
    end if;
  end process;

  -- Rest of stimuli
  stim_process : process
  begin
    rst    <= '1';
    wait for 4*clk_period;
    rst    <= '0';
    for i in NCYCLES to 0 loop
      wait for clk_period;
         uniform2("1","2",button_left);
         uniform2("1","2",button_center);
         uniform2("1","2",button_right);
    end loop; -- buclesimul 
    wait for NCYCLES*clk_period;
    endsim <= true;
    wait;
  end process;


end tb_vgadriver_arch;
