library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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
  signal piloto : std_ulogic_vector(1 downto 0);
begin

  signo <= reg(11);
  piloto <= (1 => '0',0 => reg(11));
  process (rst, reg)
  begin
    if rst = '1' then
      preg <= (others => '1');
    else
      -- Esto no le gusta al compilador de cocotb (que es ghdl xd)
      preg <= (11 downto 2 => reg(10 downto 1), 1 => reg(11) xor reg(9));
      
      -- workaround
      -- preg(11 downto 2) <= reg(10 downto 1);
      -- preg(1) <= reg(11) xor reg(9);
    end if;
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      if ena = '1' then
        reg <= preg;
      else
        reg <= reg;
      end if;
    end if;
  end process;

end architecture;