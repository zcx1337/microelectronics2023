USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity PC_reg is
	generic (Tpd	: Time:= unit_delay);
	port (d		:in bit_32;
		  q		:out bus_bit_32 bus;
		  latch_en	:in std_logic;
		  out_en	:in std_logic;
		  reset		:in std_logic);
end PC_reg;
architecture behaviour of PC_reg is
begin
	process(d,latch_en, out_en,reset)
		variable master_PC: bit_32:=X"0000_0000";
		variable slave_PC: bit_32:=X"0000_0000";
	begin
		if reset='1' then
			slave_PC:=X"0000_0000";
		elsif latch_en = '1' then
			master_PC:=d;
		else
			slave_PC:=master_PC;
		end if;
		if out_en='1' then
			q <= slave_PC after Tpd;
		else
			q <= null after Tpd;
		end if;
	end process;
end behaviour;
