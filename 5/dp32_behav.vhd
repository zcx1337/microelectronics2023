USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity dp32 is
	generic ( Tpd	: Time:= unit_delay);
	port (d_bus	:inout bus_bit_32 bus;
		  a_bus	:out bit_32;
		  read	:out std_logic;
		  write	:out std_logic;
		  fetch	:out std_logic;
		  ready	:in std_logic;
		  phi1	:in std_logic;
		  phi2	:in std_logic;
		  reset	:in std_logic);
end dp32;
architecture behaviour of dp32 is
	SUBTYPE reg_addr is natural range 0 to 255;
	TYPE reg_array is array (reg_addr) of bit_32;
begin
	process
		VARIABLE reg :reg_array:=(others=>X"00000000");
		VARIABLE PC  :bit_32;
		VARIABLE current_instr :bit_32:=X"00000000";
		VARIABLE op: bit_8;
		VARIABLE r3,r1,r2:reg_addr;
		VARIABLE i8:integer;
		ALIAS cm_i: std_logic is current_instr(19);
		ALIAS cm_V: std_logic is current_instr(18);
		ALIAS cm_N: std_logic is current_instr(17);
		ALIAS cm_Z: std_logic is current_instr(16);
		VARIABLE cc_V,cc_N,cc_Z : std_logic:='0';
		VARIABLE temp_V,temp_N,temp_Z : std_logic:='0';
		VARIABLE displacement : bit_32:=X"00000000";		
		VARIABLE effective_addr : bit_32:=X"00000000";		
		procedure memory_read (	addr		: in bit_32;
								fetch_cycle	: in boolean;
								result		:out bit_32) IS
		begin
			--start bus cycle with address output
			a_bus <= addr after Tpd;
			fetch <= bool_to_bit(fetch_cycle)after Tpd;
			wait until phi1 ='1';
			if reset ='1' then
				return;
			end if;
			--
			-- T1 phase
			--
			read <= '1'after Tpd;
			wait until phi1 ='1';
			if reset ='1' then
				return;
			end if;
			--
			-- T2 phase
			--
			loop 
				wait until phi2 ='0';
				if reset ='1' then
					return;
				end if;
				-- END of T2
				if ready ='1' then
					result:=d_bus;
					exit;
				end if;
			end loop;
			wait until phi1 ='1';			
			if reset ='1' then
				return;
			end if;
			--
			-- Ti phase at end of cycle
			--
			read <='0' after Tpd;
		end memory_read;
		procedure memory_write (addr		: in bit_32;
								data		: in bit_32) IS
		begin
			--start bus cycle with address output
			a_bus <=addr after Tpd;
			fetch <= '0'after Tpd;
			wait until phi1 = '1';
			if reset ='1' then
				return;
			end if;
			--
			-- T1 phase
			--
			write <='1'after Tpd;
			wait until phi2 ='1';
			d_bus <=data after Tpd;
			wait until phi1 ='1';			
			if reset ='1' then
				return;
			end if;
			--
			-- T2 phase
			--
			loop 
				wait until phi2 ='0';
				if reset ='1' then
					return;
				end if;
				-- END of T2
				exit when ready ='1';
			end loop;
			wait until phi1 ='1';
			if reset ='1' then
				return;
			end if;
			--
			-- Ti phase at end of cycle
			--
			write <='0' after Tpd;
			d_bus <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"  after Tpd;

		end memory_write;
		
		procedure add (	result		: inout bit_32;
						op1,op2		: in integer;
						V,N,Z		: out std_logic) IS
		begin
		
			if op2>0 and op1> integer'HIGH -op2 then --positive overflow
				int_to_bits(((integer'LOW+op1)+op2)-integer'HIGH-1,result);
				V:='1';
			elsif op2<0 and op1< integer'LOW -op2 then --negative overflow
				int_to_bits(((integer'HIGH+op1)+op2)-integer'LOW+1,result);
				V:='1';
			else
			 	int_to_bits(op1+op2,result);
			 	V:='0';
			end if;
			N:=result(31);
			Z:=bool_to_bit(result=X"0000_0000");
		end add;
		procedure subtract (	result		: inout bit_32;
								op1,op2		: in integer;
								V,N,Z		: out std_logic) IS
		begin
			if op2<0 and op1> integer'HIGH +op2 then --positive overflow
				int_to_bits(((integer'LOW+op1)-op2)-integer'HIGH-1,result);
				V:='1';
			elsif op2>0 and op1< integer'LOW +op2 then --negative overflow
				int_to_bits(((integer'HIGH+op1)-op2)-integer'LOW+1,result);
				V:='1';
			else
			 	int_to_bits(op1-op2,result);
			 	V:='0';
			end if;
			N:=result(31);
			Z:=bool_to_bit(result=X"0000_0000");

		end subtract;
		procedure divide (	result		: inout bit_32;
								op1,op2		: in integer;
								V,N,Z		: out std_logic) IS
		begin
			if op2=0 then
				if op1>0 then	--positive overflow
					 int_to_bits(integer'HIGH,result);
				else int_to_bits(integer'LOW,result);
				end if;
				V:='1';
			else
			 	int_to_bits(op1/op2,result);
			 	V:='0';
			end if;
			N:=result(31);
			Z:=bool_to_bit(result=X"0000_0000");
		end divide;
		procedure multiply (	result		: inout bit_32;
								op1,op2		: in integer;
								V,N,Z		: out std_logic) IS
		begin

			if ((op1>0 and op2>0)or(op1<0 and op2<0) 		--result positive
					and (abs op1>integer'HIGH/abs op2)) then	--positive overflow
				int_to_bits(integer'HIGH,result);
				V:='1';
			elsif ((op1>0 and op2<0)or(op1<0 and op2>0)) 		--result negative
					and ((-abs op1)<integer'LOW/abs op2) then 	--negative overflow
				int_to_bits(integer'LOW,result);
				V:='1';
			else
			 	int_to_bits(op1*op2,result);
			 	V:='0';
			end if;
			N:=result(31);
			Z:=bool_to_bit(result=X"0000_0000");

		end multiply;
	begin
	--
	-- check for reset active
	--
	if reset ='1' then
		read 	<='0' after Tpd;
		write 	<='0' after Tpd;
		fetch 	<='0' after Tpd;
		d_bus 	<= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" after Tpd;
		PC:= X"0000_0000";
		wait until reset = '0';
	end if;
	--
	-- fetch next instruction
	--
	memory_read(PC,true,current_instr);
	if reset /='1' then
		add (PC,bits_to_int(PC),1,temp_V,temp_N,temp_Z);
		--
		-- decode & execute
		--
		op:=current_instr (31 downto 24);
		r3:=bits_to_natural(current_instr (23 downto 16));
		r1:=bits_to_natural(current_instr (15 downto 8));
		r2:=bits_to_natural(current_instr (7 downto 0));
		i8:=bits8_to_int(current_instr (7 downto 0));
		case op is
			when op_add =>
				add(reg(r3),bits_to_int(reg(r1)),bits_to_int(reg(r2)),
						cc_V,cc_N,cc_Z);
			when op_addq =>
				add(reg(r3),bits_to_int(reg(r1)),i8,cc_V,cc_N,cc_Z);
			when op_sub =>
				subtract(reg(r3),bits_to_int(reg(r1)),bits_to_int(reg(r2)),
						cc_V,cc_N,cc_Z);
			when op_subq =>
				subtract(reg(r3),bits_to_int(reg(r1)),i8,cc_V,cc_N,cc_Z);
			when op_mul =>
				multiply(reg(r3),bits_to_int(reg(r1)),bits_to_int(reg(r2)),
						cc_V,cc_N,cc_Z);
			when op_mulq =>
				multiply(reg(r3),bits_to_int(reg(r1)),i8,cc_V,cc_N,cc_Z);

			when op_div =>
				divide(reg(r3),bits_to_int(reg(r1)),bits_to_int(reg(r2)),
						cc_V,cc_N,cc_Z);
			when op_divq =>
				divide(reg(r3),bits_to_int(reg(r1)),i8,cc_V,cc_N,cc_Z);
			when op_land =>
				reg(r3)	:= reg(r1)and reg(r2);
				cc_Z :=bool_to_bit(reg(r3)=X"0000_0000");
			when op_lor =>
				reg(r3)	:= reg(r1)or reg(r2);
				cc_Z :=bool_to_bit(reg(r3)=X"0000_0000");
			when op_lxor =>
				reg(r3)	:= reg(r1)xor reg(r2);
				cc_Z :=bool_to_bit(reg(r3)=X"0000_0000");
			when op_lmask =>
				reg(r3)	:= reg(r1)and not reg(r2);
				cc_Z :=bool_to_bit(reg(r3)=X"0000_0000");
			when op_ld =>
				memory_read(PC,true,displacement);
				if reset /='1' then
					add(PC,bits_to_int(PC),1,temp_V,temp_N,temp_Z);
					add(effective_addr,
							bits_to_int(reg(r1)),bits_to_int(displacement),
							temp_V,temp_N,temp_Z);
					memory_read(effective_addr,false,reg(r3));
				end if;
			when op_ldq =>
				add(effective_addr,
					bits_to_int(reg(r1)),i8,
					temp_V,temp_N,temp_Z);
					memory_read(effective_addr,false,reg(r3));
			when op_st =>
				memory_read(PC,true,displacement);
				if reset /='1' then
					add(PC,bits_to_int(PC),1,temp_V,temp_N,temp_Z);
					add(effective_addr,
							bits_to_int(reg(r1)),bits_to_int(displacement),
							temp_V,temp_N,temp_Z);
					memory_write(effective_addr,reg(r3));
				end if;
			when op_stq =>
					add(effective_addr,
							bits_to_int(reg(r1)),i8,
							temp_V,temp_N,temp_Z);
					memory_write(effective_addr,reg(r3));
			when op_br =>
				memory_read(PC,true,displacement);
				if reset /='1' then
					add(PC,bits_to_int(PC),1,temp_V,temp_N,temp_Z);
					add(effective_addr,
						bits_to_int(PC),bits_to_int(displacement),
						temp_V,temp_N,temp_Z);
					if ((cm_V and cc_V)or(cm_N and cc_N)or(cm_Z and cc_Z))
							=cm_i then
						PC:= effective_addr;
					end if;
				end if;
			when op_bi =>
				memory_read(PC,true,displacement);
				if reset /='1' then
					add(PC,bits_to_int(PC),1,temp_V,temp_N,temp_Z);
					add(effective_addr,
						bits_to_int(reg(r1)),bits_to_int(displacement),
						temp_V,temp_N,temp_Z);
					if ((cm_V and cc_V)or(cm_N and cc_N)or(cm_Z and cc_Z))
							=cm_i then
						PC:= effective_addr;
					end if;
				end if;
			when op_brq =>
					add(effective_addr,
						bits_to_int(PC),i8,
						temp_V,temp_N,temp_Z);
					if ((cm_V and cc_V)or(cm_N and cc_N)or(cm_Z and cc_Z))
							=cm_i then
						PC:= effective_addr;
					end if;
			when op_biq =>
					add(effective_addr,
						bits_to_int(reg(r1)),i8,
						temp_V,temp_N,temp_Z);
					if ((cm_V and cc_V)or(cm_N and cc_N)or(cm_Z and cc_Z))
							=cm_i then
						PC:= effective_addr;
					end if;
							
			when others =>
				assert false report " Hi, illegal instruction" severity warning;
			end case;			
	end if; -- reset /='1'
	end process;	
end behaviour;
