module rom (
  input clk,              // Clock signal
  input en,               // Enable signal
  input reset,            // Asynchronous reset signal
  input [3:0] addr,       // 4-bit address input
  output reg [3:0] data,  // 4-bit data output
  output reg parity_error // Parity error flag
);

  // 4-bit memory with 16 locations
  reg [3:0] mem [15:0];
  
  // Parity bits for memory locations (single-bit parity for each memory location)
  reg parity [15:0]; 

  // Function to compute even parity for a 4-bit data input
  function [0:0] calc_parity;
    input [3:0] d;        // 4-bit input
    begin
      calc_parity = ^d;   // XOR all bits to compute even parity (1 if odd number of 1s)
    end
  endfunction

  // Memory read and parity check process, triggered by the clock or reset
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      // Reset behavior: clear data and parity error
      data <= 4'b0000;
      parity_error <= 1'b0;
    end else if (en) begin
      // Read data from memory when enabled
      data <= mem[addr];
      
      // Check parity: if the calculated parity doesn't match the stored parity, set error
      if (calc_parity(mem[addr]) !== parity[addr]) begin
        parity_error <= 1'b1;  // Set parity error flag
      end else begin
        parity_error <= 1'b0;  // Clear parity error flag if no mismatch
      end
    end else begin
      // If disabled, output invalid data and set parity error to undefined
      data <= 4'bxxxx;
      parity_error <= 1'bx;
    end
  end

  // Initial block to initialize memory and corresponding parity bits
  initial begin
    // Initialize memory contents
    mem[0]  = 4'b0010; mem[1]  = 4'b0010; mem[2]  = 4'b1110; mem[3]  = 4'b0010;
    mem[4]  = 4'b0100; mem[5]  = 4'b1010; mem[6]  = 4'b1100; mem[7]  = 4'b0000;
    mem[8]  = 4'b1010; mem[9]  = 4'b0010; mem[10] = 4'b1110; mem[11] = 4'b0010;
    mem[12] = 4'b0100; mem[13] = 4'b1010; mem[14] = 4'b1100; mem[15] = 4'b0000;

    // Initialize corresponding parity bits using the parity calculation function
    parity[0]  = calc_parity(mem[0]);  parity[1]  = calc_parity(mem[1]);
    parity[2]  = calc_parity(mem[2]);  parity[3]  = calc_parity(mem[3]);
    parity[4]  = calc_parity(mem[4]);  parity[5]  = calc_parity(mem[5]);
    parity[6]  = calc_parity(mem[6]);  parity[7]  = calc_parity(mem[7]);
    parity[8]  = calc_parity(mem[8]);  parity[9]  = calc_parity(mem[9]);
    parity[10] = calc_parity(mem[10]); parity[11] = calc_parity(mem[11]);
    parity[12] = calc_parity(mem[12]); parity[13] = calc_parity(mem[13]);
    parity[14] = calc_parity(mem[14]); parity[15] = calc_parity(mem[15]);
  end

endmodule