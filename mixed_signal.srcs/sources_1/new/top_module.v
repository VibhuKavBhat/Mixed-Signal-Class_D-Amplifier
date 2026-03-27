module top_module(

    input [7:0] freq_sel,
    input rst,
    input start,
    input clk,
    output reg out
    
    );
    
    reg [11:0] ctr_clk;
    reg [7:0] sawtooth;
    reg [7:0] audio;
    reg clk_out = 0;
    
//clk divider
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin clk_out <= 0; ctr_clk <= 0; end
        else if (ctr_clk >= 3999) begin ctr_clk <= 0; clk_out <= ~clk_out; end
        else ctr_clk <= ctr_clk + 1;
    end
    

//audio
    audio sine_rom(sawtooth, audio);


//sawtooth    
    always @(posedge clk_out, posedge rst) begin
        if (rst) sawtooth <= 0;
        else if (sawtooth >= 255) sawtooth <= 0;
        else sawtooth <= sawtooth + 1;
    end
    
    
    
//comparator 
    always @(posedge clk_out, posedge rst) begin
        if (rst) out <= 0;
        else if (audio >= sawtooth) out <= 1;
        else out <= 0;
    end

    
    
    
    
endmodule
