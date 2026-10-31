`timescale 1ns/10ps
module uart_tb();

		reg [0:7] shift_reg;
	reg clk;				//	works with 1.8432 MHz
	reg send_enable, Rx,rst,inc;
	wire Tx,next,recieved;
	wire [0:7] data_recieved;
	wire baud_clk,receiving;
	wire [3:0] bits_send, bits_recieve;
	wire [7:0] baud_rate, baud;
	wire recieved_delay;   // We need to turn the recieved pin off after 1 cycle, so this helps in it.
	
	uart u(
	.shift_reg(shift_reg),
	.clk(clk),
	.send_enable(send_enable), .Rx(Rx),.rst(rst),.inc(inc),
	.Tx(Tx),.next(next),.recieved(recieved),
	.data_recieved(data_recieved),
	.baud_clk(baud_clk),.receiving(receiving),
	.bits_send(bits_send), .bits_recieve(bits_recieve),
	.baud_rate(baud_rate), .baud(baud),
	.recieved_delay(recieved_delay)  // We need to turn the recieved pin off after 1 cycle, so this helps in it. 	
	);
	
	
	always #27 clk=~clk;
	initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, uart_tb);
		  
		rst=1;
		clk=0;
		#150 rst=0;
		#50 shift_reg=8'b10011011;
		#500000 send_enable=1;
		#700000 inc=1;
		#500 inc=0;
		
		#2207360
		$finish;
	end
	
	always@(posedge baud_clk) Rx<=$random % 2;
	
	always@(posedge clk) begin
		if(next) send_enable<=0;
	end
	
	endmodule