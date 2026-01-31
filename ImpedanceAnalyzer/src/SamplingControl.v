//----------------------------------------//
// Filename     : SamplingCtrl.v
// Description  : SamplingMode
// Company      : KMITL
// Project      : ImpedanceAnalyzer
//----------------------------------------//
// Version      : 00.01
// Date         : 01/02/2026
// Author       : Adisorn Sommart
// Remark       : New Creation
//----------------------------------------//

module SamplingCtrl (
    input   wire    Fg_CLK,
    input   wire    oIntBtn,
    input   wire    Fg_RESETn,

    output  wire    DDSEnable,  
    output  wire    DDSReady,
    output  wire    [2:0]DDSMode
);
//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    reg [2:0] rDDSMode;
    reg rDDSReady;
    reg rDDSEnable;

    reg [13:0]rValue;

    reg [13:0] rCnt;
    reg begin_ready;
    reg [6:0] rCnt_Ready;
    reg [22:0] rDebounce_Mode;
    reg rPulse_In;

    localparam Twentyfivehundred_ms = 23'd5000000 - 1;

//----------------------------------------//
// Output Declaration
//-----------------------------------------//

    assign  DDSMode = rDDSMode;
    assign  DDSReady = rDDSReady;
    assign  DDSEnable = rDDSEnable;

//----------------------------------------//
// Process Declaration
//----------------------------------------//

//initial ready signal
 always @(posedge Fg_CLK or negedge Fg_RESETn) begin
    if (!Fg_RESETn) begin
        begin_ready <= 1'd0;
    end else begin
        begin_ready <= (rCnt_Ready == 7'd79) ? 1'd1 : begin_ready;
    end
 end

// count ready
always @(posedge Fg_CLK or negedge Fg_RESETn) begin
    if (!Fg_RESETn) begin
        rCnt_Ready <= 7'd0;
    end else begin
        if (begin_ready == 1'd0) begin
            rCnt_Ready <= (rCnt_Ready == 7'd79) ? 7'd0 : rCnt_Ready + 7'd1;
        end
    end
end

always @(posedge Fg_CLK or negedge Fg_RESETn) begin
    if (!Fg_RESETn) begin
        rDDSReady <= 1'd0; 
    end else begin
        if (rCnt_Ready == 7'd79) begin
            rDDSReady <= 1'd1;
        end else begin
            rDDSReady <= 1'd0;
        end
    end
end

  // Debounce Mode
  always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rDebounce_Mode
    if (!Fg_RESETn) begin
      rDebounce_Mode <= 23'd0;
    end else begin
      if ((rDDSEnable && rPulse_In) || (oIntBtn && rDDSMode == 3'd0) && rDebounce_Mode == Twentyfivehundred_ms) begin
        rDebounce_Mode <= 23'd0;
      end else begin
        rDebounce_Mode <= ( rDebounce_Mode < Twentyfivehundred_ms) ?  rDebounce_Mode + 23'd1 :  rDebounce_Mode;
      end
    end
  end

    // Mode Ctrl
  always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rMode
    if (!Fg_RESETn) begin
      rDDSMode <= 3'd0;
    end else begin
      if ((rDDSEnable && rPulse_In) || (oIntBtn && rDDSMode == 3'd0) && rDebounce_Mode == Twentyfivehundred_ms) begin
        rDDSMode <= (rDDSMode < 3'd3) ? rDDSMode + 3'd1 : 3'd0;
      end
    end
  end

    // Signal Generator Mode
  always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rGen_signal
    if (!Fg_RESETn) begin
      rValue <= 14'd1 - 1;
    end else begin
      case (rDDSMode)
        3'd0: rValue <= 14'd1 - 1;
        3'd1: rValue <= 14'd10 - 1;
        3'd2: rValue <= 14'd100 - 1;
        3'd3: rValue <= 14'd1000 - 1;
        default: rValue <= 14'd1 - 1;
        
      endcase
    end
  end

    // Counter for Enable
  always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rCnt_Enable
    if (!Fg_RESETn) begin
      rCnt <= 14'd0;
    end else begin
      rCnt <= (rCnt < rValue) ? rCnt + 14'd3 : 14'd0;
    end
  end

  // Enable Signal
  always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rEnable
    if (!Fg_RESETn) begin
      rDDSEnable <= 1'b0;
    end else begin
      rDDSEnable <= (rCnt == rValue) ? 1'b1 : 1'b0;
    end
  end

    // Pulse Gen from Button
  always @(posedge Fg_CLK or negedge Fg_RESETn) begin : u_rPulse_in
    if (!Fg_RESETn) begin
      rPulse_In <= 1'b0;
    end else if (rDDSEnable) begin
      rPulse_In <= 1'b0;
    end else if (oIntBtn) begin
      rPulse_In <= 1'b1;
    end else begin
      rPulse_In <= rPulse_In;
    end
  end
endmodule