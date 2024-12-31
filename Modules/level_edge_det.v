module level_det(input clk, in,
						output pulse);
	reg r1, r2, r3;
	initial begin
		r1 <= 0;
		r2 <= 0;
		r3 <= 0;
	end
	
	always @ (posedge clk) begin
		r1 <= in;
		r2 <= r1;
		r3 <= r2;
	end
	
	assign pulse = r2 & ~r3;
endmodule
