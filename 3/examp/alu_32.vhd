--
--  File: c:\my designs\alu\SRC\alu_32.VHD
--  created by Design Wizard: 06/18/98 11:41:50
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
-----------------------------------------------------------------------
---------PACKAGE DECLARATION dp32_types -------------------------------
-----------------------------------------------------------------------
PACKAGE dp32_types IS
CONSTANT unit_delay : Time := 1 ns;

	--  Subtype Declaration
SUBTYPE bit_32 IS std_logic_vector(31 downto 0);
SUBTYPE CC_bits IS std_logic_vector(2 downto 0);
SUBTYPE cm_bits IS std_logic_vector(3 downto 0);
SUBTYPE bus_bit_32 IS  std_logic_vector(31 downto 0);--bit_32;
SUBTYPE bit_8 IS std_logic_vector(7 downto 0);
	--  Type Declaration
TYPE bool_to_bit_table IS ARRAY (boolean) OF std_logic;
TYPE bit_32_array IS ARRAY (integer RANGE <>) OF bit_32;
	--  Constant Declaration
CONSTANT bool_to_bit :bool_to_bit_table;
CONSTANT op_add 	: bit_8 := X"00";
CONSTANT op_sub 	: bit_8 := X"01";
CONSTANT op_mul 	: bit_8 := X"02";
CONSTANT op_div 	: bit_8 := X"03";
CONSTANT op_addq 	: bit_8 := X"10";
CONSTANT op_subq 	: bit_8 := X"11";
CONSTANT op_mulq 	: bit_8 := X"12";
CONSTANT op_divq 	: bit_8 := X"13";
CONSTANT op_land 	: bit_8 := X"04";
CONSTANT op_lor 	: bit_8 := X"05";
CONSTANT op_lxor 	: bit_8 := X"06";
CONSTANT op_lmask 	: bit_8 := X"07";
CONSTANT op_ld 		: bit_8 := X"20";
CONSTANT op_st 		: bit_8 := X"21";
CONSTANT op_ldq 	: bit_8 := X"30";
CONSTANT op_stq 	: bit_8 := X"31";
CONSTANT op_br 		: bit_8 := X"40";
CONSTANT op_brq 	: bit_8 := X"50";
CONSTANT op_bi 		: bit_8 := X"41";
CONSTANT op_biq 	: bit_8 := X"51";

--constant  low_address :integer :=0;
--constant high_address :integer :=65535;
--type memory_array is 
--	array(integer range low_address to high_address)of bit_32;
--shared 		variable memo :bit_32:=X"00000000";
--shared		variable address : integer;	
	--  Function Declaration
function bits_to_int(bits: in std_logic_vector) return integer;
--function bits8_to_int(bits: in std_logic_vector) return integer;
function bits_to_natural(bits: in std_logic_vector) return natural;
	--  Procedure Declaration
procedure int_to_bits(int: in integer; bits:out std_logic_vector);
END dp32_types;

-----------------------------------------------------------------------
-------      PACKAGE BODY dp32_types ----------------------------------
-----------------------------------------------------------------------
PACKAGE BODY dp32_types IS
CONSTANT bool_to_bit :bool_to_bit_table :=
	(false =>'0',true =>'1');
-----------------------------------------------------------------------
function bits_to_int(bits: in std_logic_vector) return integer IS
	variable temp: std_logic_vector(bits'range);
	variable result: integer:=0;
	variable tmp: 	integer:=0;
  begin
	if bits(bits'left)='1' then
		temp:= not bits;
	else
		temp:=bits;
	end if;
	for index in bits'RANGE loop --(31 downto 0) 
		if temp(index)='0' then
			tmp:=0;
		else 
			tmp:=1;
		end if;

		result:=result*2 +tmp;  
	end loop;
	if bits(bits'left)= '1' then
		result:= (-result)-1;
	end if;
	return result;
  end bits_to_int;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--function bits8_to_int(bits: in std_logic_vector) return integer IS
--	variable temp: std_logic_vector(7 downto 0);
--	variable result: integer:=0;
--	variable tmp: 	integer:=0;
--  begin
--	if bits(bits'left)='1' then
--		temp:= not bits;
--	else
--		temp:=bits;
--	end if;
--	for index in bits'RANGE loop --(7 downto 0) 
--		if temp(index)='0' then
--			tmp:=0;
--		else 
--			tmp:=1;
--		end if;

--		result:=result*2 +tmp;  
--	end loop;
--	if bits(bits'left)= '1' then
--		result:= (-result)-1;
--	end if;
--	return result;
--  end bits8_to_int;
-----------------------------------------------------------------------

function bits_to_natural(bits: in std_logic_vector) return natural is
	variable result: natural:=0;
	variable tmp: 	integer:=0;
  begin
	for index in bits'RANGE loop --(31 downto 0) 
		if bits(index)='0' then
			tmp:=0;
		else 
			tmp:=1;
		end if;

		result:=result*2 +tmp;  
	end loop;
	return result;
  end bits_to_natural;
-----------------------------------------------------------------------
procedure int_to_bits(int: in integer; bits:out std_logic_vector) is
	variable result: std_logic_vector(31 downto 0);
	variable temp: integer;
begin
	if int < 0 then
		temp:=-(int+1);
	else
		temp:=int;
	end if;
	for index in bits'reverse_range loop
		if (temp rem 2)=0 then
			result(index):='0';
		else 
			result(index):='1';
		end if;
		temp:=temp/2;	
	end loop;
	if int<0 then
		result:= not result;
		result(bits'left):='1';
	end if;
	bits:=result;
end int_to_bits;
-----------------------------------------------------------------------
END dp32_types;
-----------------------------------------------------------------------
-------  END  PACKAGE BODY dp32_types ---------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
---------PACKAGE DECLARATION ALU_32_types -----------------------------
-----------------------------------------------------------------------
PACKAGE alu_32_types IS
TYPE ALU_command IS (disable,pass1,
					log_and,log_or,log_xor,log_mask,
					incr1,add,subtract,multiply,divide);
END alu_32_types;	
--PACKAGE BODY alu_32_types IS
--END alu_32_types;
--------------------------------------------------------------------
USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--------------------------------------------------------------------
----------------------ENTITY ALU_32 --------------------------------
--------------------------------------------------------------------
ENTITY ALU_32 IS
	generic (Tpd:Time:=unit_delay);
	PORT( operand1	: IN	bit_32;
		operand2    : IN	bit_32;		
		result  	: OUT	bus_bit_32 bus;
		cond_code  	: OUT	CC_bits;
		command		: IN ALU_command);
END ALU_32;
--------------------------------------------------------------------
------------------------ARCHITECTURE  OF ALU_32 --------------------
--------------------------------------------------------------------

ARCHITECTURE behaviour OF ALU_32 IS
	alias cc_V: std_logic is cond_code(2);
	alias cc_N: std_logic is cond_code(1);
	alias cc_Z: std_logic is cond_code(0);

BEGIN
	ALU_function: process (operand1,operand2,command)
		VARIABLE a,b : integer;
		VARIABLE temp_result : bit_32:=(others=>'0');
	begin
		case command is
			when add|subtract|multiply|divide =>
				a:=bits_to_int(operand1);
				b:=bits_to_int(operand2);
			when incr1 =>
				a:=bits_to_int(operand1);
				b:=1;
			when others =>
				null;
		end case;
		case command is
			when disable =>	
					null;
			when pass1 =>
		temp_result:= operand1;
			when log_and=>
		temp_result:= operand1 and operand2;
			when log_or =>
		temp_result:= operand1 or operand2;
			when log_xor =>
		temp_result:= operand1 xor operand2;
			when log_mask =>
		temp_result:= operand1 and not operand2;
			when add|incr1 =>
				if b>0 and a> integer'high - b then	--positive overflow
					int_to_bits(((integer'low + a)+b)- integer'high -1,temp_result);
					cc_V <= '1' after Tpd;
				elsif b<0 and a<integer'low-b then	--negative overflow
					int_to_bits(((integer'high + a)+b)- integer'low +1,temp_result);
					cc_V <= '1'after Tpd;
				else
					int_to_bits(a+b,temp_result);
					cc_V <= '0'after Tpd;
				end if;	
			when subtract =>
				if b<0 and a> integer'high + b then	--positive overflow
					int_to_bits(((integer'low + a)-b)- integer'high -1,temp_result);
					cc_V <= '1'after Tpd;
				elsif b>0 and a<integer'low+b then	--negative overflow
					int_to_bits(((integer'high + a)-b)- integer'low +1,temp_result);
					cc_V <= '1'after Tpd;
				else
					int_to_bits(a-b,temp_result);
					cc_V <= '0'after Tpd;
				end if;	
			when multiply =>
				if ((a>0 and b>0)or(a<0 and b<0)) --result positive
					and(abs a > integer'high / abs b) then
					--positive overflow
					int_to_bits(integer'high,temp_result);
					cc_V <= '1'after Tpd;
				elsif ((a>0 and b<0)or(a<0 and b>0)) --result negative
					and((- abs a) < integer'low / abs b) then
					--negative overflow
					int_to_bits(integer'low,temp_result);
					cc_V <= '1'after Tpd;
				else
					int_to_bits(a*b,temp_result);
					cc_V <= '0'after Tpd;
				end if;	
			when divide =>
				if b=0 then
					if a>=0 then	--positive overflow
						int_to_bits(integer'high,temp_result);
					else
						int_to_bits(integer'low,temp_result);										
					end if;
					cc_V <= '1'after Tpd;
				else
					int_to_bits(a/b,temp_result);																			
					cc_V <= '0'after Tpd;
				end if;
		end case;
		if command /= disable then
			result <=temp_result after Tpd;
		else 
			result <= null after Tpd;
		end if;
--		if (temp_result = X"00000000")then
		cc_Z <=bool_to_bit(temp_result = X"00000000")after Tpd;
		cc_N <=bool_to_bit(temp_result(31) = '1')after Tpd;

--			cc_Z <='0';
--		else
--			cc_Z <='1';
--		end if;
--		if (temp_result(31) = '1')then
--			cc_N <='0';
--		else
--			cc_N <='1';
--		end if;
	end process ALU_function;

END behaviour;

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------

