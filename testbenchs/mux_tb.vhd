-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Thu, 24 Apr 2025 09:25:51 GMT
-- Request id : cfwk-fed377c2-680a039f45bf8

library ieee;
use ieee.std_logic_1164.all;

entity tb_display_mux is
end tb_display_mux;

architecture tb of tb_display_mux is

    component display_mux
        port (clk      : in std_logic;
              rst      : in std_logic;
              sw       : in std_logic_vector (15 downto 0);
              btnc     : in std_logic;
              btnd     : in std_logic;
              btnl     : in std_logic;
              btnr     : in std_logic;
              segments : out std_logic_vector (6 downto 0);
              dp       : out std_logic;
              anodes   : out std_logic_vector (7 downto 0);
              buzzer   : out std_logic);
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal sw       : std_logic_vector (15 downto 0);
    signal btnc     : std_logic;
    signal btnd     : std_logic;
    signal btnl     : std_logic;
    signal btnr     : std_logic;
    signal segments : std_logic_vector (6 downto 0);
    signal dp       : std_logic;
    signal anodes   : std_logic_vector (7 downto 0);
    signal buzzer   : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : display_mux
    port map (clk      => clk,
              rst      => rst,
              sw       => sw,
              btnc     => btnc,
              btnd     => btnd,
              btnl     => btnl,
              btnr     => btnr,
              segments => segments,
              dp       => dp,
              anodes   => anodes,
              buzzer   => buzzer);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        
        sw <= (others => '0');
        sw(0) <= '0';
        sw(1) <= '1';
        
        btnc <= '0';
        btnd <= '0';
        btnl <= '0';
        btnr <= '0';

        -- Reset generation
        -- ***EDIT*** Check that rst is really your reset signal

        rst <= '0';
        wait for 1000000000 ns; -- run for 1s
        btnc <= '1';
        wait for 100000000 ns;  -- stop for 100ms
        btnd <= '1';
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_display_mux of tb_display_mux is
    for tb
    end for;
end cfg_tb_display_mux;
