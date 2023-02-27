USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity reg_file_32_rrw is
	generic (depth	: positive;	
			 Tpd	: Time:= unit_delay;
			 Tac	: Time:= unit_delay);
	port (a1	:in std_logic_vector(depth-1 downto 0);
		  q1	:out bus_bit_32 bus;
		  en1	:in std_logic;
		  a2	:in std_logic_vector(depth-1 downto 0);
		  q2	:out bus_bit_32 bus;
		  en2	:in std_logic;
		  a3	:in std_logic_vector(depth-1 downto 0);
		  d3	:in bit_32;
 		  en3	:in std_logic);
end reg_file_32_rrw;
architecture behaviour of reg_file_32_rrw is
begin
	reg_file:process(a1,en1,a2,en2,a3,d3,en3)
		subtype reg_addr is natural range 0 to 256;--depth-1;
		type register_array is array (reg_addr) of bit_32;

		variable registers: register_array:=(others=>X"00000000");

	begin
		if en3='1' then
			registers(bits_to_natural(a3)):=d3;
		end if;
		if en1='1' then
			q1 <= registers(bits_to_natural(a1))after Tac;
		else
			q1 <= null after Tpd;
		end if;
		if en2='1' then
			q2 <= registers(bits_to_natural(a2))after Tac;
		else
			q2 <= null after Tpd;
		end if;
	end process reg_file;
end behaviour;
