library verilog;
use verilog.vl_types.all;
entity TIMER_tester is
    port(
        alarm           : in     vl_logic;
        high            : in     vl_logic_vector(3 downto 0);
        low             : in     vl_logic_vector(3 downto 0);
        clk             : out    vl_logic;
        d               : out    vl_logic_vector(9 downto 0);
        reset           : out    vl_logic;
        start           : out    vl_logic;
        stop            : out    vl_logic
    );
end TIMER_tester;
