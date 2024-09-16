library IEEE;
use IEEE.std_logic_1164.all;

entity leds is
    port ( entrada1 : in  std_logic;
           salida1  : out std_logic;
           entrada2 : in  std_logic;
           led1     : out std_logic;
           led2     : out std_logic;
           led3     : out std_logic
       );
end leds;

architecture leds_arch of leds is

begin

    process (entrada1)
    begin
        if entrada2 = '1' then
            salida1 <= NOT entrada1;
        else
            salida1 <= entrada1;
        end if;
    end process;

    led1 <= entrada2;
    led2 <= NOT entrada2;
    led3 <= entrada2;

end leds_arch;
