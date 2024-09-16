library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity contador is
  generic( N : integer := 8 );
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    ena    : in  std_logic;
    cuenta : out std_logic_vector(N-1 downto 0)
  );
end contador;

architecture contador_arch of contador is

  signal cont, p_cont : unsigned(N-1 downto 0);

begin

  cuenta <= std_logic_vector(cont);
  
  comb: process (cont, ena)
  begin
    if ena = '1' then
      p_cont <= cont + 1;
    else
      p_cont <= cont;    
    end if;  
  end process;
  
  sinc: process (rst, clk)
  begin
    if rst = '1' then
      cont <= (others => '0');
    elsif rising_edge(clk) then
      cont <= p_cont;
    end if;
  end process;

end contador_arch;

