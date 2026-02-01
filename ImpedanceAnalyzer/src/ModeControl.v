//----------------------------------------//
// Filename     : ModeControl
// Description  : 
// Company      : KMITL
// Project      : ImpedanceAnalyzer
//----------------------------------------//
// Version      : 00.01
// Date         : 01/02/69
// Author       : Adisorn Sommart
//----------------------------------------//
module ModeControl (
    input   wire    ExtClk,
    input   wire    ExtResetn,
    input   wire    [11:0]DataIn,
    input   wire    DataInvalid,

    output  wire     [1:0]FreqMode,
    output  wire     StartMeasure
);
    reg     [1:0]rFreqMode;
    reg     rStartMeasure;

    assign  FreqMode <= rFreqMode;
    assign  StartMeasure <= rStartMeasure;

    always @(posedge ExtClk or negedge ExtResetn) begin
        if (!ExtResetn) begin
            rFreqMode <= 2'd0;
            rStartMeasure <= 1'd0;
        end
        else begin
            rStartMeasure <= 1'd0;
            if (DataInvalid) begin
                if (DataIn < 12'd4) begin
                    rFreqMode <= DataIn[1:0]; // Change freq
                end
                else if (DataIn == 12'd4) begin
                    rStartMeasure <= 1'd1; //Start Measure Phase
                end
            end
        end
    end
endmodule