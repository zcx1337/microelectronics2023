module odd_mult(
    input [159:0] arr,
    output reg [31:0] result
);

reg [31:0] a[0:4];

reg [31:0] res;

integer i, j, k;

always @(*) begin
    for (i = 0; i < 5; i = i + 1) begin
        //a[i] = arr[(i+1)*32-1:i*32];
        //for (j = (i+1)*32-1; j < i*32; j = j + 1) begin
        for (j = 0; j < 32; j = j + 1) begin
          k = i * 32 + j;
          a[i][j] = arr[k];
        end
    end
    
    res = 1;
    for (i=0; i<5; i=i+1) begin
      if (a[i] % 2 == 1) begin
        res = res * a[i];
      end
    end
   
   result = res;
end

endmodule