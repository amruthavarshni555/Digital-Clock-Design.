module clk_divider(clk,reset,clk_1hz);
input clk,reset;
reg [25:0]count;
output reg clk_1hz;
always@(posedge clk or posedge reset) begin
    if(reset) begin
        count <= 0;
        clk_1hz <= 1'b0;
    end
    else if( count == 1 ) begin
         count <= 0;
        clk_1hz <= ~clk_1hz; 
    end
    
    else begin  
    count <= count + 1;
    
    end 
end 
endmodule 

module count10(clk,enable, carry,reset,count);
input clk, reset,enable;
output reg [3:0]count;
output reg carry;
always@(posedge clk or posedge reset)
begin
    if(reset) begin 
    count <= 4'b0000;
    carry <= 0;
    end
    else if(enable) begin
     if(count == 9) begin 
       count <= 4'b0000;
       carry <= 1'b1;
    end 
    else begin 
     count <= count +1;
     carry <= 1'b0;
    end 
   end
   else begin 
   count <= count;
   carry <= 0;
   end 
end 
endmodule 

module count6(clk,reset,count,enable,carry);
input clk, reset, enable;
output reg [2:0]count;
output reg carry;
always@(posedge clk or posedge reset)
begin
    if(reset) begin 
    count <= 3'b000;
    carry <= 0;
    end 
    else if(enable) begin 
     if(count == 5) begin 
     count <= 3'b000;
     carry <= 1'b1;
     end 
    else begin 
     count <= count + 1;
     carry <= 1'b0;
    end 
    end 
    else begin
    count <= count;
    carry <= 1'b0;
end 
end 
endmodule 

module mod60sec(clk,reset,enable,ones,tens,carrymod60sec);
 input clk, reset,enable;
 output  [3:0]ones;
 output  [2:0]tens;
 output  carrymod60sec;
 wire carry10;

count10 uu1(.clk(clk), .reset(reset), .count(ones), .enable(enable), .carry(carry10));

count6 uu2(.clk(clk),.reset(reset),.enable(carry10), .count(tens), .carry(carrymod60sec));

endmodule 

// logic for minutes. we can also code it like sec but this reduces hardware and it is less and easy connection.

module mincount(clk,reset,enable,ones,tens,carrymin);

 input clk, reset,enable;
 output reg [3:0]ones;
 output reg [2:0]tens;
 output reg carrymin;

 always@(posedge clk or posedge reset) begin
    if(reset) begin
    ones <= 0;
    tens <= 0;
    carrymin <= 0;
    end
    else if(enable) begin 
        if(ones == 9 && tens == 5) begin
             ones <= 0;
             tens <= 0;
             carrymin <= 1;
        end 
        else if(ones == 9) begin
            ones <= 0; 
            tens <= tens + 1;
            carrymin <= 0;
        end
        else  begin
         ones <= ones + 1;
         carrymin <= 0;
    end 
    end 
    else 
    carrymin <= 0;
 end 
endmodule 

module mintop(clk,reset,enable,ones_min,tens_min,carrymod60min,ones_sec,tens_sec);
input clk,reset,enable;
output  [3:0]ones_sec;
output  [2:0]tens_sec;
wire carry;
output  [3:0]ones_min;
output  [2:0]tens_min;

output carrymod60min;

mod60sec uu4(.clk(clk), .reset(reset), .enable(enable), .ones(ones_sec), .tens(tens_sec), .carrymod60sec(carry));

mincount uu5(.clk(clk), .reset(reset), .enable(carry), .ones(ones_min), .tens(tens_min), .carrymin(carrymod60min));     
endmodule 


module mod24(clk,reset,ones,tens,enable);
input clk, reset,enable;
output reg [3:0]ones;
output reg [1:0]tens;
always@(posedge clk or posedge reset) begin
    if(reset) begin
        ones <= 0;
        tens <= 0;
    end
    else if(enable) begin 
        if(tens == 2 && ones == 3) begin
             ones <= 0;
             tens <= 0;
        end
        else if( ones == 9) begin
            ones <= 0;
            tens <= tens + 1;
        end
        else 
         ones <= ones +1;
    end
end

endmodule 
     // final clock top module 
module digitalclk(clk,reset,ones_min,tens_min,ones_sec,tens_sec,ones_hr,tens_hr);

input clk,reset;
output  [3:0]ones_sec;
output  [2:0]tens_sec;

output  [3:0]ones_min;
output  [2:0]tens_min;

output  [3:0]ones_hr;
output  [1:0]tens_hr;
wire carryf;
wire slow_clk;

clk_divider uu6(.clk(clk), .reset(reset), .clk_1hz(slow_clk));

mintop uu7(.clk(clk), .reset(reset), .enable(slow_clk), .ones_sec(ones_sec), .tens_sec(tens_sec), .ones_min(ones_min), 
            .tens_min(tens_min), .carrymod60min(carryf) );

mod24 uu8(.clk(clk), .reset(reset), .enable(carryf), .ones(ones_hr), .tens(tens_hr));

endmodule 

// display 7 segment
module sevenseg ( input clk,
    input reset,

    input [3:0] ones_sec, 
    input [2:0] tens_sec,
    input [3:0] ones_min, 
    input [2:0] tens_min,
    input [3:0] ones_hr, 
    input [1:0] tens_hr,

    output reg [6:0] seg,   // a b c d e f g
    output reg [5:0] an     // 6 digit enable
);
reg[2:0] sel;
always@(posedge clk or posedge  reset) begin
    if(reset)
    sel <= 0;
    else if( sel == 5 )
    sel <= 0;
    else 
    sel <= sel +1;
end 

reg [3:0] digit;

always@(*) begin 
 case(sel) 
    3'd0: digit = ones_sec;
    3'd1: digit = tens_sec;
    3'd2: digit = ones_min;
    3'd3: digit = tens_min;
    3'd4: digit = ones_hr;
    3'd5: digit = tens_hr;
    default: digit = 0;
 
 endcase
end 

always@(*) begin 
 case(sel) 
   3'd0: an = 6'b000001;
   3'd1: an = 6'b000010;
   3'd2: an = 6'b000100;
   3'd3: an = 6'b001000;
   3'd4: an = 6'b010000;
   3'd5: an = 6'b100000;
   default: an = 6'b000001;
    endcase
end

always@(*) begin
    case(digit) 
    4'd0: seg = 7'b1111110;
    4'd1: seg = 7'b0110000;
    4'd2: seg = 7'b1101101;
    4'd3: seg = 7'b1111001;
    4'd4: seg = 7'b0110011;
    4'd5: seg = 7'b1011011;
    4'd6: seg = 7'b1011111;
    4'd7: seg = 7'b1110000;
    4'd8: seg = 7'b1111111;
    4'd9: seg = 7'b1111011;
    default: seg = 7'b0000000;
    endcase
end
endmodule


module finaldisplay(input clk,
    input reset,
    output  [6:0] seg,   // a b c d e f g
    output  [5:0] an );

    wire [3:0] ones_sec;
    wire [2:0] tens_sec;
    wire [3:0] ones_min;
    wire [2:0] tens_min;
    wire [3:0] ones_hr;
    wire [1:0] tens_hr;

    digitalclk uu9( .clk(clk), .reset(reset),.ones_min(ones_min),.tens_min(tens_min), 
                    .ones_sec(ones_sec), .tens_sec(tens_sec), .ones_hr(ones_hr), .tens_hr(tens_hr));

    sevenseg uu10 (.clk(clk), .reset(reset),.ones_min(ones_min),.tens_min(tens_min), 
                    .ones_sec(ones_sec), .tens_sec(tens_sec), .ones_hr(ones_hr), .tens_hr(tens_hr), .seg(seg), .an(an));

endmodule 



















