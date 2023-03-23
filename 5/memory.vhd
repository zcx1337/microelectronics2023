USE work.dp32_types.all,work.alu_32_types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity memory is
	generic (Tpd	:Time:= unit_delay);
	port (	d_bus	:inout bus_bit_32 bus;
			a_bus	:in  bit_32;
			read	:in  std_logic;
			write	:in  std_logic;
			ready	:out std_logic);
end  memory;
ARCHITECTURE behaviour OF memory IS
begin
	process
		constant  low_address :integer :=0;
		constant high_address :integer :=65535;
		type memory_array is 
			array(integer range low_address to high_address)of bit_32;
		variable address : integer:=0;
		variable mem :memory_array:=
      (X"0700_0000",
       X"1001_0004",
       X"1004_0001",
       X"1003_0001",    
       X"3002_010A", 
       X"0405_0204",
       X"5009_0001",    
       X"0203_0302",
       X"1101_0101",    
       X"5004_00FA", --end of prog
       X"0000_0001", --start of vector
       X"0000_0004",
       X"0000_0009",
       X"0000_0003",
       X"0000_0002",
       others =>X"0000_0000");
	begin
		--
		-- put d_bus and reply into initial state
		--
		d_bus <=null after Tpd;
		ready <='0' after Tpd;
		--
		-- wait for a command
		--
		wait until (read='1')or(write='1');
		--
		-- dispatch read or write cycle
		--
		address := bits_to_int(a_bus);
		if address >=low_address and address <=high_address then
			-- address match for this memory
			if write ='1' then
				ready<='1' after Tpd;
				wait until write='0'; -- wait until end of write cycle
				mem(address):=d_bus'delayed(Tpd); -- sample data from Tpd ago
			else  -- read='1'
				d_bus <= mem(address) after Tpd;	-- fetch data
				ready <='1' after Tpd;
				wait until read='0'; -- hold for read cycle
			end if;
		end if;
	end process;		
end behaviour;						

