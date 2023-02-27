USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity buffer_32 is
	generic (Tpd: Time:= unit_delay);
	port (a :in bit_32;
		  b :out bus_bit_32 bus;
		 en	:in std_logic);
end buffer_32;
architecture behaviour of buffer_32 is
begin
	b_diver:process(en,a)
	begin
		if en='1' then
			b <= a after Tpd;
		else
			b <= null after Tpd;
		end if;
	end process b_diver;
end behaviour;
