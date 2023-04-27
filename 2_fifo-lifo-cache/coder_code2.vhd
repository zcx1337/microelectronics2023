library ieee;

use ieee.std_logic_1164.all;

entity coder_code2 is
	port(r : in std_logic_vector(7 downto 0);
		ei : in std_logic;
		a : out std_logic_vector (2 downto 0);
		g, e0 : out std_logic);
end coder_code2;

architecture behav of coder_code2 is
	signal tmp : std_logic_vector(2 downto 0);
begin
process(r, ei)
begin
	if (ei = '1') then
		if(r(7) = '1') then
			tmp <= "111";
		elsif(r(6) = '1') then
			tmp <= "110";
		elsif(r(5) = '1') then
			tmp <= "101";
		elsif(r(4) = '1') then
			tmp <= "100";
		elsif(r(3) = '1') then
			tmp <= "011";
		elsif(r(2) = '1') then
			tmp <= "010";
		elsif(r(1) = '1') then
			tmp <= "001";
		elsif (r(0) = '1') then
			tmp <= "000";
		end if;

		if(r = "00000000") then
			e0 <= '1';
			g <= '0';
			tmp <= "000";
		else
			e0 <= '0';
			g <= '1';
		end if;
	else
		tmp <= "000";
		g <= '0';
		e0 <= '0';
	end if;
	end process;
a <= tmp;
end behav;

				
