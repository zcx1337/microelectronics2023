USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity clock_gen is
	generic (Tpw	: Time:= 8 ns;
			 Tps	: Time:= 2 ns);
	port (phi1,phi2	:out std_logic;
		  reset		:out std_logic);
end  clock_gen;
ARCHITECTURE behaviour OF clock_gen IS
	Constant clock_period:Time :=2*(Tpw+Tps);
begin
	reset_driver:
		reset <='1','0' after 2*clock_period+Tpw;
	clock_driver:process
	begin	
		phi1 <= '1','0' after Tpw;
		phi2 <= '1'after Tpw+Tps,'0' after Tpw+Tps+Tpw;
 		wait for clock_period;
	end process clock_driver;
end behaviour;						

