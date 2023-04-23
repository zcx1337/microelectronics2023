module BCDCounter (cnten, clear, clk, load, dat_in, carry_in, count, zero);
 parameter prop_delay = 10;
 input cnten, clear, clk, load;
 input [3:0] dat_in;
 input [3:0] carry_in;
 output zero;
 output [3:0] count;
 reg zero;
 reg [3:0] count;
 reg [3:0] int_count;
 always @ (posedge clk)
 begin
 if (clk == 1)
 begin
 zero = 1;
 if (clear == 1) int_count = 4'b0000 ;
 else if (load == 1) int_count = dat_in ;
 else if (cnten == 0)
 begin
 if ((int_count == 4'b0000) && (carry_in != 4'b0000)) int_count = 4'b1001 ;
 else int_count = int_count - 1'b1 ;
 end
 else int_count = int_count ;
 end
 zero = (int_count[3] | int_count[2]) | (int_count[1] | int_count[0]);
 #prop_delay count = int_count ;
 end
endmodule