library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity contador is
  port (
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    cont : out std_logic_vector(7 downto 0)
  );
end entity;

architecture contador_arch of contador is

  signal pval, val : integer := 0;

begin
  cont <= std_logic_vector(to_unsigned(val, cont'length));

  process (clk, reset)
  begin
    if (reset = '1') then
      pval <= 0;
    else
      if (rising_edge(clk) and enable = '1') then
        pval <= pval + 1;
      end if;
    end if;
  end process;

  process (pval)
  begin
    val <= pval;
  end process;

end architecture;