//----------------------------------------//
// Filename     : TxData.v
// Description  : Parallel + Handshake FPGA → ESP
//----------------------------------------//
module TxData (
    input   wire        ExtClk,
    input   wire        ExtResetn,
    input   wire [11:0] TxData,
    input   wire        Req,

    output  reg         Ack,
    output  reg  [3:0]  DataOut
);

    //------------------------------------//
    // State Declaration
    //------------------------------------//
    parameter   StateIdle = 3'd0,
                SendData0 = 3'd1,
                WaitData0 = 3'd2,
                SendData1 = 3'd3,
                WaitData1 = 3'd4,
                SendData2 = 3'd5,
                WaitData2 = 3'd6;

    reg [2:0] rState;

    //------------------------------------//
    // FSM
    //------------------------------------//
    always @(posedge ExtClk or negedge ExtResetn) begin
        if (!ExtResetn) begin
            rState  <= StateIdle;
            Ack     <= 1'b0;
            DataOut <= 4'd0;
        end
        else begin
            case (rState)

                StateIdle: begin
                    Ack <= 1'b0;
                    if (Req)
                        rState <= SendData0;
                end

                SendData0: begin
                    DataOut <= TxData[3:0];
                    Ack     <= 1'b1;
                    rState  <= WaitData0;
                end

                WaitData0: begin
                    if (!Req) begin
                        Ack    <= 1'b0;
                        rState <= SendData1;
                    end
                end

                SendData1: begin
                    DataOut <= TxData[7:4];
                    Ack     <= 1'b1;
                    rState  <= WaitData1;
                end

                WaitData1: begin
                    if (!Req) begin
                        Ack    <= 1'b0;
                        rState <= SendData2;
                    end
                end

                SendData2: begin
                    DataOut <= TxData[11:8];
                    Ack     <= 1'b1;
                    rState  <= WaitData2;
                end

                WaitData2: begin
                    if (!Req) begin
                        Ack    <= 1'b0;
                        rState <= StateIdle;
                    end
                end

                default: rState <= StateIdle;
            endcase
        end
    end

endmodule
