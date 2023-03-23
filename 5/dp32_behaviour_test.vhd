Configuration dp32_behaviour_test of dp32_test is
 for structure
 for cg : clock_gen
 use entity work.clock_gen (behaviour)
 generic map (Tpw => 8 ns, Tps => 4 ns);
 end for;
 for mem : memory
 use entity work.memory (behaviour);
 end for;
 for proc: dp32
 use entity work.dp32 (behaviour);
 end for;
 end for;
end dp32_behaviour_test;





