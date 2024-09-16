library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.contador8bits;
use work.contador1_12;

library work;
use work.top_config.all;

entity contadorCtrlRAMnonGeneric is
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        ena   : in std_logic;
        ena_write : out std_logic;
        address : out unsigned(7 downto 0)
    );
end entity;

architecture contCtrlRAM_arch of contadorCtrlRAMnonGeneric is

    signal cuenta_master : std_logic_vector(3 downto 0);
    signal enable_write, p_ena_write,s_ena_write,enable_slave,p_enable_slave : std_logic  := '0';
    signal p_address_vec,address_vec : std_logic_vector(7 downto 0) := (others => '0') ;
    
    -- component contador is
    --     generic( N : integer := 8 );
    --     port (
    --       rst    : in  std_logic;
    --       clk    : in  std_logic;
    --       ena    : in  std_logic;
    --       cuenta : out std_logic_vector(N-1 downto 0)
    --     );
    -- end component;
    component contador8bits is
        port (
          rst    : in  std_logic;
          clk    : in  std_logic;
          ena    : in  std_logic;
          cuenta : out std_logic_vector(7 downto 0)
        );
    end component;
begin

    -- address <= unsigned(address_vec);
    address <= (others => '0') ;
    ena_write <= s_ena_write;

    c1_12 : entity work.contador1_12
    port map (
        rst    => rst,
        clk    => clk,
        ena    => ena,
        cuenta => cuenta_master
    );

    -- counter1_1 : contador
    -- generic map (
    --     N => ADDR_WIDTH
    -- )
    -- port map (
    --     rst     => rst,
    --     clk     => clk,
    --     ena     => enable_slave,
    --     cuenta  => address_vec
    -- );
    counter1_1 : contador8bits
    port map (
        rst     => rst,
        clk     => clk,
        ena     => enable_slave,
        cuenta  => address_vec
    );
    
    comb : process (ena,cuenta_master)
    begin
        if ena = '1' then
            -- p_ena_write <= s_ena_write;
            if cuenta_master = "0000" then
                p_ena_write <= '1';
                p_enable_slave <= '1';
            else
                p_ena_write <= '0';
                p_enable_slave <= '0';
            end if;   
        else
            p_ena_write <= '0'; 
            p_enable_slave <= '0';  
        end if;  
    end process;
    
    sinc: process (rst, clk)
    begin
      if rst = '1' then
        address_vec <= (others => '0');
        s_ena_write <= '0';
        enable_slave <= '0';
      elsif rising_edge(clk) then
        address_vec <= p_address_vec;
        s_ena_write <= p_ena_write;
        enable_slave <= p_enable_slave;
      end if;
    end process;

end architecture;