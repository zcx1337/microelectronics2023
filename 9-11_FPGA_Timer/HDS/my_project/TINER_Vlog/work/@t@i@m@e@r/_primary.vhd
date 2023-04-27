library verilog;
use verilog.vl_types.all;
entity TIMER is
    port(
        clk             : in     vl_logic;
        d               : in     vl_logic_vector(9 downto 0);
        reset           : in     vl_logic;
        start           : in     vl_logic;
        stop            : in     vl_logic;
        alarm           : out    vl_logic;
        high            : out    vl_logic_vector(3 downto 0);
        low             : out    vl_logic_vector(3 downto 0)
    );
end TIMER;
