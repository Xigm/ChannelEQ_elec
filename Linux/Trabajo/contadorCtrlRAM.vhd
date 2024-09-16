library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.contador8bits;
use work.contador1_12;

library work;
use work.top_config.all;

entity contadorCtrlRAM is
    generic (ADDR_WIDTH : integer := 8);
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        ena   : in std_logic;
        ena_write : out std_logic;
        address : out unsigned(ADDR_WIDTH-1 downto 0)
    );
end entity;

architecture contCtrlRAM_arch of contadorCtrlRAM is

    signal cuenta_master : unsigned(3 downto 0);
    signal enable_write, s_ena_write,enable_slave,p_enable_slave : std_logic  := '0';
    signal p_address_vec,address_vec : unsigned(ADDR_WIDTH-1 downto 0);
    signal unsadd_stdadd : std_logic_vector(ADDR_WIDTH-1 downto 0);
    
    component contador is
        generic( N : integer := 8 );
        port (
          rst    : in  std_logic;
          clk    : in  std_logic;
          ena    : in  std_logic;
          cuenta : out std_logic_vector(N-1 downto 0);
          change : out std_logic
        );
    end component;

begin

    address <= unsigned(unsadd_stdadd);
    ena_write <= s_ena_write;

    c1_12 : entity work.contador1_12
    port map (
        rst    => rst,
        clk    => clk,
        ena    => ena,
        cuenta => cuenta_master
    );

    counter1_1 : contador
    generic map (
        N => ADDR_WIDTH
    )
    port map (
        rst     => rst,
        clk     => clk,
        ena     => enable_slave,
        cuenta  => unsadd_stdadd,
        change  => s_ena_write
    );
    
    comb : process (ena,cuenta_master)
    begin
        if ena = '1' then
            -- p_ena_write <= s_ena_write;
            if cuenta_master = "0000" then
                -- p_ena_write <= '1';
                p_enable_slave <= '1';
                p_address_vec <= address_vec +1;
            else
                -- p_ena_write <= '0';
                p_enable_slave <= '0';
                p_address_vec <= address_vec;
            end if;   
        else
            -- p_ena_write <= '0'; 
            p_enable_slave <= '0';  
            p_address_vec <= address_vec;
        end if;  
    end process;
    
    sinc: process (rst, clk)
    begin
      if rst = '1' then
        address_vec <= (others => '0');
        -- s_ena_write <= '0';
        enable_slave <= '0';
      elsif rising_edge(clk) then
        address_vec <= p_address_vec;
        -- s_ena_write <= p_ena_write;
        enable_slave <= p_enable_slave;
      end if;
    end process;

end architecture;