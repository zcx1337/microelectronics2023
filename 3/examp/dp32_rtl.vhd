LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.dp32_types.all, work.ALU_32_types.all;
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
architecture RTL of dp32 is
component reg_file_32_rrw
generic (depth : positive);
port (a1 : in std_logic_vector(depth-1 downto 0);
	q1 : out bus_bit_32 bus;
	en1 : in std_logic;
	a2 : in std_logic_vector(depth-1 downto 0);
	q2 : out bus_bit_32 bus;
	en2 : in std_logic;
	a3 : in std_logic_vector(depth-1 downto 0);
	d3 : in bit_32;
	en3 : in std_logic);
end component;
component mux2
generic (width : positive);
port (i0, i1 : in std_logic_vector(width-1 downto 0);
y : out std_logic_vector(width-1 downto 0);
sel : in std_logic);
end component;
component PC_reg
port (d : in bit_32;
q : out bus_bit_32 bus;
latch_en : in std_logic;
out_en : in std_logic;
reset : in std_logic);
end component;
component ALU_32
port (operand1 : in bit_32;
operand2 : in bit_32;
result : out bus_bit_32 bus;
cond_code : out CC_bits;
command : in ALU_command);
end component;
component cond_code_comparator
port (cc : in CC_bits;
cm : in cm_bits;
result : out std_logic);
end component;
component buffer_32
port (a : in bit_32;
b : out bus_bit_32 bus;
en : in std_logic);
end component;
component latch
generic (width : positive);
port (d : in std_logic_vector(width-1 downto 0);
q : out std_logic_vector(width-1 downto 0);
en : in std_logic);
end component;

component latch_buffer_32
port (d : in bit_32;
q : out bus_bit_32 bus;
latch_en : in std_logic;
out_en : in std_logic);
end component;
component signext_8_32
port (a : in bit_8;
b : out bus_bit_32 bus;
en : in std_logic);
end component;
signal op1_bus : bus_bit_32;
signal op2_bus : bus_bit_32;
signal r_bus : bus_bit_32;
signal ALU_CC : CC_bits;
signal CC : CC_bits;
signal current_instr : bit_32;
alias instr_a1 : bit_8 is current_instr(15 downto 8);
alias instr_a2 : bit_8 is current_instr(7 downto 0);
alias instr_a3 : bit_8 is current_instr(23 downto 16);
alias instr_op : bit_8 is current_instr(31 downto 24);
alias instr_cm : cm_bits is current_instr(19 downto 16);
signal reg_a2 : bit_8:=(others=>'0');
signal reg_result : bit_32;
signal addr_latch_en : std_logic;
signal disp_latch_en : std_logic;
signal disp_out_en : std_logic;
signal d2_en : std_logic;
signal dr_en : std_logic;
signal instr_latch_en : std_logic;
signal immed_signext_en : std_logic;
signal ALU_op : ALU_command;
signal CC_latch_en : std_logic;
signal CC_comp_result : std_logic;
signal PC_latch_en : std_logic;
signal PC_out_en : std_logic;
signal reg_port1_en : std_logic;
signal reg_port2_en : std_logic;
signal reg_port3_en : std_logic;
signal reg_port2_mux_sel : std_logic;
signal reg_res_latch_en : std_logic;
begin -- architecture RTL of dp32
reg_file : reg_file_32_RRW
	generic map (depth => 8)
	port map (a1 => instr_a1, q1 => op1_bus, en1 => reg_port1_en,
			a2 => reg_a2, q2 => op2_bus, en2 => reg_port2_en,
			a3 => instr_a3, d3 => reg_result, en3 => reg_port3_en);
reg_port2_mux : mux2
	generic map (width => 8)
	port map (i0 => instr_a2, i1 => instr_a3, y => reg_a2,
				sel => reg_port2_mux_sel);

reg_res_latch : latch
	generic map (width => 32)
	port map (d => r_bus, q => reg_result, en => reg_res_latch_en);
PC : PC_reg
	port map (d => r_bus, q => op1_bus,
				latch_en => PC_latch_en, out_en => PC_out_en,
				reset => reset);
ALU : ALU_32
	port map (operand1 => op1_bus, operand2 => op2_bus,
			result => r_bus, cond_code => ALU_CC,
			command => ALU_op);
CC_reg : latch
	generic map (width => 3)
	port map (d => ALU_CC, q => CC, en => CC_latch_en);
CC_comp : cond_code_comparator
	port map (cc => CC, cm => instr_cm, result => CC_comp_result);
dr_buffer : buffer_32
	port map (a => d_bus, b => r_bus, en => dr_en);
d2_buffer : buffer_32
	port map (a => op2_bus, b => d_bus, en => d2_en);

disp_latch : latch_buffer_32
	port map (d => d_bus, q => op2_bus,
				latch_en => disp_latch_en, out_en => disp_out_en);

addr_latch : latch
	generic map (width => 32)
	port map (d => r_bus, q => a_bus, en => addr_latch_en);

instr_latch : latch
	generic map (width => 32)
	port map (d => r_bus, q => current_instr, en => instr_latch_en);

immed_signext : signext_8_32
	port map (a => instr_a2, b => op2_bus, en => immed_signext_en);


state_machine: process
	type controller_state is
		(resetting, fetch_0, fetch_1, fetch_2, decode,
		disp_fetch_0, disp_fetch_1, disp_fetch_2,
		execute_0, execute_1, execute_2);
	variable state, next_state : controller_state;
	variable write_back_pending : boolean;
	type ALU_op_select_table is
		array (natural range 0 to 255) of ALU_command;
	constant ALU_op_select : ALU_op_select_table :=
		(16#00# => add,
		16#01# => subtract,
		16#02# => multiply,
		16#03# => divide,
		16#10# => add,
		16#11# => subtract,
		16#12# => multiply,
		16#13# => divide,
		16#04# => log_and,
		16#05# => log_or,
		16#06# => log_xor,
		16#07# => log_mask,
		others => disable);

begin -- process state_machine
	--
	-- start of clock cycle
	--
	wait until phi1 = '1';
	--
	-- check for reset
	--
	if reset = '1' then
		state := resetting;
	--
	-- reset external bus signals
	--
	read <= '0' after Tpd;
	fetch <= '0' after Tpd;
	write <= '0' after Tpd;
	--
	-- reset dp32 internal control signals
	--
	addr_latch_en <= '0' after Tpd;
	disp_latch_en <= '0' after Tpd;
	disp_out_en <= '0' after Tpd;
	d2_en <= '0' after Tpd;
	dr_en <= '0' after Tpd;
	instr_latch_en <= '0' after Tpd;
	immed_signext_en <= '0' after Tpd;
	ALU_op <= disable after Tpd;
	CC_latch_en <= '0' after Tpd;
	PC_latch_en <= '0' after Tpd;
	PC_out_en <= '0' after Tpd;
	reg_port1_en <= '0' after Tpd;
	reg_port2_en <= '0' after Tpd;
	reg_port3_en <= '0' after Tpd;
	reg_port2_mux_sel <= '0' after Tpd;
	reg_res_latch_en <= '0' after Tpd;
	--
	-- clear write-back flag
	--
	write_back_pending := false;
	--
	else -- reset = '0'
	state := next_state;
	end if;

	--
	-- dispatch action for current state
	--
	case state is
	when resetting =>
	--
	-- check for reset going inactive at end of clock cycle
	--
	wait until phi2 = '0';
	if reset = '0' then
	next_state := fetch_0;
	else
	next_state := resetting;
	end if;
	--
	when fetch_0 =>
	--
	-- clean up after previous execute cycles
	--
	reg_port1_en <= '0' after Tpd;
	reg_port2_mux_sel <= '0' after Tpd;
	reg_port2_en <= '0' after Tpd;
	immed_signext_en <= '0' after Tpd;
	disp_out_en <= '0' after Tpd;
	dr_en <= '0' after Tpd;
	read <= '0' after Tpd;
	d2_en <= '0' after Tpd;
	write <= '0' after Tpd;
	--
	-- handle pending register write-back
	--
	if write_back_pending then
	reg_port3_en <= '1' after Tpd;
	end if;
	--
	-- enable PC via ALU to address latch
	--
	PC_out_en <= '1' after Tpd; -- enable PC onto op1_bus
	ALU_op <= pass1 after Tpd; -- pass PC to r_bus
	--
	wait until phi2 = '1';
	addr_latch_en <= '1' after Tpd; -- latch instr address
	wait until phi2 = '0';
	addr_latch_en <= '0' after Tpd;
	--
	next_state := fetch_1;
	--

	when fetch_1 =>
	--
	-- clear pending register write-back
	--
	if write_back_pending then
		reg_port3_en <= '0' after Tpd;
		write_back_pending := false;
	end if;
	--
	-- increment PC & start bus read
	--
	ALU_op <= incr1 after Tpd; -- increment PC onto r_bus
	fetch <= '1' after Tpd;
	read <= '1' after Tpd;
	--
	wait until phi2 = '1';
	PC_latch_en <= '1' after Tpd; -- latch incremented PC
	wait until phi2 = '0';
	PC_latch_en <= '0' after Tpd;
	--
	next_state := fetch_2;
	--
	when fetch_2 =>
	--
	-- cleanup after previous fetch_1
	--
	PC_out_en <= '0' after Tpd; -- disable PC from op1_bus
	ALU_op <= disable after Tpd; -- disable ALU from r_bus
	--
	-- latch current instruction
	--
	dr_en <= '1' after Tpd; -- enable fetched instr onto r_bus
	--
	wait until phi2 = '1';
	instr_latch_en <= '1' after Tpd; -- latch fetched instr from r_bus
	wait until phi2 = '0';
	instr_latch_en <= '0' after Tpd;
	--
	if ready = '1' then
		next_state := decode;
	else
		next_state := fetch_2; -- extend bus read
	end if;
	
	when decode =>
	--
	-- terminate bus read from previous fetch_2
	--
	fetch <= '0' after Tpd;
	read <= '0' after Tpd;
	dr_en <= '0' after Tpd; -- disable fetched instr from r_bus
	--
	-- delay to allow decode logic to settle
	--
	wait until phi2 = '0';
	--
	-- next state based on instr_op of currect instruction
	--
	case instr_op is
		when op_add | op_sub | op_mul | op_div
			| op_addq | op_subq | op_mulq | op_divq
			| op_land | op_lor | op_lxor | op_lmask
			| op_ldq | op_stq =>
			next_state := execute_0;
		when op_ld | op_st =>
			next_state := disp_fetch_0; -- fetch offset
		when op_br | op_bi =>
			if CC_comp_result = '1' then -- if branch taken
				next_state := disp_fetch_0; -- fetch displacement
			else -- else
				next_state := execute_0; -- increment PC
			-- past displacement
			end if;
		when op_brq | op_biq =>
			if CC_comp_result = '1' then -- if branch taken
				next_state := execute_0; -- add immed
				-- displacement to PC
			else -- else
				next_state := fetch_0; -- no action needed
			end if;
		when others =>
			assert false report "illegal instruction" severity warning;
			next_state := fetch_0; -- ignore and carry on
	end case; -- op
	--
	
	when disp_fetch_0 =>
	--
	-- enable PC via ALU to address latch
	--
	PC_out_en <= '1' after Tpd; -- enable PC onto op1_bus
	ALU_op <= pass1 after Tpd; -- pass PC to r_bus
	--
	wait until phi2 = '1';
	addr_latch_en <= '1' after Tpd; -- latch displacement address
	wait until phi2 = '0';
	addr_latch_en <= '0' after Tpd;
	--
	next_state := disp_fetch_1;
	--
	when disp_fetch_1 =>
	--
	-- increment PC & start bus read
	--
	ALU_op <= incr1 after Tpd; -- increment PC onto r_bus
	fetch <= '1' after Tpd;
	read <= '1' after Tpd;
	--
	wait until phi2 = '1';
	PC_latch_en <= '1' after Tpd; -- latch incremented PC
	wait until phi2 = '0';
	PC_latch_en <= '0' after Tpd;
	--
	next_state := disp_fetch_2;
	--
	when disp_fetch_2 =>
	--
	-- cleanup after previous disp_fetch_1
	--
	PC_out_en <= '0' after Tpd; -- disable PC from op1_bus
	ALU_op <= disable after Tpd; -- disable ALU from r_bus
	--
	-- latch displacement
	--
	wait until phi2 = '1';
	disp_latch_en <= '1' after Tpd; -- latch fetched disp from r_bus
	wait until phi2 = '0';
	disp_latch_en <= '0' after Tpd;
	--
	if ready = '1' then
		next_state := execute_0;
	else
		next_state := disp_fetch_2; -- extend bus read
	end if;

	when execute_0 =>
	--
	-- terminate bus read from previous disp_fetch_2
	--
	fetch <= '0' after Tpd;
	read <= '0' after Tpd;
	--
	case instr_op is
		when op_add | op_sub | op_mul | op_div
			| op_addq | op_subq | op_mulq | op_divq
			| op_land | op_lor | op_lxor | op_lmask =>
		-- enable r1 onto op1_bus
				reg_port1_en <= '1' after Tpd;
				if instr_op = op_addq or instr_op = op_subq
					or instr_op = op_mulq or instr_op = op_divq then
		-- enable i8 onto op2_bus
					immed_signext_en <= '1' after Tpd;
				else		
		-- select a2 as port2 address
					reg_port2_mux_sel <= '0' after Tpd;
		-- enable r2 onto op2_bus
					reg_port2_en <= '1' after Tpd;
				end if;
		-- select ALU operation
				ALU_op <= ALU_op_select(bits_to_int(instr_op)) after Tpd;
				--
				wait until phi2 = '1';
		-- latch cond codes from ALU
				CC_latch_en <= '1' after Tpd;
		-- latch result for reg write
				reg_res_latch_en <= '1' after Tpd;
				wait until phi2 = '0';
				CC_latch_en <= '0' after Tpd;
				reg_res_latch_en <= '0' after Tpd;
		--
				next_state := fetch_0; -- execution complete
				write_back_pending := true; -- register write_back required
		--
		when op_ld | op_st | op_ldq | op_stq =>
		-- enable r1 to op1_bus
			reg_port1_en <= '1' after Tpd;
			if instr_op = op_ld or instr_op = op_st then
		-- enable displacement to op2_bus
				disp_out_en <= '1' after Tpd;
			else
		-- enable i8 to op2_bus
				immed_signext_en <= '1' after Tpd;
			end if;
			ALU_op <= add after Tpd; -- effective address to r_bus
		--
			wait until phi2 = '1';
			addr_latch_en <= '1' after Tpd; -- latch effective address
			wait until phi2 = '0';
			addr_latch_en <= '0' after Tpd;
		--
			next_state := execute_1;
		--
	
		when op_br | op_bi | op_brq | op_biq =>
			if CC_comp_result = '1' then
				if instr_op = op_br then
					PC_out_en <= '1' after Tpd;
					disp_out_en <= '1' after Tpd;
				elsif instr_op = op_bi then
					reg_port1_en <= '1' after Tpd;
					disp_out_en <= '1' after Tpd;
				elsif instr_op = op_brq then
					PC_out_en <= '1' after Tpd;
					immed_signext_en <= '1' after Tpd;
				else -- instr_op = op_biq
					reg_port1_en <= '1' after Tpd;
					immed_signext_en <= '1' after Tpd;
				end if;
				ALU_op <= add after Tpd;
			else
				assert instr_op = op_br or instr_op = op_bi
				report "reached state execute_0 "
						& "when brq or biq not taken"
				severity error;
				PC_out_en <= '1' after Tpd;
				ALU_op <= incr1 after Tpd;
			end if;
	--
			wait until phi2 = '1';
			PC_latch_en <= '1' after Tpd; -- latch incremented PC
			wait until phi2 = '0';
			PC_latch_en <= '0' after Tpd;
	--
			next_state := fetch_0;
	--
		when others =>
			null;
	end case; -- op
--

	when execute_1 =>
	--
	-- instr_op is load or store instruction.
	-- cleanup after previous execute_0
	--
		reg_port1_en <= '0' after Tpd;
		if instr_op = op_ld or instr_op = op_st then
	-- disable displacement from op2_bus
			disp_out_en <= '0' after Tpd;
		else
	-- disable i8 from op2_bus
			immed_signext_en <= '0' after Tpd;
		end if;
		ALU_op <= add after Tpd; -- disable ALU from r_bus
--		ALU_op <= disable after Tpd; -- disable ALU from r_bus	--
	-- start bus cycle
	--
		if instr_op = op_ld or instr_op = op_ldq then
			fetch <= '0' after Tpd; -- start bus read
			ALU_op <= disable after Tpd;		
			read <= '1' after Tpd;
		else -- instr_op = op_st or instr_op = op_stq
			reg_port2_mux_sel <= '1' after Tpd; -- address a3 to port2
			reg_port2_en <= '1' after Tpd; -- reg port2 to op2_bus
			d2_en <= '1' after Tpd; -- enable op2_bus to d_bus buffer
			write <= '1' after Tpd; -- start bus write
		end if;
	--
		next_state := execute_2;
	--
	when execute_2 =>
		--
		-- instr_op is load or store instruction.
		-- for load, enable read data onto r_bus
		--
		if instr_op = op_ld or instr_op = op_ldq then
			
			wait until phi2 = '1';
			dr_en <= '1' after Tpd; -- enable data to r_bus
		-- latch data in reg result latch
			reg_res_latch_en <= '1' after Tpd;
			wait until phi2 = '0';
			reg_res_latch_en <= '0' after Tpd;
			write_back_pending := true; -- write-back pending
		end if;
	--
		next_state := fetch_0;
	--
	end case; -- state
end process state_machine;

end RTL;
