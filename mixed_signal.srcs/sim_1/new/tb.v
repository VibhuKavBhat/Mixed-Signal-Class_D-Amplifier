module tb();

    // 1. Declare Testbench Signals
    reg [7:0] freq_sel;
    reg rst;
    reg start;
    reg clk;
    wire out;

    // 2. Instantiate the Unit Under Test (UUT)
    top_module uut (
        .freq_sel(freq_sel), 
        .rst(rst), 
        .start(start), 
        .clk(clk), 
        .out(out)
    );

    // 3. Generate the 100 MHz System Clock
    // 100 MHz = 10 nanosecond period (5ns HIGH, 5ns LOW)
    always #5 clk = ~clk;

    // 4. Test Sequence
    initial begin
        // Initialize Inputs
        clk = 0;
        freq_sel = 1;
        start = 0;
        
        // Assert Reset to initialize all registers
        rst = 1; 
        #100; // Hold reset for 100ns
        
        // De-assert Reset and let the system run
        rst = 0;
        
        // Wait and watch!
        // We need to wait a long time in simulation time because 
        // the audio tick only fires every 20,000 ns (50 kHz).
        // Let's run it for 100,000 ns (100 us) to see 5 full audio steps.
        #100000;
        
        // Pause the simulation
        $stop; 
    end

endmodule