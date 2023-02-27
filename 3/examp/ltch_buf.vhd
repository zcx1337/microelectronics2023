USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity latch_buffer_32 is
	generic (Tpd: Time:= unit_delay);
	port (d :in bit_32;
		  q :out bus_bit_32 bus;
	latch_en: in std_logic;
	out_en	: in std_logic);
end latch_buffer_32;
architecture behaviour of latch_buffer_32 is
begin
	process(d,latch_en,out_en)
		variable latched_value :bit_32:=(others=>'Z');
	begin
		if latch_en='1' then
			latched_value:= d;
		end if;
		if out_en='1' then
			q<= latched_value after Tpd;
		else
			q <= null after Tpd;
		end if;
	end process;
end behaviour;
