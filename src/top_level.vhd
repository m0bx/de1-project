library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port (
        CLK     : in  std_logic;
        SW      : in  std_logic_vector(15 downto 0);
        CA      : out std_logic;
        CB      : out std_logic;
        CC      : out std_logic;
        CD      : out std_logic;
        CE      : out std_logic;
        CF      : out std_logic;
        CG      : out std_logic;
        DP      : out std_logic;
        AN      : out std_logic_vector(7 downto 0);
        BTNC    : in  std_logic;
        BTND    : in  std_logic;
        BTNL    : in  std_logic;
        BTNR    : in  std_logic;
        LED17_R : out std_logic
    );
end entity top_level;

architecture behavioral of top_level is
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

    signal sig_segments : std_logic_vector(6 downto 0);
    signal btnc_sync    : std_logic := '0';
    signal btnd_sync    : std_logic := '0';
    signal btnl_sync    : std_logic := '0';
    signal btnr_sync    : std_logic := '0';

begin

    sync_buttons: process(CLK)
    begin
        if rising_edge(CLK) then
            -- gets button data synchrinically to clock
            btnc_sync <= BTNC;
            btnd_sync <= BTND;
            btnl_sync <= BTNL;
            btnr_sync <= BTNR;
        end if;
    end process;

    -- display component
    u_display_mux: display_mux
        port map (
            clk      => CLK,
            rst      => '0',
            sw       => SW,
            btnc     => btnc_sync,
            btnd     => btnd_sync,
            btnl     => btnl_sync,
            btnr     => btnr_sync,
            segments => sig_segments,
            dp       => DP,
            anodes   => AN,
            buzzer   => LED17_R
        );

    -- segment signal routing from mux
    CA <= sig_segments(6);
    CB <= sig_segments(5);
    CC <= sig_segments(4);
    CD <= sig_segments(3);
    CE <= sig_segments(2);
    CF <= sig_segments(1);
    CG <= sig_segments(0);

end architecture behavioral;
