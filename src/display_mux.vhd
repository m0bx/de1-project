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
    
    -- Control signals
    signal run_clock     : std_logic := '1';
    signal run_alarm     : std_logic := '1';
    signal run_stopwatch : std_logic := '1';
    
    -- Display signals
    signal digit_select   : integer range 0 to 7 := 0;
    signal seg_data      : std_logic_vector(6 downto 0);
    signal dp_enable     : std_logic;
    
    -- Clock enables
    signal en_1hz    : std_logic;
    signal en_10khz  : std_logic;
