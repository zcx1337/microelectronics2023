entity odd_mult is
    Port ( vector : in  std_logic_vector(4 downto 0);
           result : out integer);
end odd_mult;

architecture Behavioral of odd_mult is
begin

    process(vector)
        variable odd_product : integer := 1;
    begin
        for i in vector'range loop
            if (vector(i) mod 2 = 1) then
                odd_product := odd_product * to_integer(unsigned(vector(i)));
            end if;
        end loop;
        result <= odd_product;
    end process;

end Behavioral;
