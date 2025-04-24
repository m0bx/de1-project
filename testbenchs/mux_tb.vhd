library ieee;
use ieee.std_logic_1164.all;

entity tb_display_mux is
end entity;

architecture tb of tb_display_mux is

    component display_mux is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            sw       : in  std_logic_vector(15 downto 0);
            btnc     : in  std_logic;
            btnd     : in  std_logic;
            btnl     : in  std_logic;
            btnr     : in  std_logic;
            segments : out std_logic_vector(6 downto 0);
            dp       : out std_logic;
            anodes   : out std_logic_vector(7 downto 0);
            buzzer   : out std_logic
        );
    end component;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal sw       : std_logic_vector(15 downto 0) := (others => '0');
    signal btnc     : std_logic := '0';
    signal btnd     : std_logic := '0';
    signal btnl     : std_logic := '0';
    signal btnr     : std_logic := '0';
    signal segments : std_logic_vector(6 downto 0);
    signal dp       : std_logic;
    signal anodes   : std_logic_vector(7 downto 0);
    signal buzzer   : std_logic;

    constant TbPeriod : time := 10 ns;  -- 100 MHz clock

begin

    -- DUT instantiation
    dut: display_mux
        port map (
            clk      => clk,
            rst      => rst,
            sw       => sw,
            btnc     => btnc,
            btnd     => btnd,
            btnl     => btnl,
            btnr     => btnr,
            segments => segments,
            dp       => dp,
            anodes   => anodes,
            buzzer   => buzzer
        );

    -- Clock generator: 100 MHz
    clk_gen: process
    begin
        clk <= '0';
        wait for TbPeriod/2;
        clk <= '1';
        wait for TbPeriod/2;
    end process;

    -- Test stimulus
    stim: process
    begin
        -- 1) Hold reset for 100 ns
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- 2) Select stopwatch mode ("10")
        sw <= (others => '0');
        sw(1) <= '1';   -- sw(1 downto 0) = "10"

        -- 3) Let it run for 1 second
        wait for 1 sec;

        -- 4) Pause stopwatch (btnc toggle)
        btnc <= '1';
        wait for TbPeriod;
        btnc <= '0';

        -- 5) Wait 100 ms
        wait for 100 ms;

        -- 6) Reset stopwatch (btnd toggle)
        btnd <= '1';
        wait for TbPeriod;
        btnd <= '0';

        -- 7) Let outputs settle
        wait for 100 ms;

        -- 8) End simulation
        assert false report "=== End of Simulation ===" severity failure;
    end process;

end architecture;
