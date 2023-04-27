// Модуль - АЛУ.
module ALU(command_code,xdata,ydata,clock,result,flagZ,flagO,flagN);
parameter numbits=3;

   input    [2:0] command_code;             // код команды
   input    clock;                          // синхроимпульс
   input    [numbits:0] xdata, ydata;       // входные данные 
   output   [2*numbits+1:0] result;         // результат операции 
   output   flagZ,flagO,flagN;              // флаги 0, переполн. и отрицат.
   reg      [2*numbits+1:0] res;
   reg      z,o,n;

//*********************************************
// Task - задание - выход==вход
task Disable;
  output [2*numbits+1:0] Disable;
  input  [numbits:0] x, y;
  begin
    y=x;
    Disable=x;
  end
endtask
//*********************************************

//*********************************************
// Task - задание - сумматор
task Summator;
  output [2*numbits+1:0] Summator;
  input  [numbits:0] x, y;
  input  c_in;
  integer i;
  reg a,b,c,d,a1,b1,c1,bit,summa;

  begin
  for (i=0; i<=numbits; i=i+1)
    begin
       a= ~x[i]&~y[i]&c_in;
       b= ~x[i]&y[i]&~c_in;
       c=c_in&x[i]&y[i];
       d=x[i]&~y[i]&~c_in;
       Summator[i]=a|b|c|d;

       a1=x[i]&y[i]&~c_in;
       b1=x[i]&~y[i]&c_in;
       c1=~x[i]&y[i]&c_in;
       bit=c|a1|b1|c1;
       c_in=bit;
    end
    Summator[numbits+1]=bit;
    for (i=numbits+2; i<=2*numbits+1; i=i+1)
         Summator[i]=0;
   end
endtask
//*********************************************

//*********************************************
// Task - задание - вычитание
task Substance;
  output [2*numbits+1:0] Substance;
  input  [numbits:0] x, y;
  begin
    if (x>=y)
       Substance=x-y;
    else 
       Substance=y-x;
  end
endtask
//*********************************************

//*********************************************
// Task - задание - умножение
task Multiple;
  output [2*numbits+1:0] Multiple;
  input  [numbits:0] x, y;
  begin
    if ((x>=0 && y>=0)||(x<=0 && y<=0))
       Multiple=x*y;
    if ((x>0 && y<0)||(x<0 && y>0))
       Multiple=-x*y;
  end
endtask
//*********************************************

//*********************************************
// Task - задание - деление
task Divide;
  output [2*numbits+1:0] Divide;
  input  [numbits:0] x, y;
  begin
    if (!y) 
       Divide='bx;
    else
      begin
        if ((x>=0 && y>0)||(x<=0 && y<0))
           Divide=x/y;
        if ((x>0 && y<0)||(x<0 && y>0))
           Divide=-x/y;
      end
  end
endtask 
//*********************************************

//*********************************************
// Task - задание - побитовое И
task Operation_and;
  output [2*numbits+1:0] Operation_and;
  input  [numbits:0] x, y;
  integer i;
  begin
    for (i=0; i<=numbits; i=i+1)
        Operation_and[i]=x[i]&&y[i];
    for (i=numbits+1; i<=2*numbits+1; i=i+1)
        Operation_and[i]=0;
  end
endtask
//*********************************************

//*********************************************
// Task - задание - побитовое ИЛИ
task Operation_or;
  output [2*numbits+1:0] Operation_or;
  input  [numbits:0] x, y;
  integer i;
  begin
    for (i=0; i<=numbits; i=i+1)
        Operation_or[i]=x[i]||y[i];
    for (i=numbits+1; i<=2*numbits+1; i=i+1)
        Operation_or[i]=0;
  end
endtask
//*********************************************

//*********************************************
// Task - задание - побитовое инвертирование
task Operation_not;
  output [2*numbits+1:0] Operation_not;
  input  [numbits:0] x, y;
  integer i;
  begin
    y=x;
    for (i=0; i<=numbits; i=i+1)
        Operation_not[i]=~x[i];
    for (i=numbits+1; i<=2*numbits+1; i=i+1)
        Operation_not[i]=0;
  end
endtask
//*********************************************

   always @(posedge clock) 
   begin
   case (command_code)
         'b000:
            begin
              Disable(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               if (res<0)
                   n=1;
               else 
                   n=0;
               o=0;
            end
// Сложение
         'b001:
            begin
               Summator(res,xdata,ydata,0);
               z = (res==0) ? 1 : 0;
               if (res<0)
                   n=1;
               else 
                   n=0;
               o=0;
            end
// Вычитание
         'b010:
            begin
               Substance(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               if (xdata<ydata)
                   n=1;
               else 
                   n=0;
               o=0;
            end
// Умножение
         'b011:
            begin
               Multiple(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               if (res<0)
                   n=1;
               else
                   n=0;
               if ((xdata<0&&ydata>0)||(xdata>0&&ydata<0))
                  n=1;
               else 
                  n=0;
               o=0;
            end
// Деление
         'b100:
            begin
               o=(ydata==0) ? 1 : 0;
               Divide(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               if ((xdata<0&&ydata>0)||(xdata>0&&ydata<0))
                  n=1;
               else 
                  n=0;
            end
// Логическое  " И "
         'b101:
            begin
               Operation_and(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               n=0;
               o=0;
            end
// Логическое " ИЛИ "
         'b110:
            begin
               Operation_or(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               n=0;
               o=0;
            end
// Побитное инвертирование, логическое " НЕ "
         'b111:
            begin
               Operation_not(res,xdata,ydata);
               z = (res==0) ? 1 : 0;
               n=0;
               o=0;
            end
          default: res='bx; // Необрабатываемые коды команды
   endcase
   end
   assign result=res;  //  Результат
   assign flagZ=z;     //  Флаг -  результат-нуль
   assign flagN=n;     //  Флаг -  результат-отрицательный
   assign flagO=o;     //  Флаг -  переполнение
endmodule


