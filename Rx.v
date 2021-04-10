`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:56:35 03/07/2020 
// Design Name: 
// Module Name:    Rx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Rx(input wire clk, input wire reset, input wire rx, output wire [0:7]dataByte, output reg dataInEnable);
	reg [0:13]counter = 0; //9600 Baud @ 50Mhz
	localparam MAX_TICK = 5208;
	
	localparam [1:0]
		IDLE = 2'b00,
		START = 2'b01,
		DATA = 2'b10,
		STOP = 2'b11;
		
	reg [0:2]bitPos = 0;
	reg [0:7]dataBuff = 0;

	reg [1:0]state = 0;
	reg [1:0]nextState = 0;
	
	assign dataByte = dataBuff;
	
	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin
			nextState <= IDLE;
			counter <= 0;
			bitPos <= 0;
			dataBuff <= 0;
			dataInEnable <= 0;
		end
		
		else
		begin
			state <= nextState;
			
			case(state)
				IDLE:
				begin
					dataInEnable <= 1'b0;
					counter <= 0;
					bitPos <= 0;
					
					if(state == IDLE && rx == 0)
						nextState <= START;
				end
			
				START:
				begin
					counter <= counter + 1;
					
					if(counter == MAX_TICK / 2)
					begin
						if(rx == 0) //rx still low?
						begin
							nextState <= DATA;
							counter <= 0;
						end
						
						else
							nextState <= IDLE;
					end
				end
				
				DATA:
				begin
					counter <= counter + 1;
					dataBuff[bitPos] <= rx;
					
					if(bitPos < 7 && counter == MAX_TICK)
					begin
						bitPos <= bitPos + 1;
						counter <= 0;
					end
					
					else if(bitPos == 7 && counter == MAX_TICK)
						nextState <= STOP;
				end
				
				STOP:
				begin
					dataInEnable <= 1'b1;
					
					counter <= counter + 1;
					if(counter == MAX_TICK)
					begin
						nextState <= IDLE;
						counter <= 0;
					end
				end
			
			endcase
		end
	end
endmodule
