library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY lifo_code IS
	port (DI : in std_logic_vector(7 downto 0);
		 WR,RD, Reset: in std_logic;
   	     DO : out std_logic_vector(7 downto 0);
		  full, empty : out std_logic);
END lifo_code;

ARCHITECTURE behav of lifo_code is
TYPE wordsArray is array (0 to 7) of std_logic_vector(7 downto 0);
SIGNAL outWord : std_logic_vector(7 downto 0);
SIGNAL words : wordsArray;

SIGNAL tmpClock : std_logic;
SIGNAL isEmpty : std_logic;
SIGNAL isFull : std_logic;
BEGIN
	tmpClock <= WR or RD;
    
	PROCESS(tmpClock, reset)
    	variable counter : integer range 0 to 7 := 0;
    	variable rdCounter : integer range 0 to 7 := 0;
	BEGIN
    	IF(Reset = '1') THEN
      		counter := 0;
    	ELSE
    	IF rising_edge(tmpClock) THEN
    		IF(WR = '1') THEN   			
        		words(counter) <= DI;
        		counter := counter + 1;
        		IF counter > 7 THEN
        			counter := 0;
        		END IF;
      		END IF;
   			IF(RD = '1') THEN 
   			counter := counter - 1;
       			outWord <= words(counter);      			
       			IF counter < 0 THEN
       				counter := 7;
       			END IF;
     		END IF;
     		IF counter = 7 THEN
     			isFull <= '1';
     			isEmpty <= '0';
     		ELSIF counter = 0 THEN
     			isFull <= '0';
     			isEmpty <= '1';
     		ELSE
     			isFull <= '0';
     			isEmpty <= '0';
     		END IF;
     	END IF;
    END IF;
    END PROCESS;
    DO <= outWord;
    full <= isFull;
    empty <= isEmpty;
 END behav;

