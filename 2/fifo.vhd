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
type words is array (7 downto 0) of std_logic_vector(7 downto 0);
signal outWord : std_logic_vector(7 downto 0);
begin
    process(WR,RD)
    variable wrCounter : integer := 0;
    variable rdCounter : integer := 0;
    begin
    if(Reset = '1') then
      wrCounter := 0;
      rdCounter := 0;
    end if;
      if (WR = '1') then
        words(wrCounter) <= data;
        wrCounter := wrCounter + 1;
        if(wrCounter > 8) then
          wrCounter := 0;
        end if;
      end if;
      if (RD = '1') then
        outWord <= words(rdCounter);
        rdCounter := rdCounter + 1;
        if(rdCounter > 8) then
          rdCounter := 0;
        end if;
      end if;
    end process;
DO <= outWord;
end behav;


