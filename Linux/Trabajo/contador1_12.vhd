library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Simple counter which counts from 0 to 11 cyclicly

entity contador1_12 is
  -- Generic defines beginning value for counter, in case is needed an uncommon start
  generic (
    start : integer := 11
  );
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    ena    : in  std_logic;
    cuenta : out unsigned(3 downto 0)
  );
end contador1_12;

architecture contador1_12_arch of contador1_12 is

  signal cont, p_cont : unsigned(3 downto 0);

begin

  cuenta <= cont;
  
  comb: process (cont, ena)
  begin
    if ena = '1' then
    -- if it has reached the end, reset
        if cont = 11 then
            p_cont <= (others => '0');
        else
            p_cont <= cont + 1;
        end if;
    else
      p_cont <= cont;    
    end if;  
  end process;
  
  sinc: process (rst, clk)
  begin
    if rst = '1' then
      -- Usage of generic for initialization
      cont <= to_unsigned(start,cont'length);
    elsif rising_edge(clk) then
      cont <= p_cont;
    end if;
  end process;

end contador1_12_arch;

