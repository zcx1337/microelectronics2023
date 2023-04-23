library verilog;
use verilog.vl_types.all;
entity Counter is
    generic(
        gnd             : integer := 0
    );
    port(
        clear           : in     vl_logic;
        clk             : in     vl_logic;
        dat_in          : in     vl_logic_vector(3 downto 0);
        hold            : in     vl_logic;
        load            : in     vl_logic;
        high            : out    vl_logic_vector(3 downto 0);
        low             : out    vl_logic_vector(3 downto 0);
        zero            : out    vl_logic
    );
end Counter;
