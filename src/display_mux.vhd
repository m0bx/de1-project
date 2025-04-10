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
