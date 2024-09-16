library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- pseudo random binary sequence generator

entity PRBS is
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    ena : in std_ulogic;
    signo : out std_ulogic
  );
end entity;

architecture arch_PRBS of PRBS is

  signal reg, preg : std_ulogic_vector(11 downto 1) := (others => '1');

begin
  -- output of the PRBS
  signo <= reg(11);

  process (reg)
  begin
      -- not working till GHDL_ARGS ?= --std=08 is used in GHDL compiler from cocotb (thanks to @hipolitoguzman)
      preg <= (11 downto 2 => reg(10 downto 1), 1 => reg(11) xor reg(9));
      
      -- workaround
      -- preg(11 downto 2) <= reg(10 downto 1);
      -- preg(1) <= reg(11) xor reg(9);
  end process;

  process (clk,rst)
  begin
    if rst = '1' then
      -- indexin n slicin
      reg <= (11 => '0',10 => '1', others => '1');
    elsif rising_edge(clk) then
      if ena = '1' then
        reg <= preg;
      else
        reg <= reg;
      end if;
    end if;
  end process;

end architecture;