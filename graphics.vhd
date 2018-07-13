library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package graphics is
	procedure square(
		signal x_curr, y_curr, x_start, y_start	: in integer;
		signal pixel_color								: out std_logic_vector(2 downto 0);
		signal state										: out std_logic
	);
end graphics;

package body graphics is
	procedure square(
		signal x_curr, y_curr, x_start, y_start	: in integer;
		signal pixel_color								: out std_logic_vector(2 downto 0);
		signal state										: out std_logic
	) is
	begin
		if (x_curr >= x_start and x_curr < (x_start + 100)) and (y_curr >= y_start and y_curr < (y_start + 100)) then
			pixel_color <= (others => '1');
			state <= '1';
		else
			pixel_color <= (others => '0');
			state <= '0';
		end if;
	end square;
end graphics;