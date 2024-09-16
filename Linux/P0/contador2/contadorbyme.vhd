library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

---Escribir desde cero un contador de 8 bits sencillo, con un proceso
---combinacional que únicamente incremente el próximo valor de la cuenta y un
---proceso síncrono que incluya un reset asíncrono.
---Añadir entrada enable al contador

---Si enable vale '0', no se modifica el valor de la cuenta. Si vale
---'1', se incrementa en '1'.


---Añadir un generic, N, para convertirlo en un contador genérico de N
---bits.
---Añadir un puerto de entrada updown

---Mientras el contador esté habilitado, si updown vale '1', debe
---contar hacia arriba, mientras que si vale '0', debe contar hacia abajo.
---Si el contador está deshabilitado, no se modifica el valor de la
---cuenta, independientemente del valor de updown.


---Añadir un generic, SAT_VALUE, de tipo integer (range 0 to 2**N-1),
---y una nueva salida, sat, de forma que cuando el valor de cuenta sea
---igual a SAT_VALUE y el contador esté habilitado:

---La salida sat se active combinacionalmente
---El próximo valor de la cuenta sea 0
---Se deja al alumno las posibles consideraciones de cómo este nuevo
---comportamiento se vería afectado por la entrada updown

entity contadorbyme is
    generic(N : integer := 8;sat_value : integer := 2**8-1);
    port ( enable : in  std_logic;
           updown  : in std_logic;
           clk : in  std_logic;
           cont: out std_logic_vector(N-1 downto 0);
           rst: in std_logic;
           sat: out std_logic := '0'
       );
end contadorbyme;

architecture contadorbyme_arch of contadorbyme is

    signal acont,pcont: integer := 0;

begin

    cont <= std_logic_vector(to_unsigned(pcont,cont'length));
    process (clk)
    begin
        if enable = '1' then
            if rising_edge(clk) then
                pcont <= acont;
            end if;
        end if;
    end process;

    process (pcont)
    begin
        if updown='1' then
            if pcont = sat_value then
                sat <= '1';
                acont <= 0;
            else
                acont <= pcont + 1;
                sat <= '0';
            end if;
        else 
            if pcont = 0 then
                sat <= '1';
                acont <= 0;
            else
                acont <= pcont - 1;
                sat <= '0';
            end if;
        end if;
    end process;


end contadorbyme_arch;
