library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fifo_code IS
	port (DI : in std_logic_vector(7 downto 0);
		 WR,RD, Reset: in std_logic;
   	     DO : out std_logic_vector(7 downto 0);
		  full, empty : out std_logic);
END fifo_code;

ARCHITECTURE behav of fifo_code is
TYPE wordsArray is array (0 to 7) of std_logic_vector(7 downto 0);
SIGNAL outWord : std_logic_vector(7 downto 0);
SIGNAL words : wordsArray;

SIGNAL tmpClock : std_logic;
SIGNAL isEmpty : std_logic;
SIGNAL isFull : std_logic;

BEGIN
	tmpClock <= WR or RD;
    
	PROCESS(tmpClock, reset)
    	variable wrCounter : integer range 0 to 7 := 0;
    	variable rdCounter : integer range 0 to 7 := 0;
	BEGIN
    	IF(Reset = '1') THEN
      		wrCounter := 0;
        	rdCounter := 0;
    	ELSE
    	IF rising_edge(tmpClock) THEN
    		IF(WR = '1') THEN
        		words(wrCounter) <= DI;
        		wrCounter := wrCounter + 1;
        		IF(wrCounter > 7) THEN
          			wrCounter := 0;
        		END IF;
        		IF(wrCounter = rdCounter) THEN
        			isFull <= '1';
        			isEmpty <= '0';
        		ELSE
        			isFull <= '0';
        			isEmpty <= '0';
        		END IF;
      		END IF;
   		IF(RD = '1') THEN 
       		outWord <= words(rdCounter);
       		rdCounter := rdCounter + 1;
       		if(rdCounter > 7) THEN
         		rdCounter := 0;
       		END IF;
       		IF(wrCounter = rdCounter) THEN
        		isEmpty <= '1';
        		isFull <= '0';
        	ELSE
        		isEmpty <= '0';
        		isFull <= '0';
        	END IF;
     	END IF;
     	END IF;
    END IF;
    END PROCESS;
    DO <= outWord;
    full <= isFull;
    empty <= isEmpty;
 end behav;
