library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity contadorLeds is
    port (  enable : in  std_logic;
            clk : in  std_logic;
            cont: out std_logic_vector(2**8-1 downto 0);
            rst: in std_logic;
            sat: out std_logic := '0'
        );

end contadorLeds;

architecture contadorLeds_arch of contadorLeds is

component contadorbyme is
    generic(N : integer := 8;sat_value : integer := 2**8-1);
    port (
        enable : in  std_logic;
        updown  : in std_logic;
        clk : in  std_logic;
        cont: out std_logic_vector(N-1 downto 0);
        rst: in std_logic;
        sat: out std_logic := '0'  
    );
end component;

begin

    counterInst: contadorbyme
        generic map (
            N => 2**8,sat_value => 100
        )
        port map (
            enable => enable,
            updown => '1',
            clk => clk,
            cont => cont,
            rst => rst,
            sat => sat
        );
    

end architecture;