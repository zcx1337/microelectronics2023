USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity cond_code_comparator is
	generic (Tpd	: Time:= unit_delay);
	port (cc	:in CC_bits;
		  cm	:in cm_bits;
		  result:out std_logic);
end  cond_code_comparator;
ARCHITECTURE behaviour OF cond_code_comparator IS
	alias cc_V: std_logic is cc(2);
	alias cc_N: std_logic is cc(1);
	alias cc_Z: std_logic is cc(0);
	alias cm_i: std_logic is cm(3);
	alias cm_V: std_logic is cm(2);
	alias cm_N: std_logic is cm(1);
	alias cm_Z: std_logic is cm(0);
begin
	result <= bool_to_bit(((cm_V and cc_V)
						or (cm_N and cc_N)
						or (cm_Z and cc_Z))=cm_i) after Tpd;
end behaviour;						

