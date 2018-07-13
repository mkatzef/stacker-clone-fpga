library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package stacker_types_pkg is
	type stacker_board_t is array(0 to 15) of std_logic_vector(6 downto 0);
end package;
