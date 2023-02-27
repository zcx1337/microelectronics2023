use work.dp32_types.all;
configuration dp32_rtl_test of dp32_test is
	for structure
		for cg : clock_gen
			use entity work.clock_gen(behaviour)
				generic map (Tpw => 8 ns, Tps => 2 ns);
		end for;
		for mem : memory
			use entity work.memory(behaviour);
		end for;
		for proc : dp32
			use entity work.dp32(rtl);
			for rtl
				for all : reg_file_32_rrw
					use entity work.reg_file_32_rrw(behaviour);
				end for;
				for all : mux2
					use entity work.mux2(behaviour);
				end for;
				for all : latch
					use entity work.latch(behaviour);
				end for;
				for all : PC_reg
					use entity work.PC_reg(behaviour);
				end for;
				for all : ALU_32
					use entity work.ALU_32(behaviour);
				end for;
				for all : cond_code_comparator
					use entity work.cond_code_comparator(behaviour);
				end for;
				for all : buffer_32
					use entity work.buffer_32(behaviour);
				end for;
				for all : latch_buffer_32
					use entity work.latch_buffer_32(behaviour);
				end for;
				for all : signext_8_32
					use entity work.signext_8_32(behaviour);
				end for;
			end for;
		end for;
	end for;
end dp32_rtl_test;
