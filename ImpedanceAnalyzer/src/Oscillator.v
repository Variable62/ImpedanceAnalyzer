//----------------------------------------//
// Filename     : Oscillator.v
// Description  : Create Digital Sinewave
// Company      : KMITL
// Project      : ImpedanceAnalyzer
//----------------------------------------//
// Version      : 00.01
// Date         : 1/2/69
// Author       : Adisorn Sommart
// Remark       :   
//----------------------------------------//
module Oscillator (
    input  wire        Fg_CLK,
    input  wire        Fg_RESETn,
    input  wire        Enable,
    input  wire        Ready,
    input  wire [31:0] init_1,     // sin(b)
    input  wire [31:0] init_2,     // 2cos(b)
    // input  wire [ 2:0] DDSMode,
    
    output wire [31:0] out_1,
    output wire [31:0] out_2
);
  //----------------------------------------//
  // Signal Declaration
  //----------------------------------------//

  reg [31:0] rA; // digital gain
  reg [63:0] rC;
  reg [31:0] out_1_a;
  reg [31:0] rOut;
  reg [31:0] rout_1;
  reg [31:0] rout_2;

  //----------------------------------------//
  // Output Declaration
  //----------------------------------------//

  assign out_1 = rout_1;
  assign out_2 = rout_2;

  //----------------------------------------//
  // Process Declaration
  //----------------------------------------//
    always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rout_1
        if (!Fg_RESETn) begin
            rout_1 <= 32'd0;
        end
        else if (Ready) begin
            rout_1 <= init_1; // Sin(B)
        end
        else if (Enable) begin
            rout_1 <= rOut;
        end
        else begin
            rout_1 <= rout_1;
        end
    end

    always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rout_2
        if (!Fg_RESETn) begin
            rout_2 <= 32'd0;
        end
        else if (Ready) begin
            rout_2 <= 32'd0;
        end
        else if (Enable) begin
            rout_2 <= rout_1;
        end
        else begin
            rout_2 <= rout_2;
        end
    end

    always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rA
        if (!Fg_RESETn) begin
            rA <= 32'd0;
        end
        else if (Ready) begin
            rA  <= init_2;
        end
        else    begin
            rA <=   rA;
        end
    end

    always @(*) begin
        rC <= $signed(rA)*$signed(rout_1);
        out_1_a <= rC[60:29];
    end

    always @(*) begin
        rOut <= out_1_a - rout_2;
    end

endmodule