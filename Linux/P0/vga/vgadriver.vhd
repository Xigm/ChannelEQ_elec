library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity vgadriver is
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    button_left   : in  std_logic;
    button_center : in  std_logic;
    button_right  : in  std_logic;
    x             : out unsigned(9 downto 0);
    y             : out unsigned(9 downto 0);
    VS            : out std_logic;
    HS            : out std_logic;
    R             : out std_logic;
    G             : out std_logic;
    B             : out std_logic);
end vgadriver;

architecture Behavioral of vgadriver is
  signal O3_compX, O3_compY : std_logic;
  signal Blank_x, Blank_y   : std_logic;
  signal enable_contY       : std_logic;
  signal R_in, G_in, B_in   : std_logic;
  signal p_R, p_G, p_B      : std_logic;

  signal eje_x, eje_y : std_logic_vector (9 downto 0);

  component contador is
    generic (Nbit : integer := 8);
    port(clk    : in  std_logic;
         rst    : in  std_logic;
         rsts   : in  std_logic;
         enable : in  std_logic;
         Q      : out std_logic_vector ((Nbit - 1) downto 0));
  end component;

  component comparador is
    generic (Nbit           : integer := 8;
             End_Of_Screen  : integer := 10;
             Start_Of_Pulse : integer := 20;
             End_Of_Pulse   : integer := 30;
             End_Of_Line    : integer := 40);

    port (clk  : in  std_logic;
          rst  : in  std_logic;
          data : in  std_logic_vector (Nbit-1 downto 0);
          O1   : out std_logic;
          O2   : out std_logic;
          O3   : out std_logic);
  end component;

  component dibuja is
    port (
      button_left   : in  std_logic;
      button_center : in  std_logic;
      button_right  : in  std_logic;
      R             : out std_logic;
      G             : out std_logic;
      B             : out std_logic;
      eje_x         : in  std_logic_vector (9 downto 0);
      eje_y         : in  std_logic_vector (9 downto 0));
  end component;

begin

  x <= unsigned(eje_x);
  y <= unsigned(eje_y);

  contador_x : contador
    generic map (Nbit => 10)
    port map (clk    => clk,
              rst    => rst,
              rsts   => O3_compX,
              enable => '1',
              Q      => eje_x
              );

  enable_contY <= O3_compX;

  contador_y : contador
    generic map (Nbit => 10)
    port map (clk    => clk,
              rst    => rst,
              rsts   => O3_compY,
              enable => enable_contY,
              Q      => eje_y
              );

  comparador_x : comparador
    generic map (Nbit           => 10,
                 End_Of_Screen  => 639,
                 Start_Of_Pulse => 655,
                 End_Of_Pulse   => 751,
                 End_Of_Line    => 799
                 )
    port map (clk  => clk,
              rst  => rst,
              data => eje_x,
              O1   => Blank_x,
              O2   => HS,
              O3   => O3_compX
              );

  comparador_y : comparador
    generic map (Nbit           => 10,
                 End_Of_Screen  => 479,
                 Start_Of_Pulse => 489,
                 End_Of_Pulse   => 491,
                 End_Of_Line    => 520
                 )
    port map (clk  => clk,
              rst  => rst,
              data => eje_y,
              O1   => Blank_y,
              O2   => VS,
              O3   => O3_compY
              );

  dibuja_instancia : dibuja
    port map (eje_x         => eje_x,
              eje_y         => eje_y,
              button_left   => button_left,
              button_center => button_center,
              button_right  => button_right,
              R             => R_in,
              G             => G_in,
              B             => B_in
              );

  gen_color : process (Blank_x, Blank_y, R_in, G_in, B_in)
  begin
    if (Blank_x = '1' or Blank_y = '1') then
      p_R <= '0'; p_G <= '0'; p_B <= '0';
    else
      p_R <= R_in; p_G <= G_in; p_B <= B_in;
    end if;
  end process;

  -- Optionally: pass RGB through a flip-flop to avoid color flickering
--  sync : process(clk)
--  begin
--    if rising_edge(clk) then
      R <= p_R;
      G <= p_G;
      B <= p_B;
--    end if;
--  end process;

end Behavioral;
