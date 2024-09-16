library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity comparador is
  generic (Nbit           : integer := 8;
           End_Of_Screen  : integer := 10;
           Start_Of_Pulse : integer := 20;
           End_Of_Pulse   : integer := 30;
           End_Of_Line    : integer := 40);
  port (clk  : in  std_logic;
        rst  : in  std_logic;
        data : in  std_logic_vector (Nbit-1 downto 0);
        O1   : out std_logic;
        O2   : out std_logic;
        O3   : out std_logic);
end comparador;

architecture Behavioral of comparador is
  signal p_O1, p_O2, p_O3 : std_logic;


begin

  comb : process(data)
  begin
    if (to_integer(unsigned(data)) > End_Of_Screen) then
      p_O1 <= '1';
    else
      p_O1 <= '0';
    end if;

    if ((to_integer(unsigned(data)) < End_Of_Pulse) and (to_integer(unsigned(data)) >= Start_Of_Pulse)) then
      p_O2 <= '0';
    else
      p_O2 <= '1';
    end if;

    if (to_integer(unsigned(data)) = End_Of_Line) then
      p_O3 <= '1';
    else
      p_O3 <= '0';
    end if;
  end process;

  sinc : process(clk, rst)
  begin
    if rst = '1' then
      O1 <= '0';
      O2 <= '1';
      O3 <= '0';
    elsif rising_edge (clk) then
      O1 <= p_O1;
      O2 <= p_O2;
      O3 <= p_O3;
    end if;
  end process;
end Behavioral;
