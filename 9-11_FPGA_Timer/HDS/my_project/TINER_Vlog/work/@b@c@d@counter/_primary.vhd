library verilog;
use verilog.vl_types.all;
entity BCDCounter is
    generic(
        prop_delay      : integer := 10
    );
    port(
        cnten           : in     vl_logic;
        clear           : in     vl_logic;
        clk             : in     vl_logic;
        load            : in     vl_logic;
        dat_in          : in     vl_logic_vector(3 downto 0);
        carry_in        : in     vl_logic_vector(3 downto 0);
        count           : out    vl_logic_vector(3 downto 0);
        zero            : out    vl_logic
    );
end BCDCounter;
