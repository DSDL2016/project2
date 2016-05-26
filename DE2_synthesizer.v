// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE2 Music Synthesizer
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date   :| Changes Made:
//   V1.0 :| Joe Yang          :| 10/25/2006  :| Initial Revision
// --------------------------------------------------------------------

/////////////////////////////////////////////
////     2Channel-Music-Synthesizer     /////
/////////////////////////////////////////////
/*******************************************/
/*             KEY & SW List               */
/* KEY[0]: I2C reset                       */
/* KEY[1]: Demo Sound repeat               */
/* KEY[2]: Keyboard code Reset             */
/* KEY[3]: Keyboard system Reset           */
/* SW[0] : 0 Brass wave ,1 String wave     */
/* SW[1] : 0 CH1_ON ,1 CH1_OFF             */
/* SW[2] : 0 CH2_ON ,1 CH2_OFF             */
/* SW[9] : 0 DEMO Sound ,1 KeyBoard Play   */
/*******************************************/


module DE2_synthesizer (

		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_27,							//	27 MHz
		CLOCK_50,							//	50 MHz
		////////////////////	Push Button		////////////////////
		START_KEY,							
		////////////////////	DPDT Switch		////////////////////
		SW_STRING,
		SW_RESET,
		SW_MUTE,		
		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		
	
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK,						//	Audio CODEC Chip Clock
		TD_RESET,						//	TV Decoder Reset
	);

////////////////////////	Clock Input	 	////////////////////////
	input			CLOCK_27;					//	27 MHz
	input			CLOCK_50;					//	50 MHz
////////////////////////	Push Button		////////////////////////
	input			START_KEY;					
////////////////////////	DPDT Switch		////////////////////////
	input 		SW_STRING;
	input 		SW_RESET;
	input 		SW_MUTE;
////////////////////////	I2C		////////////////////////////////
	inout			I2C_SDAT;				//	I2C Data
	output		I2C_SCLK;				//	I2C Clock

	
////////////////////	Audio CODEC		////////////////////////////
	inout			AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
	inout			AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
	input			AUD_ADCDAT;			    //	Audio CODEC ADC Data
	output		AUD_DACDAT;				//	Audio CODEC DAC Data
	inout			AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
	output		AUD_XCK;				//	Audio CODEC Chip Clock


	output		TD_RESET;				//	TV Decoder Reset
////////////////////////////////////////////////////////////////////

	
	assign  TD_RESET    =   1;
	
//  I2C
	
	wire I2C_END;
	
	I2C_AV_Config 		u7	(	//	Host Side
								.iCLK		( CLOCK_50 ),
								.iRST_N		( ~SW_RESET ),
								.o_I2C_END	( I2C_END ),
								//	I2C Side
								.I2C_SCLK	( I2C_SCLK ),
								.I2C_SDAT	( I2C_SDAT )	
								
								);



//	AUDIO SOUND

	wire    AUD_CTRL_CLK;
	
	assign	AUD_ADCLRCK	=	AUD_DACLRCK;

	assign	AUD_XCK		=	AUD_CTRL_CLK;			


//  AUDIO PLL

	VGA_Audio_PLL 		u1	(	
								.areset ( ~I2C_END ),
								
								.inclk0 ( CLOCK_27 ),

								.c1		( AUD_CTRL_CLK )	
							
								);


// Music Synthesizer Block //

// TIME & CLOCK Generater //

	reg    [31:0]VGA_CLK_o;

	wire   keyboard_sysclk = VGA_CLK_o[11];

	wire   demo_clock1      = VGA_CLK_o[10]; 
	wire   demo_clock2      = VGA_CLK_o[18]; 

	always @( posedge CLOCK_50 ) VGA_CLK_o = VGA_CLK_o + 1;
		

// DEMO SOUND //

// DEMO Sound (CH1) //

	wire [7:0]demo_code1;
	wire [7:0]demo_code2;
	
	wire [7:0]demo_code;
	assign demo_code = demo_code2;

	demo_sound1	dd1(
		.clock   ( demo_clock1 ),
		.key_code( demo_code1 ),
		.k_tr    ( START_KEY )
	);
	
	demo_sound2	dd2(
		.clock   ( demo_clock2 ),
		.key_code( demo_code2 ),
		.k_tr    ( START_KEY )
	);

////////////Sound Select/////////////	

	wire [15:0]sound1;

	wire sound_off1;

// Staff Display & Sound Output //

	staff st1(
		
		// Key code-in //
		
		.scan_code1( demo_code ),
		//Sound Output to Audio Generater//
		
		.sound1( sound1 ),
		
		.sound_off1( sound_off1 )
		
	);

///////LED Display////////

	//assign LEDR[9:6] = { sound_off1,sound_off1,sound_off1,sound_off1 };
						
// 2CH Audio Sound output -- Audio Generater //

	adio_codec ad1	(	
	        
		// AUDIO CODEC //
		
		.oAUD_BCK ( AUD_BCLK ),
		.oAUD_DATA( AUD_DACDAT ),
		.oAUD_LRCK( AUD_DACLRCK ),																
		.iCLK_18_4( AUD_CTRL_CLK ),
		
		// KEY //
		
		.iRST_N( ~SW_RESET ),							
		.iSrc_Select( 2'b00 ),

		// Sound Control //

		.key1_on( ~SW_MUTE & sound_off1 ),//CH1 ON / OFF					
		.sound1( sound1 ),// CH1 Freq						
		.instru( SW_STRING )  // Instruction Select
	);

endmodule
