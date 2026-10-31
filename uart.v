module uart(
	input [0:7] shift_reg,
	input clk,				//	works with 1.8432 MHz
	input send_enable, Rx,rst,inc,
	output reg Tx,next,recieved,
	output reg [0:7] data_recieved,
	output reg baud_clk,receiving,
	output reg [3:0] bits_send, bits_recieve,
	output reg [7:0] baud_rate, baud,
	output reg recieved_delay  // We need to turn the recieved pin off after delay of 1 cycle, so this helps in it. 	
);

	/*reg [0:7] data_recieved;
	reg baud_clk,receiving;
	reg [3:0] bits_send, bits_recieve;
	reg [7:0] baud_rate, baud;
	reg recieved_delay;  // We need to turn the recieved pin off after 1 cycle, so this helps in it.  */
	
	//--------baud_rate generator---------
	
	parameter B115200= 8'd16;
	parameter B57600= 8'd32;
	parameter B28800= 8'd64;
	parameter B14400= 8'd128;
	parameter B9600= 8'd192;
	
	always @(posedge clk) begin //--------decides baud rate----------
		
		if(rst) baud_rate<=B9600;
		if(inc) begin
			case (baud_rate)
				B9600:baud_rate<=B14400;
				B14400:baud_rate<=B28800;
				B28800:baud_rate<=B57600;
				B57600:baud_rate<=B115200;
				B115200:baud_rate<=B9600;
			endcase
		end
	end
	
	always@(posedge clk) begin  //--------baud clock generator-------
		if(rst) begin
			baud<=8'd0;
			baud_clk<=0;
		end
		else baud<=baud+1;
		
		if(baud==baud_rate) begin
			baud<=0;
			baud_clk<=~baud_clk;
		end
	end
	
	always@ (posedge baud_clk or posedge rst) begin  //----------Tx-----------
		if(rst) begin
			 bits_send<=0;
			end
		else if(!send_enable) begin
			Tx<=1;
			bits_send<=0;
		end
		else if(send_enable) begin
			if(bits_send!=4'd9) next<=0;
			case(bits_send)
				4'd0:Tx<=0;
				4'd1:Tx<=shift_reg[0];
				4'd2:Tx<=shift_reg[1];
				4'd3:Tx<=shift_reg[2];
				4'd4:Tx<=shift_reg[3];
				4'd5:Tx<=shift_reg[4];
				4'd6:Tx<=shift_reg[5];
				4'd7:Tx<=shift_reg[6];
				4'd8:Tx<=shift_reg[7];
				4'd9: begin
							Tx<=1;
							next<=1;
						end
			endcase
			bits_send<=bits_send+1;
		end
	end
	
	
	always@(posedge baud_clk or posedge rst) begin //---------Rx---------
		if(rst) begin 
			receiving<=0;
			recieved<=0;
		end
		else if(bits_recieve==4'd8) begin
			receiving<=0;
			if(recieved_delay) begin
					recieved<=0;
					recieved_delay<=0;
					bits_recieve<=0;
					
			end
			else if(recieved) begin 
						recieved_delay <=1;		
						
			end
			else recieved<=1;
		end
		else if(receiving) begin 
			data_recieved[bits_recieve]<=Rx;
			bits_recieve<=bits_recieve+1;      //bits_recieve is a counter 
		end
		else if(Rx==0&&!recieved) begin
			if(receiving!=1) begin
				receiving<=1;
				bits_recieve<=0;
		end
		end
		
		
				
				
	end
endmodule
		
			
	
		
			
			
		
	
	
	
	
	
	
	
				