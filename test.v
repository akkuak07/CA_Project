`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2021 01:59:45
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module test; 
 reg clk1, clk2; 
 integer k; 
 code risc(clk1, clk2);
 initial 
 begin 
 clk1 = 0; clk2 = 0; 
 repeat (40) // Generating two-phase clock 
 begin 
 #5 clk1 = 1; #5 clk1 = 0; 
 #5 clk2 = 1; #5 clk2 = 0; 
 end 
 end 
 initial
 begin
 $dumpfile ("risc.vcd"); 
 $dumpvars (0, test); 
 #300 $finish; 
 end 
endmodule
