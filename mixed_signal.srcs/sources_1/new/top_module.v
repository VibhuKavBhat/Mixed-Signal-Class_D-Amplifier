module top_module(

    //input [7:0] freq_sel,
    input rst,
    input start,
    input clk,
    output out1,
    output out2
    //output amp_en
    
    );

    parameter PWM = 2; // 1 = 390Khz, 2 = 195Khz, 3 = , 4 = 97KHz
    parameter Audio_sampling = 1999; //100MHz/2000 = 50KHz
    parameter deadtime = 20;

    reg [7:0] ctr_PWM;
    reg [10:0] ctr_audio;
    
    reg audio_tick;
    reg [7:0] sawtooth;
    reg [7:0] audio_addr;
    wire [7:0] audio;
    
    //assign amp_en = 1;
    
//timers
    always @(posedge clk, posedge rst) begin
        if (rst) begin            
            ctr_audio <= 0;            
            audio_tick <= 0;
        end

        else begin            
            if (ctr_audio >= Audio_sampling) begin
                ctr_audio <= 0;
                audio_tick <= 1;
            end

            else begin
                ctr_audio <= ctr_audio + 1;
                audio_tick <= 0;
            end          
                
        end
    end
    

//audio
    always @(posedge clk, posedge rst) begin
        if (rst) audio_addr <= 0;
        else if (audio_tick) audio_addr <= audio_addr + 1;
    end
    
    sine_rom audio1 (audio_addr, audio);


//sawtooth    
    always @(posedge clk, posedge rst) begin
        if (rst) begin sawtooth <= 0; ctr_PWM <= 0; end
        else begin 
            
            if (ctr_PWM >= PWM - 1) begin
                ctr_PWM <= 0;
                sawtooth <= sawtooth + 1;
            end else begin
                ctr_PWM <= ctr_PWM + 1;            
            end
        end
    end
    
    
    
//comparator 
    reg pwm_raw;
    always @(posedge clk or posedge rst) begin
        if (rst) pwm_raw <= 0;
        else pwm_raw <= (audio >= sawtooth);
    end

// 2. The 20-cycle Shift Register (Minimal Delay)
    reg [deadtime-1:0] delay_reg;
    always @(posedge clk) begin
        delay_reg <= {delay_reg[deadtime-2:0], pwm_raw};
    end

    wire pwm_delayed = delay_reg[deadtime-1];

// Dead-time Outputs
// out1 turns on only when both current and delayed are 1
// out2 turns on only when both current and delayed are 0
    assign out1 = pwm_raw & pwm_delayed;
    assign out2 = ~(pwm_raw | pwm_delayed);
    
    
    
endmodule
