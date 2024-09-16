library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registro is
    generic (
        delay : Integer := 15
    );
    port (
        clk   : in std_logic;
        rst : in std_logic;
        ena : in std_logic;
        input : in signed(9 downto 0);

        output : out signed(9 downto 0)
    );
end entity;


architecture registro_arch of registro is

    type reg is array (0 to delay-1) of signed(9 downto 0);
    signal p_regis,regis : reg := (others => (others => '0'));

begin

    output <= regis(delay-1);

    comb: process (regis, ena, input)
    begin
      if ena = '1' then
        p_regis(1 to delay-1) <= regis(0 to delay-2);
        p_regis(0) <= input;
      else
        p_regis <= regis;
      end if;  
    end process;
    
    sinc: process (rst, clk)
    begin
      if rst = '1' then
        regis <= (others => (others => '0'));
      elsif rising_edge(clk) then
        regis <= p_regis;
      end if;
    end process;

end architecture;