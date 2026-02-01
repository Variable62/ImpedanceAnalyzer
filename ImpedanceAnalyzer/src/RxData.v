//----------------------------------------//
// Filename     : RxData
// Description  : FPGA to ESP parallel data TX
// Company      : KMITL
// Project      : ImpedanceAnalyzer
//----------------------------------------//
// Version      : 00.01
// Date         : 01/02/69
// Author       : Adisorn Sommart
//----------------------------------------//
module RxData (
    input   wire    ExtClk,
    input   wire    ExtResetn,
    input   wire    [3:0]DataIn,
    input   wire    [1:0]ReadPhase, 
    input   wire    ReadPulse,  // stb

    output  wire    [11:0]DataOut,
    output  wire    DataOutvalid
);
//----------------------------------------//
// Signal Declaration
//----------------------------------------//
    reg [11:0] rDataOut;
    reg rDataOutvalid;
//----------------------------------------//
// Output Declaration
//-----------------------------------------//
    assign  DataOut <= rDataOut;
    assign  DataOutvalid <= rDataOutvalid;

//----------------------------------------//
// Process Declaration
//----------------------------------------//
    always @(posedge ExtClk or negedge ExtResetn) begin
        if (!ExtResetn) begin
            rDataOut <= 12'd0;
            rDataOutvalid <= 1'd0;
        end
        else begin
            rDataOutvalid <= 1'd0;
            if (ReadPulse) begin
                case (ReadPhase)
                    2'd0 : rDataOut[3:0] <= DataIn;  
                    2'd1 : rDataOut[7:4] <= DataIn;
                    2'd2 : rDataOut[11:8] <= DataIn;
                endcase
                    rDataOutvalid <= 1'd1;
            end
        end
    end
endmodule