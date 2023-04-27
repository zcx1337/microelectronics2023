library verilog;
use verilog.vl_types.all;
entity Control is
    generic(
        ZEROS           : integer := 0;
        flush           : integer := 0;
        load_u          : integer := 1;
        load_t          : integer := 2;
        getkey          : integer := 3;
        alarm           : integer := 4;
        standby         : integer := 5;
        suspend         : integer := 6;
        counting        : integer := 7;
        end_count       : integer := 8
    );
    port(
        clk             : in     vl_logic;
        d               : in     vl_logic_vector(9 downto 0);
        reset           : in     vl_logic;
        start           : in     vl_logic;
        stop            : in     vl_logic;
        zero            : in     vl_logic;
        beep            : out    vl_logic;
        clear           : out    vl_logic;
        hold            : out    vl_logic;
        load            : out    vl_logic
    );
end Control;
