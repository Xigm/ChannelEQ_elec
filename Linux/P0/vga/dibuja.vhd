library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity dibuja is
  port (
    button_left   : in  std_logic;
    button_center : in  std_logic;
    button_right  : in  std_logic;
    R             : out std_logic;
    G             : out std_logic;
    B             : out std_logic;
    eje_x         : in  std_logic_vector (9 downto 0);
    eje_y         : in  std_logic_vector (9 downto 0));
end dibuja;

architecture Behavioral of dibuja is

  signal buttons          : std_logic_vector(2 downto 0);

begin

  buttons <= button_left & button_center & button_right;

  process(eje_x, eje_y, buttons)
  begin

    case buttons is

      -- Cyan screen
      when "111" =>
        R <= '0'; G <= '1'; B <= '1';

      -- Andalusia
      when "001" =>
        R <= '0'; G <= '1'; B <= '0';
        if((to_integer(unsigned(eje_y)) > 119) and (to_integer(unsigned(eje_y)) < 359)) then
          R <= '1'; G <= '1'; B <= '1';
        else
          R <= '0'; G <= '1'; B <= '0';
        end if;

      -- Blue Screen
      when "010" =>
        R <= '0'; G <= '0'; B <= '1';

      -- Spain
      when "100" =>
        if((to_integer(unsigned(eje_y)) > 119) and (to_integer(unsigned(eje_y)) < 359)) then
          R <= '1'; G <= '1'; B <= '0';
        else
          R <= '1'; G <= '0'; B <= '0';
        end if;

      -- Homage to Jon Tombs
      when "000" =>
        R <= '1'; G <= '1'; B <= '1';
        if ( (to_integer(unsigned(eje_x)) > 279 and 
              to_integer(unsigned(eje_x)) < 359) or
             (to_integer(unsigned(eje_y)) > 209 and
              to_integer(unsigned(eje_y)) < 269)) then
                R <= '1'; G <= '0'; B <= '0';
        end if;

      when others =>
        R <= '1'; G <= '1'; B <= '1';

    end case;
  end process;

end Behavioral;
