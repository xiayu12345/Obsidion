
/* Copyright Statement:
 *
 * This software/firmware and related documentation ("MediaTek Software") are
 * protected under relevant copyright laws. The information contained herein
 * is confidential and proprietary to MediaTek Inc. and/or its licensors.
 * Without the prior written permission of MediaTek inc. and/or its licensors,
 * any reproduction, modification, use or disclosure of MediaTek Software,
 * and information contained herein, in whole or in part, shall be strictly prohibited.
 */
/* MediaTek Inc. (C) 2010. All rights reserved.
 *
 * BY OPENING THIS FILE, RECEIVER HEREBY UNEQUIVOCALLY ACKNOWLEDGES AND AGREES
 * THAT THE SOFTWARE/FIRMWARE AND ITS DOCUMENTATIONS ("MEDIATEK SOFTWARE")
 * RECEIVED FROM MEDIATEK AND/OR ITS REPRESENTATIVES ARE PROVIDED TO RECEIVER ON
 * AN "AS-IS" BASIS ONLY. MEDIATEK EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NONINFRINGEMENT.
 * NEITHER DOES MEDIATEK PROVIDE ANY WARRANTY WHATSOEVER WITH RESPECT TO THE
 * SOFTWARE OF ANY THIRD PARTY WHICH MAY BE USED BY, INCORPORATED IN, OR
 * SUPPLIED WITH THE MEDIATEK SOFTWARE, AND RECEIVER AGREES TO LOOK ONLY TO SUCH
 * THIRD PARTY FOR ANY WARRANTY CLAIM RELATING THERETO. RECEIVER EXPRESSLY ACKNOWLEDGES
 * THAT IT IS RECEIVER'S SOLE RESPONSIBILITY TO OBTAIN FROM ANY THIRD PARTY ALL PROPER LICENSES
 * CONTAINED IN MEDIATEK SOFTWARE. MEDIATEK SHALL ALSO NOT BE RESPONSIBLE FOR ANY MEDIATEK
 * SOFTWARE RELEASES MADE TO RECEIVER'S SPECIFICATION OR TO CONFORM TO A PARTICULAR
 * STANDARD OR OPEN FORUM. RECEIVER'S SOLE AND EXCLUSIVE REMEDY AND MEDIATEK'S ENTIRE AND
 * CUMULATIVE LIABILITY WITH RESPECT TO THE MEDIATEK SOFTWARE RELEASED HEREUNDER WILL BE,
 * AT MEDIATEK'S OPTION, TO REVISE OR REPLACE THE MEDIATEK SOFTWARE AT ISSUE,
 * OR REFUND ANY SOFTWARE LICENSE FEES OR SERVICE CHARGE PAID BY RECEIVER TO
 * MEDIATEK FOR SUCH MEDIATEK SOFTWARE AT ISSUE.
 *
 * The following software/firmware and/or related documentation ("MediaTek Software")
 * have been modified by MediaTek Inc. All revisions are subject to any receiver's
 * applicable license agreements with MediaTek Inc.
 */

/*****************************************************************************
*  Copyright Statement:
*  --------------------
*  This software is protected by Copyright and the information contained
*  herein is confidential. The software may not be copied and the information
*  contained herein may not be used or disclosed except with the written
*  permission of MediaTek Inc. (C) 2008
*
*  BY OPENING THIS FILE, BUYER HEREBY UNEQUIVOCALLY ACKNOWLEDGES AND AGREES
*  THAT THE SOFTWARE/FIRMWARE AND ITS DOCUMENTATIONS ("MEDIATEK SOFTWARE")
*  RECEIVED FROM MEDIATEK AND/OR ITS REPRESENTATIVES ARE PROVIDED TO BUYER ON
*  AN "AS-IS" BASIS ONLY. MEDIATEK EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES,
*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
*  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NONINFRINGEMENT.
*  NEITHER DOES MEDIATEK PROVIDE ANY WARRANTY WHATSOEVER WITH RESPECT TO THE
*  SOFTWARE OF ANY THIRD PARTY WHICH MAY BE USED BY, INCORPORATED IN, OR
*  SUPPLIED WITH THE MEDIATEK SOFTWARE, AND BUYER AGREES TO LOOK ONLY TO SUCH
*  THIRD PARTY FOR ANY WARRANTY CLAIM RELATING THERETO. MEDIATEK SHALL ALSO
*  NOT BE RESPONSIBLE FOR ANY MEDIATEK SOFTWARE RELEASES MADE TO BUYER'S
*  SPECIFICATION OR TO CONFORM TO A PARTICULAR STANDARD OR OPEN FORUM.
*
*  BUYER'S SOLE AND EXCLUSIVE REMEDY AND MEDIATEK'S ENTIRE AND CUMULATIVE
*  LIABILITY WITH RESPECT TO THE MEDIATEK SOFTWARE RELEASED HEREUNDER WILL BE,
*  AT MEDIATEK'S OPTION, TO REVISE OR REPLACE THE MEDIATEK SOFTWARE AT ISSUE,
*  OR REFUND ANY SOFTWARE LICENSE FEES OR SERVICE CHARGE PAID BY BUYER TO
*  MEDIATEK FOR SUCH MEDIATEK SOFTWARE AT ISSUE.
*
*  THE TRANSACTION CONTEMPLATED HEREUNDER SHALL BE CONSTRUED IN ACCORDANCE
*  WITH THE LAWS OF THE STATE OF CALIFORNIA, USA, EXCLUDING ITS CONFLICT OF
*  LAWS PRINCIPLES.  ANY DISPUTES, CONTROVERSIES OR CLAIMS ARISING THEREOF AND
*  RELATED THERETO SHALL BE SETTLED BY ARBITRATION IN SAN FRANCISCO, CA, UNDER
*  THE RULES OF THE INTERNATIONAL CHAMBER OF COMMERCE (ICC).
*
*****************************************************************************/




#ifndef BUILD_LK
#include <linux/string.h>
#endif

#ifdef BUILD_LK
#include <platform/mt_gpio.h>
#include <platform/mt_pmic.h>
#else
#include <mach/mt_gpio.h>
#include <mach/mt_pm_ldo.h>
#include <mach/upmu_common.h>
#include <mach/upmu_hw.h>
#endif
#include "lcm_drv.h"

#if 1
	#ifdef BUILD_LK
	#define LOCAL_DEBUG(fmt,args...) 	printf("debug str in file:%s,func:%s"fmt,__FILE__,__func__,##args)
	#else
	#define LOCAL_DEBUG(fmt,args...) 	printk("debug str in file:%s,func:%s"fmt,__FILE__,__func__,##args)	
	#endif
#endif

#define HSYNC_PULSE_WIDTH 80 
#define HSYNC_BACK_PORCH  50
#define HSYNC_FRONT_PORCH 30
#define VSYNC_PULSE_WIDTH 7
#define VSYNC_BACK_PORCH  10
#define VSYNC_FRONT_PORCH 6



// ---------------------------------------------------------------------------
//  Local Constants
// ---------------------------------------------------------------------------
#if 0 //add by gxf 
	#define FRAME_WIDTH  (1280)
	#define FRAME_HEIGHT (800)
#else

	#define FRAME_WIDTH  (800)
	#define FRAME_HEIGHT (1280)

#endif 


#define LCM_DSI_CMD_MODE									0

#define GPIO_DISP_PWM     GPIO90 // GPIO57
#define GPIO_LCM_RST      GPIO112
#define GPIO_LCD_VDD_3_3     GPIO6 // GPIO113 
#define GPIO_LCM_PWR0_EN     0xff // GPIO57

#define GPIO_LCM_PWR1_EN     	GPIO118 // GPIO57
#define GPIO_PEW_ON      GPIO116

// ---------------------------------------------------------------------------
//  Local Variables
// ---------------------------------------------------------------------------
static LCM_UTIL_FUNCS lcm_util = {
    .set_gpio_out = NULL,
};

#define SET_RESET_PIN(v)    								(lcm_util.set_reset_pin((v)))

#define UDELAY(n) 											(lcm_util.udelay(n))
#define MDELAY(n) 											(lcm_util.mdelay(n))

// ---------------------------------------------------------------------------
//  Local Functions
// ---------------------------------------------------------------------------
#define dsi_set_cmdq_V2(cmd, count, ppara, force_update)    lcm_util.dsi_set_cmdq_V2(cmd, count, ppara, force_update)
#define dsi_set_cmdq(pdata, queue_size, force_update)		lcm_util.dsi_set_cmdq(pdata, queue_size, force_update)
#define wrtie_cmd(cmd)										lcm_util.dsi_write_cmd(cmd)
#define write_regs(addr, pdata, byte_nums)					lcm_util.dsi_write_regs(addr, pdata, byte_nums)
#define read_reg											lcm_util.dsi_read_reg()
#define read_reg_v2(cmd, buffer, buffer_size)               lcm_util.dsi_dcs_read_lcm_reg_v2(cmd, buffer, buffer_size)    
#define dsi_set_cmdq_V3(para_tbl,size,force_update)        lcm_util.dsi_set_cmdq_V3(para_tbl,size,force_update)
extern U32 pmic_config_interface (U32 RegNum, U32 val, U32 MASK, U32 SHIFT);//m++

static LCM_setting_table_V3 lcm_initialization_setting[] = {
#if 0
	//{0x15,0x00,1,{0x00}},//打开PAGE4  //
	//--------------------------------//
	{0x39,0xFF,3,{0x98,0x81,0x03}},//PAGE3
	{0x15,0x01,1,{0x00}},
	{0x15,0x02,1,{0x00}},


	{0x39,0xFF,3,{0x98,0x81,0x04}},//PAGE4
	//{0x15,0x00,1,{0x00}},//3L
	{0x15,0x3B,1,{0xC0}},     // ILI4003D sel 
	{0x15,0x6C,1,{0x15}},
	{0x15,0x6E,1,{0x30}},     //VGH 16V

	{0x39,0xFF,3,{0x98,0x81,0x00}},//PAGE0
	//{0x05,0x35,1,{0x00}},               //TE OUT
	{0x05,0x11,0,0x00},        //sleep out
	{REGFLAG_ESCAPE_ID,REGFLAG_DELAY_MS_V3, 120, {}},
	{0x05,0x29,0,0x00},        //display on
	{REGFLAG_ESCAPE_ID,REGFLAG_DELAY_MS_V3, 5, {}},

#else
	//-------------------------------------------------------------//

	{0x15,0x35,0x01,{0x00}},  // TE On
	{0x05,0x11,0x00,{}}, // Sleep Out          
	{REGFLAG_ESCAPE_ID,REGFLAG_DELAY_MS_V3, 120, {}},			//Delay,120
	{0x05,0x29,0x00,{}},  //  Display On 
	{REGFLAG_ESCAPE_ID,REGFLAG_DELAY_MS_V3, 20, {}},			//Delay,20


#endif
};

static void lcm_set_util_funcs(const LCM_UTIL_FUNCS *util)
{
    memcpy(&lcm_util, util, sizeof(LCM_UTIL_FUNCS));
}


static void lcm_get_params(LCM_PARAMS *params)
{

	memset(params, 0, sizeof(LCM_PARAMS));

	params->type   = LCM_TYPE_DSI;
	params->width  = FRAME_WIDTH;
	params->height = FRAME_HEIGHT;

	
	//params->dbi.te_mode 				= LCM_DBI_TE_MODE_VSYNC_ONLY;//LCM_DBI_TE_MODE_VSYNC_OR_HSYNC;//LCM_DBI_TE_MODE_DISABLED;//LCM_DBI_TE_MODE_VSYNC_ONLY;
	//params->dbi.te_edge_polarity		= LCM_POLARITY_FALLING;

	params->dsi.mode   = BURST_VDO_MODE;///SYNC_EVENT_VDO_MODE; //BURST_VDO_MODE;
	//params->dsi.mode   = SYNC_PULSE_VDO_MODE; 
//  params->active_width = 150;  // 129 mm
//  params->active_height = 94; // 160 mm
 
	// DSI
	/* Command mode setting */
	params->dsi.LANE_NUM				=  LCM_FOUR_LANE;//g LCM_FOUR_LANE;
	//The following defined the fomat for data coming from LCD engine.
	params->dsi.data_format.format		= LCM_DSI_FORMAT_RGB888; //LCM_DSI_FORMAT_RGB666;

	// Video mode setting		
	params->dsi.PS=LCM_PACKED_PS_24BIT_RGB888; //LCM_PACKED_PS_18BIT_RGB666;

	#if 1 //type
	params->dsi.vertical_sync_active				= 4;
    params->dsi.vertical_backporch					= 20;
    params->dsi.vertical_frontporch 				= 20;
    params->dsi.vertical_active_line				= FRAME_HEIGHT; 

    params->dsi.horizontal_sync_active				= 20;
    params->dsi.horizontal_backporch				= 20;
    params->dsi.horizontal_frontporch				= 40;
    params->dsi.horizontal_active_pixel 			= FRAME_WIDTH;
	
	params->dsi.PLL_CLOCK = 210;
	
	#endif 
	
}

extern void DSI_clk_HS_mode(unsigned char enter);

static void SSD_Single(unsigned int reg,unsigned int para)
{
	unsigned int data_array[16];
	unsigned int temp = (0x1500)|(para<<24)|(reg<<16);
	LOCAL_DEBUG("send temp val=0x%8x\n",temp );
	data_array[0]=temp ;
	dsi_set_cmdq(data_array,1,1);
}
static void SSD_CMD(unsigned int cmd)
{
	unsigned int data_array[16];
	unsigned int temp = (0x0500)|(cmd<<16);
	LOCAL_DEBUG("send temp val=0x%8x\n",temp );
	data_array[0]=temp ;
	dsi_set_cmdq(data_array,1,1);
}
static void SSD_Number(unsigned int cmd)
{
	unsigned int data_array[16];
	unsigned int temp = (0x0500)|(cmd<<16);
	LOCAL_DEBUG("send temp val=0x%8x\n",temp );
	data_array[0]=temp ;
	dsi_set_cmdq(data_array,1,1);
}

static void init_lcm_registers(void)
{


	SSD_Single(0xE0,0x00);
	SSD_Single(0xE1,0x93);
	SSD_Single(0xE2,0x65);
	SSD_Single(0xE3,0xF8);
	SSD_Single(0x80,0x03);
	SSD_Single(0xE0,0x01);
	SSD_Single(0x00,0x00);
	SSD_Single(0x01,0x3B);
	SSD_Single(0x0C,0x74);
	SSD_Single(0x17,0x00);
	SSD_Single(0x18,0xAF);
	SSD_Single(0x19,0x00);
	SSD_Single(0x1A,0x00);
	SSD_Single(0x1B,0xAF);
	SSD_Single(0x1C,0x00);
	SSD_Single(0x35,0x26);
	SSD_Single(0x37,0x09);
	SSD_Single(0x38,0x04);
	SSD_Single(0x39,0x00);
	SSD_Single(0x3A,0x01);
	SSD_Single(0x3C,0x78);
	SSD_Single(0x3D,0xFF);
	SSD_Single(0x3E,0xFF);
	SSD_Single(0x3F,0x7F);
	SSD_Single(0x40,0x06);
	SSD_Single(0x41,0xA0);
	SSD_Single(0x42,0x81);
	SSD_Single(0x43,0x14);
	SSD_Single(0x44,0x23);
	SSD_Single(0x45,0x28);
	SSD_Single(0x55,0x02);
	SSD_Single(0x57,0x69);
	SSD_Single(0x59,0x0A);
	SSD_Single(0x5A,0x2A);
	SSD_Single(0x5B,0x17);
	SSD_Single(0x5D,0x7F);
	SSD_Single(0x5E,0x6B);
	SSD_Single(0x5F,0x5C);
	SSD_Single(0x60,0x4F);
	SSD_Single(0x61,0x4D);
	SSD_Single(0x62,0x3F);
	SSD_Single(0x63,0x42);
	SSD_Single(0x64,0x2B);
	SSD_Single(0x65,0x44);
	SSD_Single(0x66,0x43);
	SSD_Single(0x67,0x43);
	SSD_Single(0x68,0x63);
	SSD_Single(0x69,0x52);
	SSD_Single(0x6A,0x5A);
	SSD_Single(0x6B,0x4F);
	SSD_Single(0x6C,0x4E);
	SSD_Single(0x6D,0x20);
	SSD_Single(0x6E,0x0F);
	SSD_Single(0x6F,0x00);
	SSD_Single(0x70,0x7F);
	SSD_Single(0x71,0x6B);
	SSD_Single(0x72,0x5C);
	SSD_Single(0x73,0x4F);
	SSD_Single(0x74,0x4D);
	SSD_Single(0x75,0x3F);
	SSD_Single(0x76,0x42);
	SSD_Single(0x77,0x2B);
	SSD_Single(0x78,0x44);
	SSD_Single(0x79,0x43);
	SSD_Single(0x7A,0x43);
	SSD_Single(0x7B,0x63);
	SSD_Single(0x7C,0x52);
	SSD_Single(0x7D,0x5A);
	SSD_Single(0x7E,0x4F);
	SSD_Single(0x7F,0x4E);
	SSD_Single(0x80,0x20);
	SSD_Single(0x81,0x0F);
	SSD_Single(0x82,0x00);
	SSD_Single(0xE0,0x02);
	SSD_Single(0x00,0x02);
	SSD_Single(0x01,0x02);
	SSD_Single(0x02,0x00);
	SSD_Single(0x03,0x00);
	SSD_Single(0x04,0x1E);
	SSD_Single(0x05,0x1E);
	SSD_Single(0x06,0x1F);
	SSD_Single(0x07,0x1F);
	SSD_Single(0x08,0x1F);
	SSD_Single(0x09,0x17);
	SSD_Single(0x0A,0x17);
	SSD_Single(0x0B,0x37);
	SSD_Single(0x0C,0x37);
	SSD_Single(0x0D,0x47);
	SSD_Single(0x0E,0x47);
	SSD_Single(0x0F,0x45);
	SSD_Single(0x10,0x45);
	SSD_Single(0x11,0x4B);
	SSD_Single(0x12,0x4B);
	SSD_Single(0x13,0x49);
	SSD_Single(0x14,0x49);
	SSD_Single(0x15,0x1F);
	SSD_Single(0x16,0x01);
	SSD_Single(0x17,0x01);
	SSD_Single(0x18,0x00);
	SSD_Single(0x19,0x00);
	SSD_Single(0x1A,0x1E);
	SSD_Single(0x1B,0x1E);
	SSD_Single(0x1C,0x1F);
	SSD_Single(0x1D,0x1F);
	SSD_Single(0x1E,0x1F);
	SSD_Single(0x1F,0x17);
	SSD_Single(0x20,0x17);
	SSD_Single(0x21,0x37);
	SSD_Single(0x22,0x37);
	SSD_Single(0x23,0x46);
	SSD_Single(0x24,0x46);
	SSD_Single(0x25,0x44);
	SSD_Single(0x26,0x44);
	SSD_Single(0x27,0x4A);
	SSD_Single(0x28,0x4A);
	SSD_Single(0x29,0x48);
	SSD_Single(0x2A,0x48);
	SSD_Single(0x2B,0x1F);
	SSD_Single(0x2C,0x01);
	SSD_Single(0x2D,0x01);
	SSD_Single(0x2E,0x00);
	SSD_Single(0x2F,0x00);
	SSD_Single(0x30,0x1F);
	SSD_Single(0x31,0x1F);
	SSD_Single(0x32,0x1E);
	SSD_Single(0x33,0x1E);
	SSD_Single(0x34,0x1F);
	SSD_Single(0x35,0x17);
	SSD_Single(0x36,0x17);
	SSD_Single(0x37,0x37);
	SSD_Single(0x38,0x37);
	SSD_Single(0x39,0x08);
	SSD_Single(0x3A,0x08);
	SSD_Single(0x3B,0x0A);
	SSD_Single(0x3C,0x0A);
	SSD_Single(0x3D,0x04);
	SSD_Single(0x3E,0x04);
	SSD_Single(0x3F,0x06);
	SSD_Single(0x40,0x06);
	SSD_Single(0x41,0x1F);
	SSD_Single(0x42,0x02);
	SSD_Single(0x43,0x02);
	SSD_Single(0x44,0x00);
	SSD_Single(0x45,0x00);
	SSD_Single(0x46,0x1F);
	SSD_Single(0x47,0x1F);
	SSD_Single(0x48,0x1E);
	SSD_Single(0x49,0x1E);
	SSD_Single(0x4A,0x1F);
	SSD_Single(0x4B,0x17);
	SSD_Single(0x4C,0x17);
	SSD_Single(0x4D,0x37);
	SSD_Single(0x4E,0x37);
	SSD_Single(0x4F,0x09);
	SSD_Single(0x50,0x09);
	SSD_Single(0x51,0x0B);
	SSD_Single(0x52,0x0B);
	SSD_Single(0x53,0x05);
	SSD_Single(0x54,0x05);
	SSD_Single(0x55,0x07);
	SSD_Single(0x56,0x07);
	SSD_Single(0x57,0x1F);
	SSD_Single(0x58,0x40);
	SSD_Single(0x5B,0x30);
	SSD_Single(0x5C,0x16);
	SSD_Single(0x5D,0x34);
	SSD_Single(0x5E,0x05);
	SSD_Single(0x5F,0x02);
	SSD_Single(0x63,0x00);
	SSD_Single(0x64,0x6A);
	SSD_Single(0x67,0x73);
	SSD_Single(0x68,0x1D);
	SSD_Single(0x69,0x08);
	SSD_Single(0x6A,0x6A);
	SSD_Single(0x6B,0x08);
	SSD_Single(0x6C,0x00);
	SSD_Single(0x6D,0x00);
	SSD_Single(0x6E,0x00);
	SSD_Single(0x6F,0x88);
	SSD_Single(0x75,0xFF);
	SSD_Single(0x77,0xDD);
	SSD_Single(0x78,0x3F);
	SSD_Single(0x79,0x15);
	SSD_Single(0x7A,0x17);
	SSD_Single(0x7D,0x14);
	SSD_Single(0x7E,0x82);
	SSD_Single(0xE0,0x04);
	SSD_Single(0x00,0x0E);
	SSD_Single(0x02,0xB3);
	SSD_Single(0x09,0x61);
	SSD_Single(0x0E,0x48);
	SSD_Single(0xE0,0x00);
	SSD_Single(0xE6,0x02);
	SSD_Single(0xE7,0x0C);
	SSD_Single(0x11,0x00);


	SSD_CMD(0x11);  	// SLPOUT
	MDELAY(120);
	
	SSD_CMD(0x29);  	// DSPON
	MDELAY(5);
}
//cjq add 

static void lcd_power_1v8_en(unsigned char enabled)
{
	if(enabled)
	{
		printf("lcd_power_1v8_en open\n");
#ifdef BUILD_LK
        /* VGP3_PMU 3V */
        pmic_config_interface(DIGLDO_CON30, 0x3, PMIC_RG_VGP3_VOSEL_MASK, PMIC_RG_VGP3_VOSEL_SHIFT);
        pmic_config_interface(DIGLDO_CON9, 0x1, PMIC_RG_VGP3_EN_MASK, PMIC_RG_VGP3_EN_SHIFT);
#else
        //upmu_set_rg_vgp3_vosel(0x7);
        //upmu_set_rg_vgp3_en(0x1);
		upmu_set_rg_vgp3_vosel(3);
		upmu_set_rg_vgp3_en(1);
#endif	
	}
	else
	{
		printf("lcd_power_1v8_en close\n");
#ifdef BUILD_LK
        /* VGP3_PMU 3V */
        pmic_config_interface(DIGLDO_CON30, 0x0, PMIC_RG_VGP3_EN_MASK, PMIC_RG_VGP3_EN_SHIFT);
        pmic_config_interface(DIGLDO_CON9, 0x0, PMIC_RG_VGP3_VOSEL_MASK, PMIC_RG_VGP3_VOSEL_SHIFT); 
#else
        upmu_set_rg_vgp3_en(0);        
        upmu_set_rg_vgp3_vosel(0);
#endif

	}

}

static void lcd_power_3v3_en(unsigned char enabled)
{
#ifdef BUILD_LK
    printf("%s, LK \n", __func__);
#else
    printk("%s, kernel", __func__);
#endif		

	if(enabled)
	{

#ifdef BUILD_LK
        /* VGP1_PMU 3.3V */

        pmic_config_interface(DIGLDO_CON28, 0x7, PMIC_RG_VGP1_VOSEL_MASK, PMIC_RG_VGP1_VOSEL_SHIFT);
        pmic_config_interface(DIGLDO_CON7, 0x1, PMIC_RG_VGP1_EN_MASK, PMIC_RG_VGP1_EN_SHIFT);		
		
#else
        upmu_set_rg_vgp1_vosel(0x7);
        upmu_set_rg_vgp1_en(0x1);		
#endif	
	}
	else
	{
#ifdef BUILD_LK
         /* VGP1_PMU 3.3V */
		 
		pmic_config_interface(DIGLDO_CON7, 0x0, PMIC_RG_VGP1_EN_MASK, PMIC_RG_VGP1_EN_SHIFT);
        pmic_config_interface(DIGLDO_CON28, 0x0, PMIC_RG_VGP1_VOSEL_MASK, PMIC_RG_VGP1_VOSEL_SHIFT);
       		
#else
        upmu_set_rg_vgp1_en(0x0);        
        upmu_set_rg_vgp1_vosel(0x0);		
#endif

	}

}


static void lcd_power_2v8_en(unsigned char enabled)
{
	if(enabled)
	{
		printf("lcd_power_2v8_en open\n");
		mt_set_gpio_mode(GPIO_LCM_PWR1_EN, GPIO_MODE_00);
		mt_set_gpio_dir(GPIO_LCM_PWR1_EN, GPIO_DIR_OUT);
		mt_set_gpio_out(GPIO_LCM_PWR1_EN, GPIO_OUT_ONE);
	}
	else
	{
		printf("lcd_power_2v8_en close\n");
		mt_set_gpio_mode(GPIO_LCM_PWR1_EN, GPIO_MODE_00);
		mt_set_gpio_dir(GPIO_LCM_PWR1_EN, GPIO_DIR_OUT);
		mt_set_gpio_out(GPIO_LCM_PWR1_EN, GPIO_OUT_ZERO); 
	}

}

static void lcd_reset(unsigned char enabled)
{

	
    if (enabled)
    {
		printf("lcd_reset open\n");
        mt_set_gpio_mode(GPIO_LCM_RST, GPIO_MODE_00);
        mt_set_gpio_dir(GPIO_LCM_RST, GPIO_DIR_OUT);     
        mt_set_gpio_out(GPIO_LCM_RST, GPIO_OUT_ONE);

		mt_set_gpio_mode(GPIO_PEW_ON, GPIO_MODE_00);
        mt_set_gpio_dir(GPIO_PEW_ON, GPIO_DIR_OUT);     
        mt_set_gpio_out(GPIO_PEW_ON, GPIO_OUT_ONE);
        
    }
    else
    {
		printf("lcd_reset close\n");
        mt_set_gpio_mode(GPIO_LCM_RST, GPIO_MODE_00);
        mt_set_gpio_dir(GPIO_LCM_RST, GPIO_DIR_OUT);       
        mt_set_gpio_out(GPIO_LCM_RST, GPIO_OUT_ZERO);
    	
    }
}

static void lcm_init(void)
{
	printf("lcm_init start\n");
		lcd_reset(0);
		MDELAY(20);
		lcd_power_1v8_en(1);
		MDELAY(10);
		lcd_power_3v3_en(1);
		MDELAY(10);
		lcd_power_2v8_en(1);
		MDELAY(10);
		lcd_reset(1);
		MDELAY(100);

	
	#if 1
	init_lcm_registers();
	#else
    dsi_set_cmdq_V3(lcm_initialization_setting, sizeof(lcm_initialization_setting) / sizeof(LCM_setting_table_V3), 1);
	#endif
	/*
	MDELAY(120);
	mt_set_gpio_mode(GPIO110, GPIO_MODE_00);
	mt_set_gpio_dir(GPIO110, GPIO_DIR_OUT);     
	mt_set_gpio_out(GPIO110, GPIO_OUT_ONE);
	mt_set_gpio_mode(GPIO11, GPIO_MODE_00);
	mt_set_gpio_mode(GPIO11, GPIO_MODE_00);
	mt_set_gpio_dir(GPIO11, GPIO_DIR_OUT);     
	mt_set_gpio_out(GPIO11, GPIO_OUT_ONE);
	*/
}


static void lcm_suspend(void)
{
	lcd_reset(0);
    MDELAY(10);
    lcd_power_2v8_en(0);
    MDELAY(20);
    lcd_power_1v8_en(0);
     MDELAY(20);
	 lcd_power_3v3_en(0);
}


static void lcm_resume(void)
{
	lcm_init();

}

LCM_DRIVER JD9365DA_H3_BOE_241211_lcm_drv = 
{
    .name           = "JD9365DA_H3_BOE_241211_lcm_drv",
    .set_util_funcs = lcm_set_util_funcs,
    .get_params     = lcm_get_params,
    .init           = lcm_init,
    .suspend        = lcm_suspend,
    .resume         = lcm_resume,
    //.compare_id    = lcm_compare_id,
};



