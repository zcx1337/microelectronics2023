library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fifo_code is
	port (DI : in std_logic_vector(7 downto 0);
		 WR,RD, Reset: in std_logic;
   	     DO : out std_logic_vector(7 downto 0);
		  full, empty : out std_logic);
end fifo_code;

architecture behav of fifo_code is
type wordsArray is array (0 to 7) of std_logic_vector(7 downto 0);
signal outWord : std_logic_vector(7 downto 0);
signal words : wordsArray;
signal tmp : wordsArray;

begin
    process(WR,RD)
    --variable wrCounter : integer range 0 to 7 := 0;
    --variable rdCounter : integer range 0 to 7 := 0;
	begin


    if(Reset = '1') then
      --wrCounter := 0;
      --rdCounter := 0;
      	words(0) <= "00000000";
	words(1) <= "00000000";
words(2) <= "00000000";
words(3) <= "00000000";
words(4) <= "00000000";
words(5) <= "00000000";
words(6) <= "00000000";
words(7) <= "00000000";
    else
      --if (WR'event and WR = '1') then
      --if rising_edge(WR) then
      if(WR = '1') then
      	words(0) <= "00001000";
        --words(wrCounter) <= DI;
        --wrCounter := wrCounter + 1;
        --if(wrCounter > 7) then
          --wrCounter := 0;
        --end if;
     end if;
     --if rising_edge(RD) then
     if(RD = '1') then 
       --outWord <= words(rdCounter);
       --rdCounter := rdCounter + 1;
       outWord <= words(0);
       --if(rdCounter > 7) then
         --rdCounter := 0;
       --end if;
     end if;
    end if;
    end process;
    DO <= outWord;
    full <= '0';
    empty <= '0';
    end behav;
