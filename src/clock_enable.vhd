library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_enable is
    generic (
            N_PERIODS : integer := 10
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           pulse : out STD_LOGIC);
end clock_enable;

architecture Behavioral of clock_enable is
    signal sig_counter : positive range 1 to n_periods := 1;
begin
    process(clk) begin
        if rising_edge(clk) then
            pulse <= '0';
            if rst = '1' then
                sig_counter <= 1;
            else 
                if sig_counter = n_periods then
                    pulse <= '1';
                    sig_counter <= 1;
                else
                    sig_counter <= sig_counter + 1;
                
                end if;
            end if;

        end if;
    end process p_clk_enable;

end architecture behavioral;
