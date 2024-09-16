library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delayer is
    port (
        clk   : in std_logic;
        rst : in std_logic;
        data_in : in signed(9 downto 0);
        data_out : out signed(9 downto 0)
    );
end entity;

architecture delayer_arch of delayer is

    signal p_data,data : signed(9 downto 0);

begin
    
    data_out <= data;
    p_data <= data_in;
   
    sinc: process (clk)
    begin
      if rst = '1' then
        data <= (others => '0'); 
      elsif rising_edge(clk) then
        data <= p_data;
      end if;
    end process;

end architecture;