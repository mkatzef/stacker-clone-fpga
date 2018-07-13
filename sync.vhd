library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
	generic(
		h_vis	: integer := 1280;
		h_fp	: integer := 48;
		h_sp	: integer := 112;
		h_bp	: integer := 248;
		
		v_vis	: integer := 1024;
		v_fp	: integer := 1;
		v_sp	: integer := 3;
		v_bp	: integer := 38
	);
	port(
		clk				: in std_logic;
		hsync, vsync	: out std_logic;
		img_col			: out integer range 0 to h_vis; -- Horitontal position in image, 1280 is off-screen
		img_row			: out integer range 0 to v_vis; -- Vertical
		frame_end		: out std_logic					  -- Rising edge occurs when setting position back to 0, 0
	);
end sync;


architecture behavior of sync is
	constant h_active_start : integer := h_fp + h_sp + h_bp;
	constant v_active_start : integer := v_fp + v_sp + v_bp;
	
	constant h_line : integer := h_active_start + h_vis;
	constant v_line : integer := v_active_start + v_vis;
	
	signal hpos	: integer range 0 to h_line := 0;
	signal vpos	: integer range 0 to v_line := 0;
	signal img_col_tmp : integer range 0 to h_vis;
	signal img_row_tmp : integer range 0 to v_vis;
	signal frame_end_tmp : std_logic := '0';
begin	
	process(clk)
		begin
		if clk'event and clk = '1' then
			-- Increment position
			if hpos < h_line - 1 then
				hpos <= hpos + 1;
			else
				hpos <= 0;
				if vpos < v_line - 1 then
					vpos <= vpos + 1;
					frame_end_tmp <= '0';
				else
					vpos <= 0;
					frame_end_tmp <= '1';
				end if;
			end if;
			
			-- Set output pixel position if on active region, or set to sentinel values
			if hpos >= h_active_start then
				img_col_tmp <= hpos - h_active_start;
			else
				img_col_tmp <= h_vis;
			end if;
			
			if vpos >= v_active_start then
				img_row_tmp <= vpos - v_active_start;
			else
				img_row_tmp <= v_vis;
			end if;
			
			-- If in sync regions, set sync signals low
			if hpos >= h_fp and hpos < (h_fp + h_sp) then
				hsync <= '0';
			else
				hsync <= '1';
			end if;
			
			if vpos >= v_fp and vpos < (v_fp + v_sp) then
				vsync <= '0';
			else
				vsync <= '1';
			end if;
		end if;
	end process;
	
	img_col <= img_col_tmp;
	img_row <= img_row_tmp;
	frame_end <= frame_end_tmp;
end behavior;
