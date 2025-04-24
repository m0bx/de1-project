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

    -- Constants
    constant DIGIT_REFRESH_COUNT : integer := 100_000; -- Refresh counter for digit switching

    -- Time signals
    signal clock_sec, clock_min     : integer range 0 to 59 := 0;
    signal alarm_sec, alarm_min     : integer range 0 to 59 := 0;
    signal stopwatch_ms             : integer range 0 to 9999 := 0;
    signal stopwatch_s             : integer range 0 to 9999 := 0;
    

    -- Control signals
    signal run_clock     : std_logic := '1';
    signal run_alarm     : std_logic := '1';
    signal run_stopwatch : std_logic := '1';

    -- Display signals
    signal digit_select   : integer range 0 to 7 := 0;
    signal current_digit : std_logic_vector(3 downto 0);
    signal seg_data      : std_logic_vector(6 downto 0);
    signal dp_enable     : std_logic;

    -- Clock enables
    signal en_1hz    : std_logic;
    signal en_10khz  : std_logic;

begin
    clk_en_1hz: clock_enable -- used for clock and alarm
        generic map (N_PERIODS => 100_000_000)
        port map (clk => clk, rst => rst, pulse => en_1hz);

    clk_en_10khz: clock_enable -- used for stopwatch
        generic map (N_PERIODS => 10_000)
        port map (clk => clk, rst => rst, pulse => en_10khz);

    process(clk)
        variable btnc_prev : std_logic := '0';
        variable btnl_prev : std_logic := '0';
        variable btnr_prev : std_logic := '0';
	    variable btnd_prev : std_logic := '0';
    begin
        if rising_edge(clk) then
            -- handle reset for testbench simulation
            if rst = '1' then
                clock_sec <= 0;
                clock_min <= 0;
                alarm_sec <= 0;
                alarm_min <= 0;
                stopwatch_ms <= 0;
                stopwatch_s <= 0;
                run_clock <= '1';
                run_alarm <= '1';
                run_stopwatch <= '1';
            else
                -- Mode control
                case sw(1 downto 0) is
                    when "00" => -- Clock mode
                        if en_1hz = '1' and run_clock = '1' then
                            if clock_sec = 59 then
                                clock_sec <= 0;
                                clock_min <= (clock_min + 1) mod 60;
                            else
                                clock_sec <= clock_sec + 1;
                            end if;
                        end if;
                        if btnc = '1' and btnc_prev = '0' then
                            run_clock <= not run_clock;
                        end if;

                    when "01" => -- Alarm mode
                        if en_1hz = '1' and run_alarm = '1' then
                            if alarm_sec = 0 then
                                if alarm_min > 0 then
                                    alarm_min <= alarm_min - 1;
                                    alarm_sec <= 59;
                                end if;
                            else
                                alarm_sec <= alarm_sec - 1;
                            end if;
                        end if;
                        if btnc = '1' and btnc_prev = '0' then
                            run_alarm <= not run_alarm;
                        end if;

                    when "10" => -- Stopwatch mode
                        if en_10khz = '1' and run_stopwatch = '1' then
                            if stopwatch_ms = 9999 then
                                stopwatch_ms <= 0;
                            else
                                stopwatch_ms <= stopwatch_ms + 1;
                            end if;
                        end if;
                        if en_1hz = '1' and run_stopwatch = '1' then
                            if stopwatch_s = 9999 then
                                stopwatch_s <= 0;
                            else
                                stopwatch_s <= stopwatch_s + 1;
                            end if;
                        end if; 
                        if btnd = '1' and btnd_prev = '0' then
                            stopwatch_ms <= 0;
                            run_stopwatch <= '0';
                        end if;
						if btnc = '1' and btnc_prev = '0' then
							run_stopwatch <= not run_stopwatch;
						end if;
                    when others => null;
                end case;

                -- Time adjustment
				if sw(2) = '1' then
					if (sw(14) = '1') xor (sw(15) = '1') then
						case sw(1 downto 0) is
							when "00" =>
								if btnl = '1' and btnl_prev = '0' then
									if sw(14) = '1' then
										clock_sec <= (clock_sec - 1) mod 60;
									else  -- sw(15)='1'
										clock_min <= (clock_min - 1) mod 60;
									end if;
								end if;
								if btnr = '1' and btnr_prev = '0' then
									if sw(14) = '1' then
										clock_sec <= (clock_sec + 1) mod 60;
									else
										clock_min <= (clock_min + 1) mod 60;
									end if;
								end if;

							when "01" =>  -- Adjust alarm
								if btnl = '1' and btnl_prev = '0' then
									if sw(14) = '1' then
										alarm_sec <= (alarm_sec - 1) mod 60;
									else
										alarm_min <= (alarm_min - 1) mod 60;
									end if;
								end if;
								if btnr = '1' and btnr_prev = '0' then
									if sw(14) = '1' then
										alarm_sec <= (alarm_sec + 1) mod 60;
									else
										alarm_min <= (alarm_min + 1) mod 60;
									end if;
								end if;

							when others =>
								null;
						end case;
					end if;
				end if;


                btnc_prev := btnc;
                btnl_prev := btnl;
                btnr_prev := btnr;
            end if;
        end if;
    end process;

    -- Multiplexing process
    process(clk)
        variable counter : integer range 0 to DIGIT_REFRESH_COUNT := 0;
    begin
        if rising_edge(clk) then

            if rst = '1' then
                counter := 0;
                digit_select <= 0;
            else
                -- Digit switching
                if counter = DIGIT_REFRESH_COUNT then
                    counter := 0;
                    digit_select <= (digit_select + 1) mod 8;
                else
                    counter := counter + 1;
                end if;

                -- Clear anodes
                anodes <= (others => '1');
                anodes(digit_select) <= '0';

                -- Default no decimal point
                dp_enable <= '0';

                -- Select digit
                case sw(1 downto 0) is
                    when "00" => -- Clock
                        case digit_select is
                            when 0 => current_digit <= std_logic_vector(to_unsigned(clock_min/10, 4));
                            when 1 => current_digit <= std_logic_vector(to_unsigned(clock_min mod 10, 4));
                                dp_enable <= '1';
                            when 2 => current_digit <= std_logic_vector(to_unsigned(clock_sec/10, 4));
                            when 3 => current_digit <= std_logic_vector(to_unsigned(clock_sec mod 10, 4));
                            when others => current_digit <= (others => '1');
                        end case;

                    when "01" => -- Alarm
                        case digit_select is
                            when 0 => current_digit <= std_logic_vector(to_unsigned(alarm_min/10, 4));
                            when 1 => current_digit <= std_logic_vector(to_unsigned(alarm_min mod 10, 4));
                                dp_enable <= '1';
                            when 2 => 
                                current_digit <= std_logic_vector(to_unsigned(alarm_sec/10, 4));
                            when 3 => current_digit <= std_logic_vector(to_unsigned(alarm_sec mod 10, 4));
                            when others => current_digit <= (others => '1');
                        end case;

                    when "10" => -- Stopwatch
                        case digit_select is
                        -- seconds
                            when 0 => current_digit <= std_logic_vector(
                            when 1 => current_digit <= std_logic_vector(
                            when 2 => current_digit <= std_logic_vector(
                            when 3 => current_digit <= std_logic_vector(
                                dp_enable <= '1';
                        -- milliseconds
                            when 4 => current_digit <= std_logic_vector(to_unsigned(stopwatch_ms/1000, 4));
                            when 5 => current_digit <= std_logic_vector(to_unsigned((stopwatch_ms/100) mod 10, 4));
                            when 6 => current_digit <= std_logic_vector(to_unsigned((stopwatch_ms/10) mod 10, 4));
                            when 7 => current_digit <= std_logic_vector(to_unsigned(stopwatch_ms mod 10, 4));
                            when others => current_digit <= (others => '1');
                            
                        end case;

                    when others => current_digit <= (others => '1');
                end case;

                -- Output decimal point
                dp <= not dp_enable;
            end if;
        end if;
    end process;

    -- Segment decoder
    u_bin2seg: bin2seg
        port map (
            clear => '0',
            bin   => current_digit,
            seg   => seg_data
        );

    segments <= seg_data;

    -- Buzzer active if alarm reaches zero in alarm mode
    buzzer <= '1' when (alarm_min = 0 and alarm_sec = 0 and sw(1 downto 0) = "01") else '0';

end architecture behavioral;
