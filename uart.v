module Tx(input wire clk, input wire reset, input wire [0:7]dataByte, input wire txStart, output reg tx);
	reg [0:13]counter = 0; //9600 Baud @ 50Mhz
	localparam MAX_TICK = 5208;

	reg [0:2]bitPos = 0;

	reg [1:0]state = 0;
	reg [1:0]nextState = 0;

	localparam [1:0]
		IDLE = 2'b00,
		START = 2'b01,
		DATA = 2'b10,
		STOP = 2'b11;

	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin
			counter <= 0;
			bitPos <= 0;
			nextState <= IDLE;
		end

		else
		begin
			state <= nextState;

			//state logic
			case(state)
				IDLE:
				begin
					tx <= 1'b1;
					bitPos <= 0;
					counter <= 0;
					
					if(txStart)
						nextState <= START;
				end

				START:
				begin
					tx <= 1'b0;
					
					counter <= counter + 1;
					
					if(counter == MAX_TICK)
					begin
						nextState <= DATA;
						counter <= 0;
					end
				end
				
				DATA:
				begin
					tx <= dataByte[bitPos];
					counter <= counter + 1;
					
					if(bitPos < 7 && counter == MAX_TICK)
					begin
						bitPos <= bitPos + 1;
						counter <= 0;
					end
					
					else if(bitPos == 7 && counter == MAX_TICK)
					begin
						nextState <= STOP;
						counter <= 0;
					end
				end

				STOP:
				begin
					tx <= 1'b1;
					
					if(txStart == 0)
						counter <= counter + 1;
						
					if(counter >= MAX_TICK)
					begin
						counter <= 0;
						nextState <= IDLE;
					end
				end
			endcase
		end
	end
endmodule
