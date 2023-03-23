package odd_mult_types is
subtype vector_address is natural range 0 to 4;
type vector_t is array (vector_address) of integer;
end odd_mult_types;

entity odd_mult is
    Port
    (
        vector : in  odd_mult_types.vector_t;
        result : out integer
    );
end odd_mult;

architecture Behavioral of odd_mult is
begin
    process(vector)
        variable odd_product : integer := 1;
    begin
        for i in vector'range loop
            if (vector(i) mod 2 = 1) then
                odd_product := odd_product * vector(i);
            end if;
        end loop;
        result <= odd_product;
        odd_product := 1;
    end process;
end Behavioral;

