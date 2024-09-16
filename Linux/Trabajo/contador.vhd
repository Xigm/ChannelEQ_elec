library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity contador is
  generic( N : integer := 8 );
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    ena    : in  std_logic;
    cuenta : out std_logic_vector(N-1 downto 0);
    change : out std_logic
  );
end contador;

architecture contador_arch of contador is

  signal cont, p_cont : unsigned(N-1 downto 0);
  signal chgn, p_chgn : std_logic;

begin

  cuenta <= std_logic_vector(cont);
  change <= chgn;
  
  comb: process (cont, ena)
  begin
    if ena = '1' then
      p_cont <= cont + 1;
      p_chgn <= '1';
    else
      p_cont <= cont;   
      p_chgn <= '0'; 
    end if;  
  end process;
  
  sinc: process (rst, clk)
  begin
    if rst = '1' then
      cont <= (others => '0');
      chgn <= '0';
    elsif rising_edge(clk) then
      cont <= p_cont;
      chgn <= p_chgn;
    end if;
  end process;

end contador_arch;

