library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_mux is
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
end entity display_mux;

architecture behavioral of display_mux is
    component clock_enable is
        generic (N_PERIODS : integer);
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            pulse : out std_logic
        );
    end component;

    component bin2seg is
        port (
            clear : in  std_logic;
            bin   : in  std_logic_vector(3 downto 0);
            seg   : out std_logic_vector(6 downto 0)
        );
    end component;
    
    -- time signals
    signal clock_sec, clock_min     : integer range 0 to 59 := 0;
    signal alarm_sec, alarm_min     : integer range 0 to 59 := 0;
    signal stopwatch_ms             : integer range 0 to 9999 := 0;
    
    -- control signals
    signal run_clock     : std_logic := '1';
    signal run_alarm     : std_logic := '1';
    signal run_stopwatch : std_logic := '1';
    
    -- display signals
    signal digit_select   : integer range 0 to 7 := 0;
    signal seg_data      : std_logic_vector(6 downto 0);
    signal dp_enable     : std_logic;
    
    -- clock enables
    signal en_1hz    : std_logic;
    signal en_10khz  : std_logic;

begin
    clk_en_1hz: clock_enable
        generic map (N_PERIODS => 100_000_000)
        port map (clk => clk, rst => rst, pulse => en_1hz);

    clk_en_10khz: clock_enable
        generic map (N_PERIODS => 10_000)
        port map (clk => clk, rst => rst, pulse => en_10khz);

    process(clk)
        variable btnc_prev : std_logic := '0';
        variable btnl_prev : std_logic := '0';
        variable btnr_prev : std_logic := '0';
	
    begin
        if rising_edge(clk) then
            if rst = '1' then
                clock_sec <= 0;
                clock_min <= 0;
                alarm_sec <= 0;
                alarm_min <= 0;
                stopwatch_ms <= 0;
                run_clock <= '1';
                run_alarm <= '1';
                run_stopwatch <= '1';
            else
                -- mody clocku
