//----------------------------------------//
// Filename     : interpolator.v
// Description  : Smooth Sinewave From Oscillator module
// Company      : KMITL
// Project      : ImpedanceAnalyzer
//----------------------------------------//
// Version      : 00.01
// Date         : 1/2/69
// Author       : Adisorn Sommart
// Remark       : fix delta 
//----------------------------------------//
module Interpolator (
    input   wire        Fg_CLK,
    input   wire        Fg_RESETn,
    input   wire [31:0] out_1,  // Y[n-1]
    input   wire [31:0] out_2, // Y[n-2]
    input   wire [2:0]  Mode,
    input   wire        Enable,
    output  wire [11:0] InterpOut
);
//----------------------------------------//
// Signal Declaration
//----------------------------------------//
    reg [31:0] N;
    reg [63:0] delta;
    reg [31:0] Out;
    reg [11:0] rInterpOut;
    reg Enable_delay;
//----------------------------------------//
// Output Declaration
//----------------------------------------//
    assign  InterpOut = {~rInterpOut[11],rInterpOut[10:0]};
//----------------------------------------//
// Process Declaration
//----------------------------------------//
    always @(posedge Fg_CLK or negedge Fg_RESETn) begin 
    if (~Fg_RESETn) begin
        N <= 32'd1;
    end
        else    begin
            case (Mode)
                    0: N <= 32'd1; 
                    1: N <= 32'd53687091;    
                    2: N <= 32'd5368709;
                    3: N <= 32'd536871;
                    default: N <= 32'd1;
            endcase
        end
    end

    always @(posedge Fg_CLK or negedge Fg_RESETn) begin 
    if (~Fg_RESETn) begin
        Enable_delay <= 0;
    end
    else begin
            Enable_delay <= Enable;
        end
    end

    always @(posedge Fg_CLK or negedge Fg_RESETn) begin
    if(~Fg_RESETn) begin
        Out <= 0;
    end
    else begin 
        if (Enable_delay) begin    
            Out <= out_2;
        end
         else begin
            Out <= Out + delta[60:29];
        end
    end
    end

    always @(*) begin
        delta = ($signed(out_1) - $signed(out_2)) * $signed(N);
        rInterpOut = Out[29:18]; 
    end

endmodule