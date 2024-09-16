-- This code infers a BRAM when synthesized
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram is
  generic (
    DATA_WIDTH : integer := 8;
    ADDR_WIDTH : integer := 8
    );
  port (clk   : in  std_logic;
        addri : in  unsigned (ADDR_WIDTH-1 downto 0);
        datai : in  std_logic_vector (DATA_WIDTH-1 downto 0);
        we    : in  std_logic;
        datao : out std_logic_vector (DATA_WIDTH-1 downto 0));
end bram;

architecture bram_arch of bram is

  type ram_type is array ((2**ADDR_WIDTH)-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
  signal ram : ram_type;

begin

  -- When synthesizing this process, the synthesizer infers a BRAM 
  process(clk)
  begin
    if (rising_edge(clk)) then
      if (we = '1') then
        ram(to_integer(addri)) <= datai;
      end if;
      datao <= ram(to_integer(addri));
    end if;
  end process;

end bram_arch;
