`timescale 1ns / 1ps

module AES_Pipelined (
    input clk,
    input rst,
    input [127:0] data_in,
    input [127:0] key,
    output reg [127:0] data_out
);
    reg [127:0] pipeline [0:10];  // 11 pipeline stages
    wire [127:0] round_keys [0:10]; // Round keys
    integer i;

    // Key expansion module
    KeyExpansion key_expansion_inst (
        .key(key),
        .round_keys(round_keys)
    );

    // AES Round Functions
    function [127:0] AES_Round (input [127:0] state, input [127:0] round_key);
        begin
            AES_Round = AddRoundKey(MixColumns(ShiftRows(SubBytes(state))), round_key);
        end
    endfunction

    function [127:0] AES_FinalRound (input [127:0] state, input [127:0] round_key);
        begin
            AES_FinalRound = AddRoundKey(ShiftRows(SubBytes(state)), round_key);
        end
    endfunction

    // SubBytes Transformation
    function [127:0] SubBytes(input [127:0] state);
        integer j;
        reg [7:0] sbox [0:255];
        begin
            // Initialize the S-box (AES S-box)
            sbox[8'h00] = 8'h63; sbox[8'h01] = 8'h7c; sbox[8'h02] = 8'h77; sbox[8'h03] = 8'h7b;
            sbox[8'h04] = 8'hf2; sbox[8'h05] = 8'h6b; sbox[8'h06] = 8'h6f; sbox[8'h07] = 8'hc5;
            sbox[8'h08] = 8'h30; sbox[8'h09] = 8'h01; sbox[8'h0A] = 8'h67; sbox[8'h0B] = 8'h2b;
            sbox[8'h0C] = 8'hfe; sbox[8'h0D] = 8'hd7; sbox[8'h0E] = 8'hab; sbox[8'h0F] = 8'h76;
            // ... (Include all 256 entries of the S-box)
            // Ensure the S-box is fully initialized.

            for (j = 0; j < 16; j = j + 1) begin
                SubBytes[127 - 8*j -: 8] = sbox[state[127 - 8*j -: 8]];
            end
        end
    endfunction

    // ShiftRows Transformation
    function [127:0] ShiftRows(input [127:0] state);
        reg [7:0] temp [0:15];
        begin
            // Extract state bytes
            for (i = 0; i < 16; i = i + 1) begin
                temp[i] = state[127 - 8*i -: 8];
            end

            // Perform ShiftRows operation
            ShiftRows = {
                temp[0],  temp[5],  temp[10], temp[15],
                temp[4],  temp[9],  temp[14], temp[3],
                temp[8],  temp[13], temp[2],  temp[7],
                temp[12], temp[1],  temp[6],  temp[11]
            };
        end
    endfunction

    // MixColumns Transformation
    function [127:0] MixColumns(input [127:0] state);
        reg [7:0] s [0:15];
        reg [7:0] s_new [0:15];
        integer i;
        begin
            // Extract state bytes
            for (i = 0; i < 16; i = i + 1) begin
                s[i] = state[127 - 8*i -: 8];
            end

            // MixColumns operation
            for (i = 0; i < 4; i = i + 1) begin
                s_new[4*i+0] = gf_mul(8'h02, s[4*i+0]) ^ gf_mul(8'h03, s[4*i+1]) ^ s[4*i+2] ^ s[4*i+3];
                s_new[4*i+1] = s[4*i+0] ^ gf_mul(8'h02, s[4*i+1]) ^ gf_mul(8'h03, s[4*i+2]) ^ s[4*i+3];
                s_new[4*i+2] = s[4*i+0] ^ s[4*i+1] ^ gf_mul(8'h02, s[4*i+2]) ^ gf_mul(8'h03, s[4*i+3]);
                s_new[4*i+3] = gf_mul(8'h03, s[4*i+0]) ^ s[4*i+1] ^ s[4*i+2] ^ gf_mul(8'h02, s[4*i+3]);
            end

            // Combine bytes back into state
            for (i = 0; i < 16; i = i + 1) begin
                MixColumns[127 - 8*i -: 8] = s_new[i];
            end
        end
    endfunction

    // Galois Field multiplication
    function [7:0] gf_mul(input [7:0] a, input [7:0] b);
        reg [7:0] p;
        reg [7:0] hi_bit_set;
        integer i;
        begin
            p = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                if (b[0] == 1)
                    p = p ^ a;
                hi_bit_set = a & 8'h80;
                a = a << 1;
                if (hi_bit_set == 8'h80)
                    a = a ^ 8'h1b;
                b = b >> 1;
            end
            gf_mul = p;
        end
    endfunction

    // AddRoundKey Transformation
    function [127:0] AddRoundKey(input [127:0] state, input [127:0] round_key);
        begin
            AddRoundKey = state ^ round_key;
        end
    endfunction

    // Pipeline process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i <= 10; i = i + 1) begin
                pipeline[i] <= 0;
            end
            data_out <= 0;
        end else begin
            // Initial AddRoundKey
            pipeline[0] <= AddRoundKey(data_in, round_keys[0]);

            // Rounds 1 to 9
            for (i = 1; i < 10; i = i + 1) begin
                pipeline[i] <= AES_Round(pipeline[i - 1], round_keys[i]);
            end

            // Final Round (without MixColumns)
            pipeline[10] <= AES_FinalRound(pipeline[9], round_keys[10]);
            data_out <= pipeline[10];
        end
    end

endmodule