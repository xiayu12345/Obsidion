
/**************************************************/		
// I2C power module controller		
/**************************************************/ 

void DisplayOn()
{
  Set_POWER(1,1,1,1);//1.8V ON, 2.8V ON, 5V ON, BL ON
}


void PowerOffSequence()
{
	DCS_Short_Write_NP(0x28);
	Delay(200);
	DCS_Short_Write_NP(0x10);
	Delay(100);
	Set_STANDBY();//Video transfer stop
	Delay(50);


	//Delay(10000);  
	//Delay(10000);
	//Delay(10000);




	Set_RESET(1,0);//MIPI RESET 1, LCD RESET 0
	Delay(50);
	Set_RESET(0,0);//MIPI RESET 0, LCD RESET 0
	Delay(50);

	Set_POWER(1,1,0,1);//1.8V ON, 2.8V ON, 5V OFF, BL ON
	Delay(50);

	//Set_BOOST(5.70, 5.70, 0x81, 50);//VDD, VEE, OFF:VDD->VEE, 10ms
	//Delay(50);

	Set_POWER(1,0,0,1);//1.8V ON, 2.8V OFF, 5V OFF, BL ON
	Delay(100);
	Set_POWER(0,0,0,0);//1.8V OFF, 2.8V OFF, 5V OFF, BL OFF

}

/**************************************************/		
// Read function (Option)		
/**************************************************/ 
//
void ReadOperation()
{
	//Clean memory: BUFFER	
	memset(0);//BUFFER size: 8 Bytes

	//Read value to BUFFER
	DCS_Short_Read_NP(0xDA, 1, BUFFER+0);
	DCS_Short_Read_NP(0xDB, 1, BUFFER+1);
	DCS_Short_Read_NP(0xDC, 1, BUFFER+2);

}


void main()
{

	//Delay(100);
	Set_POWER(1,0,0,0);//1.8V ON, 2.8V OFF, 5V OFF, BL OFF
	Delay(500);

	Set_POWER(1,1,1,0);//1.8V ON, 2.8V ON, 5V ON, BL OFF
	Delay(500);

	//Set_BOOST(5.40,5.40,0x01,50);
	//Delay(50);

	Set_RESET(0,0);//MIPI RESET 1, LCD RESET 0
	Delay(200);
	Set_RESET(1,1);//MIPI RESET 1, LCD RESET 1
	Delay(200);

	SSD_LANE(4,0);
/**************************************************/		
//INX8_T2+HX8394D
//LCDD (Peripheral) Setting	
/**************************************************/	



DCS_Long_Write_3P(0xFF,0x98,0x81,0x03);

DCS_Long_Write_3P(0xFF,0x98,0x81,0x03);

DCS_Short_Write_1P(0x01,0x00);
DCS_Short_Write_1P(0x02,0x00);
DCS_Short_Write_1P(0x03,0x53);    
DCS_Short_Write_1P(0x04,0x53);    
DCS_Short_Write_1P(0x05,0x13);
DCS_Short_Write_1P(0x06,0x04);
DCS_Short_Write_1P(0x07,0x02);
DCS_Short_Write_1P(0x08,0x02);
DCS_Short_Write_1P(0x09,0x00);
DCS_Short_Write_1P(0x0a,0x00);
DCS_Short_Write_1P(0x0b,0x00);
DCS_Short_Write_1P(0x0c,0x00);
DCS_Short_Write_1P(0x0d,0x00);
DCS_Short_Write_1P(0x0e,0x00);
DCS_Short_Write_1P(0x0f,0x00);
DCS_Short_Write_1P(0x10,0x00);
DCS_Short_Write_1P(0x11,0x00);
DCS_Short_Write_1P(0x12,0x00);
DCS_Short_Write_1P(0x13,0x00);
DCS_Short_Write_1P(0x14,0x00);
DCS_Short_Write_1P(0x15,0x00);
DCS_Short_Write_1P(0x16,0x00);
DCS_Short_Write_1P(0x17,0x00);
DCS_Short_Write_1P(0x18,0x00);
DCS_Short_Write_1P(0x19,0x00);
DCS_Short_Write_1P(0x1a,0x00);
DCS_Short_Write_1P(0x1b,0x00);
DCS_Short_Write_1P(0x1c,0x00);
DCS_Short_Write_1P(0x1d,0x00);
DCS_Short_Write_1P(0x1e,0xc0);
DCS_Short_Write_1P(0x1f,0x00);
DCS_Short_Write_1P(0x20,0x02);
DCS_Short_Write_1P(0x21,0x09);
DCS_Short_Write_1P(0x22,0x00);
DCS_Short_Write_1P(0x23,0x00);
DCS_Short_Write_1P(0x24,0x00);
DCS_Short_Write_1P(0x25,0x00);
DCS_Short_Write_1P(0x26,0x00);
DCS_Short_Write_1P(0x27,0x00);
DCS_Short_Write_1P(0x28,0x55);
DCS_Short_Write_1P(0x29,0x03);
DCS_Short_Write_1P(0x2a,0x00);
DCS_Short_Write_1P(0x2b,0x00);
DCS_Short_Write_1P(0x2c,0x00);
DCS_Short_Write_1P(0x2d,0x00);
DCS_Short_Write_1P(0x2e,0x00);
DCS_Short_Write_1P(0x2f,0x00);
DCS_Short_Write_1P(0x30,0x00);
DCS_Short_Write_1P(0x31,0x00);
DCS_Short_Write_1P(0x32,0x00);
DCS_Short_Write_1P(0x33,0x00);
DCS_Short_Write_1P(0x34,0x00);
DCS_Short_Write_1P(0x35,0x00);
DCS_Short_Write_1P(0x36,0x00);
DCS_Short_Write_1P(0x37,0x00);
DCS_Short_Write_1P(0x38,0x3C);
DCS_Short_Write_1P(0x39,0x00);
DCS_Short_Write_1P(0x3a,0x00);
DCS_Short_Write_1P(0x3b,0x00);
DCS_Short_Write_1P(0x3c,0x00);
DCS_Short_Write_1P(0x3d,0x00);
DCS_Short_Write_1P(0x3e,0x00);
DCS_Short_Write_1P(0x3f,0x00);
DCS_Short_Write_1P(0x40,0x00);
DCS_Short_Write_1P(0x41,0x00);
DCS_Short_Write_1P(0x42,0x00);
DCS_Short_Write_1P(0x43,0x00);
DCS_Short_Write_1P(0x44,0x00);
DCS_Short_Write_1P(0x45,0x00);

DCS_Short_Write_1P(0x50,0x01);
DCS_Short_Write_1P(0x51,0x23);
DCS_Short_Write_1P(0x52,0x45);
DCS_Short_Write_1P(0x53,0x67);
DCS_Short_Write_1P(0x54,0x89);
DCS_Short_Write_1P(0x55,0xab);
DCS_Short_Write_1P(0x56,0x01);
DCS_Short_Write_1P(0x57,0x23);
DCS_Short_Write_1P(0x58,0x45);
DCS_Short_Write_1P(0x59,0x67);
DCS_Short_Write_1P(0x5a,0x89);
DCS_Short_Write_1P(0x5b,0xab);
DCS_Short_Write_1P(0x5c,0xcd);
DCS_Short_Write_1P(0x5d,0xef);

DCS_Short_Write_1P(0x5e,0x01);
DCS_Short_Write_1P(0x5f,0x0A);     //FW_CGOUT_L[1] RESE_ODD
DCS_Short_Write_1P(0x60,0x02);     //FW_CGOUT_L[2] VSSG_ODD
DCS_Short_Write_1P(0x61,0x02);     //FW_CGOUT_L[3] VSSG_ODD
DCS_Short_Write_1P(0x62,0x08);     //FW_CGOUT_L[4] STV2_ODD
DCS_Short_Write_1P(0x63,0x15);    //FW_CGOUT_L[5] VDD2_ODD
DCS_Short_Write_1P(0x64,0x14);     //FW_CGOUT_L[6] VDD1_ODD
DCS_Short_Write_1P(0x65,0x02);     //FW_CGOUT_L[7]
DCS_Short_Write_1P(0x66,0x11);     //FW_CGOUT_L[8] CK11
DCS_Short_Write_1P(0x67,0x10);     //FW_CGOUT_L[9] CK9
DCS_Short_Write_1P(0x68,0x02);     //FW_CGOUT_L[10]
DCS_Short_Write_1P(0x69,0x0F);     //FW_CGOUT_L[11] CK7
DCS_Short_Write_1P(0x6a,0x0E);     //FW_CGOUT_L[12] CK5
DCS_Short_Write_1P(0x6b,0x02);     //FW_CGOUT_L[13]   
DCS_Short_Write_1P(0x6c,0x0D);     //FW_CGOUT_L[14] CK3  
DCS_Short_Write_1P(0x6d,0x0C);     //FW_CGOUT_L[15] CK1  
DCS_Short_Write_1P(0x6e,0x06);     //FW_CGOUT_L[16] STV1_ODD  
DCS_Short_Write_1P(0x6f,0x02);     //FW_CGOUT_L[17]   
DCS_Short_Write_1P(0x70,0x02);     //FW_CGOUT_L[18]   
DCS_Short_Write_1P(0x71,0x02);     //FW_CGOUT_L[19]   
DCS_Short_Write_1P(0x72,0x02);     //FW_CGOUT_L[20]   
DCS_Short_Write_1P(0x73,0x02);     //FW_CGOUT_L[21]   
DCS_Short_Write_1P(0x74,0x02);     //FW_CGOUT_L[22] 
  
DCS_Short_Write_1P(0x75,0x0A);     //BW_CGOUT_L[1]   RESE_ODD 
DCS_Short_Write_1P(0x76,0x02);     //BW_CGOUT_L[2]   VSSG_ODD 
DCS_Short_Write_1P(0x77,0x02);     //BW_CGOUT_L[3]   VSSG_ODD  
DCS_Short_Write_1P(0x78,0x06);     //BW_CGOUT_L[4]   STV2_ODD 
DCS_Short_Write_1P(0x79,0x15);     //BW_CGOUT_L[5]   VDD2_ODD 
DCS_Short_Write_1P(0x7a,0x14);     //BW_CGOUT_L[6]   VDD1_ODD 
DCS_Short_Write_1P(0x7b,0x02);     //BW_CGOUT_L[7]    
DCS_Short_Write_1P(0x7c,0x10);     //BW_CGOUT_L[8]   CK11 
DCS_Short_Write_1P(0x7d,0x11);     //BW_CGOUT_L[9]   CK9 
DCS_Short_Write_1P(0x7e,0x02);     //BW_CGOUT_L[10]   
DCS_Short_Write_1P(0x7f,0x0C);     //BW_CGOUT_L[11]  CK7
DCS_Short_Write_1P(0x80,0x0D);     //BW_CGOUT_L[12]  CK5 
DCS_Short_Write_1P(0x81,0x02);     //BW_CGOUT_L[13]   
DCS_Short_Write_1P(0x82,0x0E);     //BW_CGOUT_L[14]  CK3 
DCS_Short_Write_1P(0x83,0x0F);     //BW_CGOUT_L[15]  CK1 
DCS_Short_Write_1P(0x84,0x08);     //BW_CGOUT_L[16]  STV1_ODD 
DCS_Short_Write_1P(0x85,0x02);     //BW_CGOUT_L[17]   
DCS_Short_Write_1P(0x86,0x02);     //BW_CGOUT_L[18]   
DCS_Short_Write_1P(0x87,0x02);     //BW_CGOUT_L[19]   
DCS_Short_Write_1P(0x88,0x02);     //BW_CGOUT_L[20]   
DCS_Short_Write_1P(0x89,0x02);     //BW_CGOUT_L[21]   
DCS_Short_Write_1P(0x8A,0x02);     //BW_CGOUT_L[22]   


DCS_Long_Write_3P(0xFF,0x98,0x81,0x04);
DCS_Short_Write_1P(0x3B,0xC0);     // ILI4003D sel 
DCS_Short_Write_1P(0x6C,0x15);
DCS_Short_Write_1P(0x6E,0x30);    //VGH 16V
DCS_Short_Write_1P(0x6F,0x55);     //Pump ratio VGH=VSPX4 VGL=VSNX4
DCS_Short_Write_1P(0x3A,0x24);
DCS_Short_Write_1P(0x8D,0x1F);
DCS_Short_Write_1P(0x87,0xBA);
DCS_Short_Write_1P(0x26,0x76);
DCS_Short_Write_1P(0xB2,0xD1);
DCS_Short_Write_1P(0xB5,0x07);
DCS_Short_Write_1P(0x35,0x1F);
DCS_Short_Write_1P(0x88,0x0B);
DCS_Short_Write_1P(0x21,0x30);




DCS_Long_Write_3P(0xFF,0x98,0x81,0x01);
DCS_Short_Write_1P(0x22,0x0A);
DCS_Short_Write_1P(0x31,0x09);
DCS_Short_Write_1P(0x40,0x33);
DCS_Short_Write_1P(0x53,0x37);
DCS_Short_Write_1P(0x55,0x88);
DCS_Short_Write_1P(0x50,0x95);
DCS_Short_Write_1P(0x51,0x95);
DCS_Short_Write_1P(0x60,0x30);

DCS_Short_Write_1P(0xA0,0x0F);        //VP255Gamma P
DCS_Short_Write_1P(0xA1,0x17);               //VP251
DCS_Short_Write_1P(0xA2,0x22);               //VP247
DCS_Short_Write_1P(0xA3,0x19);              //VP243
DCS_Short_Write_1P(0xA4,0x15);               //VP239
DCS_Short_Write_1P(0xA5,0x28);               //VP231
DCS_Short_Write_1P(0xA6,0x1C);              //VP219
DCS_Short_Write_1P(0xA7,0x1C);               //VP203
DCS_Short_Write_1P(0xA8,0x78);               //VP175
DCS_Short_Write_1P(0xA9,0x1C);               //VP144
DCS_Short_Write_1P(0xAA,0x28);               //VP111
DCS_Short_Write_1P(0xAB,0x69);               //VP80
DCS_Short_Write_1P(0xAC,0x1A);               //VP52
DCS_Short_Write_1P(0xAD,0x19);               //VP36
DCS_Short_Write_1P(0xAE,0x4B);               //VP24
DCS_Short_Write_1P(0xAF,0x22);               //VP16
DCS_Short_Write_1P(0xB0,0x2A);               //VP12
DCS_Short_Write_1P(0xB1,0x4B);               //VP8
DCS_Short_Write_1P(0xB2,0x6B);               //VP4
DCS_Short_Write_1P(0xB3,0x3F);               //VP0

DCS_Short_Write_1P(0xC0,0x01);         //VN255 GAMMA N
DCS_Short_Write_1P(0xC1,0x17);               //VN251
DCS_Short_Write_1P(0xC2,0x22);               //VN247
DCS_Short_Write_1P(0xC3,0x19);              //VN243
DCS_Short_Write_1P(0xC4,0x15);               //VN239
DCS_Short_Write_1P(0xC5,0x28);               //VN231
DCS_Short_Write_1P(0xC6,0x1C);               //VN219
DCS_Short_Write_1P(0xC7,0x1D);               //VN203
DCS_Short_Write_1P(0xC8,0x78);               //VN175
DCS_Short_Write_1P(0xC9,0x1C);               //VN144
DCS_Short_Write_1P(0xCA,0x28);               //VN111
DCS_Short_Write_1P(0xCB,0x69);               //VN80
DCS_Short_Write_1P(0xCC,0x1A);               //VN52
DCS_Short_Write_1P(0xCD,0x19);               //VN36
DCS_Short_Write_1P(0xCE,0x4B);               //VN24
DCS_Short_Write_1P(0xCF,0x22);               //VN16
DCS_Short_Write_1P(0xD0,0x2A);               //VN12
DCS_Short_Write_1P(0xD1,0x4B);               //VN8
DCS_Short_Write_1P(0xD2,0x6B);               //VN4
DCS_Short_Write_1P(0xD3,0x3F);               //VN0

DCS_Long_Write_3P(0xFF,0x98,0x81,0x00);
DCS_Short_Write_NP(0x35);               //TE OUT
DCS_Short_Write_NP(0x11);        //sleep out
Delay(120);
DCS_Short_Write_NP(0x29);        //display on
Delay(20);

  
SSD_MODE(0, 1);

	//Tips:	SSD_MODE([0], [1])
	//		[0]	Video Mode:	0 - Non burst mode with sync pulses
	//						1 - Non burst mode with sync events
	//						2 - Burst mode
	//						3 - Command mode
	//		[1]	HS Mode:		0 - No operation
	//						1 - Enable HS mode
}
 



