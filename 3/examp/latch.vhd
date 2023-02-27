USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity latch is
	generic (width: positive;
			Tpd: Time:= unit_delay);
	port (d :in std_logic_vector(width-1 downto 0);
		  q :out std_logic_vector(width-1 downto 0);
		 en	:in std_logic);
end latch;
architecture behaviour of latch is
begin
	process(d,en)
	begin
		if en='1' then
			q <= d after Tpd;
		end if;
	end process;
end behaviour;
