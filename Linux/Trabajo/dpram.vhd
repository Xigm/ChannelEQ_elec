-- This code infers a Dual-Port RAM when synthesized
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is
  generic (
    DATA_WIDTH : integer := 8;
    ADDR_WIDTH : integer := 8
    );
  port (clk_a   : in  std_logic;
        clk_b   : in  std_logic;
        addri_a : in  unsigned (ADDR_WIDTH-1 downto 0); 
        datai_a : in  std_logic_vector (DATA_WIDTH-1 downto 0);
        we_a    : in  std_logic;
        datao_a : out std_logic_vector (DATA_WIDTH-1 downto 0);
        addri_b : in  unsigned (ADDR_WIDTH-1 downto 0);
        datai_b : in  std_logic_vector (DATA_WIDTH-1 downto 0);
        we_b    : in  std_logic;
        datao_b : out std_logic_vector (DATA_WIDTH-1 downto 0));
end dpram;

architecture dpram_arch of dpram is

  type ram_type is array ((2**ADDR_WIDTH)-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
  signal ram : ram_type;

begin

  -- When synthesizing this process, the synthesizer infers a BRAM 
  process(clk_a, clk_b)
  begin

    if (rising_edge(clk_a)) then
      if (we_a = '1') then
        ram(to_integer(addri_a)) <= datai_a;
      end if;
        datao_a <= ram(to_integer(addri_a));
    end if;

    if (rising_edge(clk_b)) then
      if (we_b = '1') then
        ram(to_integer(addri_b)) <= datai_b;
      end if;
      datao_b <= ram(to_integer(addri_b));
    end if;

  end process;

end dpram_arch;
