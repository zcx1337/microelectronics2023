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
			(			 
			0=>X"1000_0000",
		    1=>X"1001_0008",
			2=>X"1002_0100",
		 	3=>X"1003_0000",
    		4=>X"3004_0064",
			5=>X"1101_0101",
			6=>X"1002_0100",
 	        7=>X"1001_0100",
			8=>X"4109_0000",
			9=>X"0000_0010",
			10=>X"1005_0000",
			11=>X"1005_0501",
			12=>X"3006_0564",
			13=>X"3106_0563",
			14=>X"0108_0501",
            15=>X"500A_00FB",
            16=>X"1001_0100",
			17=>X"410B_0000",
		 	18=>X"0000_002C",
            19=>X"1002_0200",
			20=>X"410B_0000",
			21=>X"0000_0029",
			22=>X"3006_0064",
            23=>X"0108_0406",
	    	24=>X"410B_0000",
			25=>X"0000_001E",
			26=>X"1005_0400",
			27=>X"1004_0600",
			28=>X"4100_0000",
			29=>X"0000_001F",
			30=>X"1005_0600",
			31=>X"1007_0000",
			32=>X"1007_0701",
        	33=>X"3006_0764",
			34=>X"3106_0763",
        	35=>X"1108_0101",
			36=>X"0108_0708",
			37=>X"500A_00FA",
		    38=>X"3105_0163",
			39=>X"1102_0201",
			40=>X"5000_00EA",
    		41=>X"3104_036E",
	    	42=>X"1003_0301",
			43=>X"5000_00D8",
		    44=>X"3104_036E",
		    45=>X"1003_0301",
			46=>X"0007_0300",
			47=>X"0005_0000",
			48=>X"1107_0701",
			49=>X"1005_0501",
			50=>X"3006_076E",
			51=>X"3106_0563",
            52=>X"0108_0503",
			53=>X"500A_00FA",
		    54=>X"0000_0000",
		   100=>X"0000_0004",		
  		   101=>X"0000_0007",
		   102=>X"0000_0002",
  		   103=>X"0000_0009",
  		   104=>X"0000_0003",
  		   105=>X"0000_0000",
  		   106=>X"0000_0011",		
  		   107=>X"0000_0006",
		   109=>X"0000_0000",
  		   110=>X"0000_0000",			 
  		   111=>X"0000_0000",
  		   112=>X"0000_0000",
  		   113=>X"0000_0000",
  		   114=>X"0000_0000",
  		   115=>X"0000_0000",
  		   116=>X"0000_0000",
  		   117=>X"0000_0000",
  		   118=>X"0000_0000",
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
				mem(address):=d_bus;--'delayed(Tpd); -- sample data from Tpd ago
			else  -- read='1'
				d_bus <= mem(address) after Tpd;	-- fetch data
				ready <='1' after Tpd;
				wait until read='0'; -- hold for read cycle
			end if;
		end if;
	end process;		
end behaviour;						


