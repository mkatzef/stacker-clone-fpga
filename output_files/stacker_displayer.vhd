library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.stacker_types_pkg.all;

entity stacker_displayer is
	generic(
		hres : integer := 1280;
		vres : integer := 1024;
		frame_width : integer := 403;
		frame_height : integer := 7;
		block_width : integer := 62;
		block_height : integer := 62;
		border_width : integer := 5;
		border_height : integer := 5;
		h_block_count : integer := 7;
		v_block_count : integer := 15
	);
	port(
		en, clk: in std_logic;
		board : in stacker_board_t;
		xpos: in integer range 0 to hres - 1;
		ypos: in integer range 0 to vres - 1;
		r, g, b: out std_logic
	);
end stacker_displayer;


architecture behavior of stacker_displayer is
	constant unit_width : integer := block_width + border_width;
	constant unit_height : integer := block_height + border_height;
	constant h_frame_start : integer := hres - frame_width;
	constant v_frame_start : integer := vres - frame_height;

	signal block_row : integer range 0 to v_block_count - 1;
	signal block_col : integer range 0 to h_block_count - 1;
	signal block_contents : std_logic := '0';

begin
	process(clk) is
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if xpos < frame_width or xpos >= h_frame_start or ypos < frame_height or ypos >= v_frame_start then
					r <= '1';
					g <= '1';
					b <= '1';
				elsif ((xpos - frame_width) mod unit_width) < border_width or ((ypos - frame_height) mod unit_height) < border_height then
					r <= '0';
					g <= '1';
					b <= '0';
				else
					block_contents <= board(v_block_count - (ypos - frame_height) / unit_height)(h_block_count - (xpos - frame_width) / unit_width - 1);
					if block_contents = '1' then
						r <= '0';
						g <= '0';
						b <= '1';
					else
						r <= '0';
						g <= '0';
						b <= '0';
					end if;
				end if;				
			else
				r <= '0';
				g <= '0';
				b <= '0';
			end if;
		end if;
	end process;
	
end behavior;
