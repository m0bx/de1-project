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
    signal sig_anodes   : std_logic_vector(7 downto 0);
    signal btnc_sync    : std_logic := '0';
    signal btnd_sync    : std_logic := '0';
    signal btnl_sync    : std_logic := '0';
    signal btnr_sync    : std_logic := '0';

begin

    -- synchronize buttons to CLK
    sync_buttons: process(CLK)
    begin
        if rising_edge(CLK) then
            btnc_sync <= BTNC;
            btnd_sync <= BTND;
            btnl_sync <= BTNL;
            btnr_sync <= BTNR;
        end if;
    end process;

    -- display mux instance drives sig_segments & sig_anodes
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
            anodes   => sig_anodes,
            buzzer   => LED17_R
        );

    -- direct segment outputs
    CA <= sig_segments(6);
    CB <= sig_segments(5);
    CC <= sig_segments(4);
    CD <= sig_segments(3);
    CE <= sig_segments(2);
    CF <= sig_segments(1);
    CG <= sig_segments(0);

    -- reversed the anode vector
    AN(7) <= sig_anodes(0);
    AN(6) <= sig_anodes(1);
    AN(5) <= sig_anodes(2);
    AN(4) <= sig_anodes(3);
    AN(3) <= sig_anodes(4);
    AN(2) <= sig_anodes(5);
    AN(1) <= sig_anodes(6);
    AN(0) <= sig_anodes(7);

end architecture behavioral;
