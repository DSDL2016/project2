module stopwatch(
    input clock,   //clock_50MHz
    input reset,
    input start,   //Enable
    output reg [3:0] d8, d7, d6, d5, d4, d3, d2, d1
    );
	
	reg [18:0] ticker; //500000
	wire click;


//the mod 500000 clock to generate a tick every 0.01 second

always @ (posedge clock or negedge reset)
begin
	if(!reset)    //DE2-70 KEY[0]=normal Hi , so pressed down is Low
		ticker <= 0;

	else if(ticker == 500_000) //if it reaches the desired max value reset it
		ticker <= 0;
  
	else if(start)             //only start if the input is set high
		ticker <= ticker + 1;
end

assign click = ((ticker == 500_000)?1'b1:1'b0); //click to be assigned high every 0.01 second

always @ (posedge clock or negedge reset)
begin
	if (!reset)
		begin
		d1 <= 0;
		d2 <= 0;
		d3 <= 0;
		d4 <= 0;
		d5 <= 0;
		d6 <= 0;
		d7 <= 0;
		d8 <= 0;
		end
   
	else if (click) //increment at every click  (0.01Sec)
		begin
		if(d1 == 9) //xxx9 - the 0.01 second digit
			begin  //if_1
			d1 <= 0;
		 
			if (d2 == 9) //xx99 - the 0.1 second digit
				begin  // if_2
				d2 <= 0;
		   
				if (d3 == 9) //x999 - the second digit
					begin //if_3
					d3 <= 0;
			   
					if(d4 == 5) //5999 - the ten seconds digit
						begin //if_4
						d4 <= 0;
				 
						if (d5 == 9) //95999--- the minute digit
							begin //if_5
							d5 <= 0;
					
							if (d6 == 5) //595999 - the ten minutes digit
								begin //if_6
								d6 <= 0;
						
								if (d7 == 9) //9595999 - the hour digit
									begin //if_7
									d7 <= 0;
							
									if (d8 == 9) //99595999 - the ten hours digit
										d8 <= 0;
							
									else
										d8 = d8+1;
								end
						
							else
								d7 <= d7+1;
							end 
						
						else
							d6 <= d6+1;
						end 
					
					else
						d5 <= d5+1;
					end 
					 
				else   
					d4 <= d4 + 1;
				end
			else 
				d3 <= d3 + 1;
			end
			 
		else 
			d2 <= d2 + 1;
		end
			
	else 
		d1 <= d1 + 1;
	end

end
endmodule