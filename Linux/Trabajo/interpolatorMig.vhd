library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- my cut on the interpolator block

entity interpolatorMig is
        port (
            clk : in std_logic;
            rst : in std_logic;
            valid : in std_logic;
            inf_re,inf_im, sup_re,sup_im : in signed(9 downto 0);

            -- output is the estimated channel
            estim_re,estim_im : out signed(9 downto 0);
            estim_valid : out std_logic
        );
end interpolatorMig;

architecture interpolatorMig_arch of interpolatorMig is

    signal i, p_i    : signed(4 downto 0);
    signal estim_aux_re,estim_aux_im : signed(14 downto 0);

    -- Two signals needed for the firewall assertions
    signal firewall_inf_re,firewall_inf_im, firewall_sup_re,firewall_sup_im : signed(9 downto 0);
    signal p_valid_out, valid_out  : std_logic;

begin

    -- comments from original file are kept
    -- comments starting with lower case are mine, upper case one are the originals
    estim_valid <= valid_out;

    estim_aux_re <= inf_re*(12-i) + sup_re*i;
    estim_aux_im <= inf_im*(12-i) + sup_im*i;

    -- Discard the most significant bit since it doesn't contain any
    -- information (it is redundant with bit 13), and keep the 10 most
    -- significant of the rest
    estim_re <= estim_aux_re(13 downto 4);
    estim_im <= estim_aux_im(13 downto 4);

    -- i controls the interpolation:
    -- when i = 12 we are idle
    -- if we receive a valid input, we go to i = 0
    -- when i is between 0 and 11, interpolate
    -- afterwards go again to i = 12
    comb: process(inf_re,inf_im, sup_re,sup_im, valid, i)
    begin
        -- if (i < 0) or (i > 11) then  -- Anything that is not between 0 and 11: idle
        --     estim_valid <= '0';
        --     if valid = '1' then
        --         p_i <= to_signed(0, p_i'length);
        --     else
        --         p_i <= to_signed(12,p_i'length);
        --     end if;
        -- else                         -- Between 0 and 11: interpolate
           
        if valid = '1' then
            if i >= 11 then
                p_i <= to_signed(0,p_i'length);
                p_valid_out <= '1';
            else
                p_i <= i + 1;
                p_valid_out <= '1';
            end if;
        else
            p_i <= i;
            p_valid_out <= '0';
        end if;
    end process;


    sinc: process(rst, clk)
    begin
        if rst = '1' then
            i <= to_signed(0,i'length);  -- set i to 12
            valid_out <= '0';
        elsif rising_edge(clk) then
            valid_out <= p_valid_out;
            i <= p_i;
        end if;
    end process;

    -- Firewall assertions: assure that our module is being used correctly
    -- What can go wrong?
    -- 1.- Valid cannot be asserted while the interpolator is busy
    -- 2.- Input data cannot change while the interpolator is busy
    -- (the interpolator is busy if 0 <= i <= 11)
    --
    -- An interesting idea here would be to define a procedure in
    -- edc_common/edc_common called "fail_in_N_cycles", which would
    -- wait N clock cycles before stopping the simulation
    
    -- firewall_assertions: process (clk)
    -- begin
    --     if falling_edge(clk) then
    --         firewall_sup_re <= sup_re;
    --         firewall_sup_im <= sup_im;
    --         firewall_inf_re <= inf_re;
    --         firewall_inf_im <= inf_im;
    --         if (i >= 0) and (i <= 11) then
    --             if valid = '1' then
    --                 report "valid asserted while interpolator busy, data will be lost"
    --                 severity note;
    --             end if;
    --             if (inf_re /= firewall_inf_re) or (inf_im /= firewall_inf_im) or (sup_re /= firewall_sup_re) or (sup_im /= firewall_sup_im) then
    --                 report "data changed while interpolator busy, interpolation will be wrong"
    --                 severity note;
    --             end if;
    --             -- if valid = '1' then
    --             --     report "valid equals 1" severity warning;
    --             -- end if;
    --         end if;
    --     end if;
    -- end process;

end interpolatorMig_arch;
