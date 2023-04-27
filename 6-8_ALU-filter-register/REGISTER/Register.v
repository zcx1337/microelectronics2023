module DTrigger(Result, Data, Clock, Reset, Ewr);

      input  Data, Clock, Reset, Ewr;
      output Result;
      reg Res, Buf;

      always @(Clock or Reset or Ewr)
        begin
          if (Reset)
              Res = 0;
          else
            begin
               if (!Ewr)
                begin
                  Res = Data;
                  Buf = Data;
                end
               else
                  Res = Buf;
            end
        end

       assign Result = !Res;
endmodule

module MainRegister(OUTRESULT , EWR, CLOCK, RESET, DATA , EDY);

parameter numbits=7;

       input [numbits:0] DATA;
       input EWR, CLOCK, RESET, EDY;
       output [numbits:0] OUTRESULT ;
       reg [numbits:0] res;
       wire[numbits:0] Res ;

       integer i;

       DTrigger (Res[0], DATA[0], CLOCK, RESET, EWR);
       DTrigger (Res[1], DATA[1], CLOCK, RESET, EWR);
       DTrigger (Res[2], DATA[2], CLOCK, RESET, EWR);
       DTrigger (Res[3], DATA[3], CLOCK, RESET, EWR);
       DTrigger (Res[4], DATA[4], CLOCK, RESET, EWR);
       DTrigger (Res[5], DATA[5], CLOCK, RESET, EWR);
       DTrigger (Res[6], DATA[6], CLOCK, RESET, EWR);
       DTrigger (Res[7], DATA[7], CLOCK, RESET, EWR);
       always @ (RESET or CLOCK)
         begin
           if (RESET)
              for (i=0; i<=7; i=i+1)
                  res[i] = 0;
           else
             begin
                if (~EDY)
                   res = ~Res;
                else res = 'bx;
             end
         end

       assign OUTRESULT = res;
endmodule