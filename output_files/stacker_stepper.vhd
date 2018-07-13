library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stacker_types_pkg.all;

entity stacker_stepper is
	port(
		clk, en, game_clk, button, rst : in std_logic;
		state : out std_logic;
		current_height : out integer range 1 to 16;
		board : out stacker_board_t
	);
end stacker_stepper;


architecture behavior of stacker_stepper is
	signal button_pressed : std_logic := '0';
	signal button_ready : std_logic := '0';
	
	signal state_tmp : std_logic := '0'; -- 0 for active, 1 for ended
	signal current_height_tmp : integer range 0 to 16 := 1;
	
	subtype step_range is integer range 0 to 65;
	constant init_fps : step_range := 33;
	constant fps_decrement : step_range := 2;
	signal frames_per_step : step_range := init_fps;
	signal current_frame : step_range := 0;
	signal dir : std_logic := '0'; -- 0: moving right. 1: moving left
	
	-- should probably be constant
	constant init_board : stacker_board_t := (
		"1111111",
		"1110000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000",
		"0000000"
	);
	signal board_tmp : stacker_board_t := init_board;
	
begin
	process(clk, en, game_clk, rst, button, state_tmp, current_height_tmp, frames_per_step, current_frame) is	
		variable matched_blocks : std_logic_vector(6 downto 0);
		variable ones_count : integer := 0;
		variable next_row : std_logic_vector(6 downto 0);
	begin
		if rising_edge(game_clk) then
			if rst = '0' then -- reset
				current_height_tmp <= 1;
				frames_per_step <= init_fps;
				board_tmp <= init_board;
				dir <= '0';
				button_pressed <= '0';
				button_ready <= '0';
				state_tmp <= '0';
				
			elsif state_tmp = '0' and en = '1' then -- active game
				if button = '0' then
					button_pressed <= '1' and button_ready;
				else
					button_ready <= '1';
				end if;
			
				-- Increment frame counter
				if current_frame < frames_per_step then
					current_frame <= current_frame + 1;
				else
					current_frame <= 0;
					
					if button_pressed = '1' then -- go up
						button_ready <= '0';
						matched_blocks := board_tmp(current_height_tmp) and board_tmp(current_height_tmp - 1);
						board_tmp(current_height_tmp) <= matched_blocks;
						
						-- count bits, set next row
						if matched_blocks = "0000000" then
							state_tmp <= '1';
						else
							ones_count := 0;
							for i in  matched_blocks'low to matched_blocks'high loop
								if matched_blocks(i) = '1' then
									ones_count := ones_count + 1;
								end if;
							end loop;
							
							if current_height_tmp >= 6 and ones_count > 2 then
								ones_count := 2;
							end if;
							
							if current_height_tmp >= 10 and ones_count > 1 then
								ones_count := 1;
							end if;
							
							for i in  matched_blocks'low to matched_blocks'high loop
								if (dir = '0' and i < ones_count) or (dir = '1' and i > 6 - ones_count) then
									next_row(i) := '1';
								else
									next_row(i) := '0';	
								end if;
							end loop;
							
							board_tmp(current_height_tmp + 1) <= next_row;
						end if;						
						
						dir <= not dir;
						current_height_tmp <= current_height_tmp + 1;
						frames_per_step <= frames_per_step - fps_decrement;
						
					else -- go sideways
						if dir = '0' then
						if board_tmp(current_height_tmp)(1) = '1' then
								dir <= '1';
							end if;
							board_tmp(current_height_tmp) <= '0' & board_tmp(current_height_tmp)(6 downto 1);
						else
							if board_tmp(current_height_tmp)(5) = '1' then
								dir <= '0';
							end if;
							board_tmp(current_height_tmp) <= board_tmp(current_height_tmp)(5 downto 0) & '0';
						end if;
					end if;
					
					button_pressed <= '0';
				end if;
			end if;
			
			-- Check if game reached an end
			if current_height_tmp = 16 then
				state_tmp <= '1';
			end if;
		end if;
	end process;

	state <= state_tmp;
	current_height <= current_height_tmp;
	board <= board_tmp;
	
end behavior;
