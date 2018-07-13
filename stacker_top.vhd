library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stacker_types_pkg.all;


entity stacker_top is
	port(
		clk_osc						: in std_logic;
		key1, key2, key3, key4	: in std_logic;
		vga_hsync, vga_vsync		: out std_logic;
		vga_r, vga_g, vga_b		: out std_logic;
		led1 : out std_logic
	);
end stacker_top;


architecture behaviour of stacker_top is
	component pll is
		port (
			clk_in_clk	: in  std_logic := 'X';
			clk_rst_reset	: in  std_logic := 'X';
			clk_out_clk	: out std_logic
		);
	end component pll;
	
	component sync is
		port(
			clk				: in std_logic;
			hsync, vsync	: out std_logic;
			img_col			: out integer range 0 to 1280;
			img_row			: out integer range 0 to 1024;
			frame_end		: out std_logic
		);
	end component sync;
	
	component stacker_stepper is
	port(
		clk, en, game_clk, button, rst : in std_logic;
		state : out std_logic;
		current_height : out integer range 1 to 16;
		board : out stacker_board_t
	);
	end component stacker_stepper;
	
	component stacker_displayer is
	port(
		en, clk: in std_logic;
		board : in stacker_board_t;
		xpos: in integer range 0 to 1279;
		ypos: in integer range 0 to 1023;
		r, g, b: out std_logic
	);
	end component stacker_displayer;
	
	signal vga_clk, clk_rst : std_logic := '0';
	
	signal img_col : integer range 0 to 1280;
	signal img_row : integer range 0 to 1024;
	signal frame_flag : std_logic := '0';
	signal vga_r_tmp, vga_g_tmp, vga_b_tmp : std_logic := '0';
	
	signal stepper_en : std_logic := '1';
	signal stepper_state : std_logic;
	signal board_row : integer range 1 to 16;
	signal board : stacker_board_t;
	
	signal display_en : std_logic := '0';
	
begin
	pixel_clock	: pll port map(clk_osc, clk_rst, vga_clk);
	video_sync	: sync port map(vga_clk, vga_hsync, vga_vsync, img_col, img_row, frame_flag);
	game_model	: stacker_stepper port map(clk_osc, stepper_en, frame_flag, key1, key4, stepper_state, board_row, board);
	display		: stacker_displayer port map(display_en, vga_clk, board, img_col, img_row, vga_r, vga_g, vga_b);
	
	display_en <= '1' when img_col < 1280 and img_row < 1024 else '0';
	led1 <= stepper_state;
	
end behaviour;
