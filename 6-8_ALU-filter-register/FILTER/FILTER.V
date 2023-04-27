module RStrigger (out,x,xdop);
   
   input x,xdop;
   output out;
   reg res;

   always @(xdop or x)
      begin
        if (~xdop)
           res = 0;
        else
          if (~x)
           res = 1;
      end
   assign out = !res;
endmodule

module Filter (OutResult, X, A, B);

   input   X, A, B;
   output  OutResult;

   not NOT1 (AInv, A);
   not NOT2 (BInv, B);

   RStrigger call1 (ou1, X, A);
   RStrigger call2 (ou2, X, B);
   RStrigger call3 (ou3, X, AInv);
   RStrigger call4 (ou4, X, BInv);

   and  AND1 (OutResult,ou1, ou2, ou3, ou4);
endmodule
         
