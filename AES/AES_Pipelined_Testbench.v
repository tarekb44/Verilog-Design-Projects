`timescale 1ns / 1ps

module AES_Pipelined_Testbench;

    // Inputs
    reg clk;
    reg rst;
    reg [127:0] data_in;
    reg [127:0] key;

    // Output
    wire [127:0] data_out;

    AES_Pipelined uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .key(key),
        .data_out(data_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock (10ns period)

    // Test Vectors
    reg [127:0] plaintext [0:1];
    reg [127:0] test_key [0:1];
    reg [127:0] expected_ciphertext [0:1];
    integer i;

    initial begin
        // Initialize Inputs
        rst = 1;
        #10 rst = 0;

        // Test vectors
        plaintext[0] = 128'h00112233445566778899aabbccddeeff;
        test_key[0] = 128'h000102030405060708090a0b0c0d0e0f;
        expected_ciphertext[0] = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

        plaintext[1] = 128'h3243f6a8885a308d313198a2e0370734;
        test_key[1] = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        expected_ciphertext[1] = 128'h3925841d02dc09fbdc118597196a0b32;

        // Run encryption tests
        for (i = 0; i < 2; i = i + 1) begin
            data_in = plaintext[i];
            key = test_key[i];
            #130; // Wait for data to propagate through the pipeline

            $display("Test %d:", i);
            $display("Plaintext:          %h", plaintext[i]);
            $display("Key:                %h", key);
            $display("Ciphertext Output:  %h", data_out);
            $display("Expected Ciphertext:%h", expected_ciphertext[i]);

            if (data_out == expected_ciphertext[i]) begin
                $display("Test %d Passed\n", i);
            end else begin
                $display("Test %d Failed\n", i);
            end
        end

        $stop;
    end

endmodule