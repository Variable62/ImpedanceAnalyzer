//----------------------------------------//
// Filename     : ImzTop
// Description  : Summary all module
// Company      : KMITL
// Project      : ImpedanceAnalyzer
//----------------------------------------//
// Version      : 00.01
// Date         : 01/02/69
// Author       : Adisorn Sommart
//----------------------------------------//
module ImzTop (
    input   wire    ExtClk,
    input   wire    ExtResetn,
    input   wire    [3:0]DataIn,
    input   wire    [1:0]ReadPhase,
    input   wire    ReadPulse,

    output  wire    [11:0]FreqOut,
    output  wire    [11:0]DataOut,
    output  wire    Dac_CLK
);
    wire    wPllResetn;
    wire    wLock;
    wire    wPllClk;
    wire    wFgResetn;
    wire    wFgClk;
    wire    wEnable;
    wire    wReady;
    wire    [31:0]wOut1;
    wire    [31:0]wOut2;
    wire    wDataoutValid;

    localparam [31:0]Init1 = 32'd96878045;
    localparam [31:0]Init2 = 32'd1054193702;

    pll_module m_pll_module (
        .clkout(wPllClk),
        .lock(wLock),
        .reset(~wPllResetn),
        .clkin(ExtClk)
    );

    Reset_Gen m_Reset_Gen (
        .Ext_RESETn(ExtClk),
        .Ext_CLK(ExtClk),
        .PllLocked(wLock),
        .PllRESETn(wPllResetn), 
        .Fg_RESETn(wFgResetn)
    );

    clk_div m_clk_div (
        .Pll_CLK(wPllClk),
        .RESETn(wFgResetn),
        .Fg_CLK(wFgClk),
        .Dac_CLK(Dac_CLK)
    );

    Oscillator m_Oscillator (
        .Fg_CLK(wFgClk),
        .Fg_RESETn(wFgResetn),
        .Enable(wEnable),
        .Ready(wReady),
        .init_1(Init1),
        .init_2(Init2),
        .out_1(wOut1),
        .out_2(wOut2)
    );

    Interpolator m_Interpolator (
        .Fg_CLK(wFgClk),
        .Fg_RESETn(wFgResetn),
        .out_1(wOut1),
        .out_2(wOut2),
        .Mode(),
        .Enable(wEnable),
        .InterpOut(FreqOut)
    )

    RxData m_RxData( // read data from esp32
        .ExtClk(ExtClk),
        .ExtResetn(ExtResetn),
        .DataIn(DataIn),
        .ReadPhase(ReadPhase),
        .ReadPulse(ReadPulse),
        .DataOut(DataOut),
        .DataOutvalid()
    );

    TxData m_TxData( // Send data to esp32
        .ExtClk(ExtClk),
        .ExtResetn(ExtResetn),
        .TxData(),
        .Req(),
        .Ack(),
        .DataOut()
    );

    ModeControl m_ModeControl(
        .ExtClk(),
        .ExtResetn(),
        
    );

endmodule