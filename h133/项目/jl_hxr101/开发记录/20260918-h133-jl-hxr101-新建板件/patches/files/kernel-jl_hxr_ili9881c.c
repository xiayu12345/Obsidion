/*
 * HXR10106B-28 LB 10.1" 800x1280 MIPI panel (ILI9881C-0H).
 * Init copied from zs101_ili9881c (群创 ILI9881C-0D)；
 * 板件 p1_nor_JL_HXR101 / p1_emmc_JL_HXR101。
 * Board: p1_nor_JL_HXR101 / p1_emmc_JL_HXR101; lcd_gpio_0=RESET(PB11); lcd_pwm_ch=0(PB12/LCD-PWM).
 */
#include "jl_hxr_ili9881c.h"
#include "lcd_source.h"

static void LCD_power_on(u32 sel);
static void LCD_power_off(u32 sel);
static void LCD_bl_open(u32 sel);
static void LCD_bl_close(u32 sel);
static void LCD_panel_init(u32 sel);
static void LCD_panel_exit(u32 sel);

/* lcd_gpio_0 = RESET */
#define panel_reset(sel, val) sunxi_lcd_gpio_set_value(sel, 0, val)

#define REGFLAG_DELAY 0xFC
#define REGFLAG_END_OF_TABLE 0xFD

struct LCM_setting_table {
	u8 cmd;
	u32 count;
	u8 para_list[32];
};

static void LCD_cfg_panel_info(struct panel_extend_para *info)
{
	u32 i = 0, j = 0;
	u32 items;
	u8 lcd_gamma_tbl[][2] = {
		{0, 0}, {15, 15}, {30, 30}, {45, 45}, {60, 60}, {75, 75},
		{90, 90}, {105, 105}, {120, 120}, {135, 135}, {150, 150},
		{165, 165}, {180, 180}, {195, 195}, {210, 210}, {225, 225},
		{240, 240}, {255, 255},
	};
	u32 lcd_cmap_tbl[2][3][4] = {
		{
			{LCD_CMAP_G0, LCD_CMAP_B1, LCD_CMAP_G2, LCD_CMAP_B3},
			{LCD_CMAP_B0, LCD_CMAP_R1, LCD_CMAP_B2, LCD_CMAP_R3},
			{LCD_CMAP_R0, LCD_CMAP_G1, LCD_CMAP_R2, LCD_CMAP_G3},
		},
		{
			{LCD_CMAP_B3, LCD_CMAP_G2, LCD_CMAP_B1, LCD_CMAP_G0},
			{LCD_CMAP_R3, LCD_CMAP_B2, LCD_CMAP_R1, LCD_CMAP_B0},
			{LCD_CMAP_G3, LCD_CMAP_R2, LCD_CMAP_G1, LCD_CMAP_R0},
		},
	};

	items = sizeof(lcd_gamma_tbl) / 2;
	for (i = 0; i < items - 1; i++) {
		u32 num = lcd_gamma_tbl[i + 1][0] - lcd_gamma_tbl[i][0];

		for (j = 0; j < num; j++) {
			u32 value = lcd_gamma_tbl[i][1] +
				((lcd_gamma_tbl[i + 1][1] - lcd_gamma_tbl[i][1]) * j) / num;
			info->lcd_gamma_tbl[lcd_gamma_tbl[i][0] + j] =
				(value << 16) + (value << 8) + value;
		}
	}
	info->lcd_gamma_tbl[255] =
		(lcd_gamma_tbl[items - 1][1] << 16) +
		(lcd_gamma_tbl[items - 1][1] << 8) +
		lcd_gamma_tbl[items - 1][1];
	memcpy(info->lcd_cmap_tbl, lcd_cmap_tbl, sizeof(lcd_cmap_tbl));
}

static s32 LCD_open_flow(u32 sel)
{
	LCD_OPEN_FUNC(sel, LCD_power_on, 10);
	LCD_OPEN_FUNC(sel, LCD_panel_init, 10);
	LCD_OPEN_FUNC(sel, sunxi_lcd_tcon_enable, 50);
	LCD_OPEN_FUNC(sel, LCD_bl_open, 0);
	return 0;
}

static s32 LCD_close_flow(u32 sel)
{
	LCD_CLOSE_FUNC(sel, LCD_bl_close, 0);
	LCD_CLOSE_FUNC(sel, sunxi_lcd_tcon_disable, 0);
	LCD_CLOSE_FUNC(sel, LCD_panel_exit, 200);
	LCD_CLOSE_FUNC(sel, LCD_power_off, 500);
	return 0;
}

/* vendor: LCD RST L 200ms → H 200ms；补成 H→L→H 脉冲后再发码 */
static void LCD_power_on(u32 sel)
{
	sunxi_lcd_pin_cfg(sel, 1);
	sunxi_lcd_delay_ms(50);
	panel_reset(sel, 1);
	sunxi_lcd_delay_ms(10);
	panel_reset(sel, 0);
	sunxi_lcd_delay_ms(20);
	panel_reset(sel, 1);
	sunxi_lcd_delay_ms(200);
}

static void LCD_power_off(u32 sel)
{
	sunxi_lcd_pin_cfg(sel, 0);
	sunxi_lcd_delay_ms(20);
	panel_reset(sel, 0);
	sunxi_lcd_delay_ms(5);
}

static void LCD_bl_open(u32 sel)
{
	sunxi_lcd_pwm_enable(sel);
}

static void LCD_bl_close(u32 sel)
{
	sunxi_lcd_pwm_disable(sel);
}

static struct LCM_setting_table lcm_initialization_setting[] = {
	{0xFF, 3, {0x98, 0x81, 0x03}},
	{0xFF, 3, {0x98, 0x81, 0x03}},
	{0x01, 1, {0x00}},
	{0x02, 1, {0x00}},
	{0x03, 1, {0x53}},
	{0x04, 1, {0x53}},
	{0x05, 1, {0x13}},
	{0x06, 1, {0x04}},
	{0x07, 1, {0x02}},
	{0x08, 1, {0x02}},
	{0x09, 1, {0x00}},
	{0x0A, 1, {0x00}},
	{0x0B, 1, {0x00}},
	{0x0C, 1, {0x00}},
	{0x0D, 1, {0x00}},
	{0x0E, 1, {0x00}},
	{0x0F, 1, {0x00}},
	{0x10, 1, {0x00}},
	{0x11, 1, {0x00}},
	{0x12, 1, {0x00}},
	{0x13, 1, {0x00}},
	{0x14, 1, {0x00}},
	{0x15, 1, {0x00}},
	{0x16, 1, {0x00}},
	{0x17, 1, {0x00}},
	{0x18, 1, {0x00}},
	{0x19, 1, {0x00}},
	{0x1A, 1, {0x00}},
	{0x1B, 1, {0x00}},
	{0x1C, 1, {0x00}},
	{0x1D, 1, {0x00}},
	{0x1E, 1, {0xC0}},
	{0x1F, 1, {0x00}},
	{0x20, 1, {0x02}},
	{0x21, 1, {0x09}},
	{0x22, 1, {0x00}},
	{0x23, 1, {0x00}},
	{0x24, 1, {0x00}},
	{0x25, 1, {0x00}},
	{0x26, 1, {0x00}},
	{0x27, 1, {0x00}},
	{0x28, 1, {0x55}},
	{0x29, 1, {0x03}},
	{0x2A, 1, {0x00}},
	{0x2B, 1, {0x00}},
	{0x2C, 1, {0x00}},
	{0x2D, 1, {0x00}},
	{0x2E, 1, {0x00}},
	{0x2F, 1, {0x00}},
	{0x30, 1, {0x00}},
	{0x31, 1, {0x00}},
	{0x32, 1, {0x00}},
	{0x33, 1, {0x00}},
	{0x34, 1, {0x00}},
	{0x35, 1, {0x00}},
	{0x36, 1, {0x00}},
	{0x37, 1, {0x00}},
	{0x38, 1, {0x3C}},
	{0x39, 1, {0x00}},
	{0x3A, 1, {0x00}},
	{0x3B, 1, {0x00}},
	{0x3C, 1, {0x00}},
	{0x3D, 1, {0x00}},
	{0x3E, 1, {0x00}},
	{0x3F, 1, {0x00}},
	{0x40, 1, {0x00}},
	{0x41, 1, {0x00}},
	{0x42, 1, {0x00}},
	{0x43, 1, {0x00}},
	{0x44, 1, {0x00}},
	{0x45, 1, {0x00}},
	{0x50, 1, {0x01}},
	{0x51, 1, {0x23}},
	{0x52, 1, {0x45}},
	{0x53, 1, {0x67}},
	{0x54, 1, {0x89}},
	{0x55, 1, {0xAB}},
	{0x56, 1, {0x01}},
	{0x57, 1, {0x23}},
	{0x58, 1, {0x45}},
	{0x59, 1, {0x67}},
	{0x5A, 1, {0x89}},
	{0x5B, 1, {0xAB}},
	{0x5C, 1, {0xCD}},
	{0x5D, 1, {0xEF}},
	{0x5E, 1, {0x01}},
	{0x5F, 1, {0x0A}},
	{0x60, 1, {0x02}},
	{0x61, 1, {0x02}},
	{0x62, 1, {0x08}},
	{0x63, 1, {0x15}},
	{0x64, 1, {0x14}},
	{0x65, 1, {0x02}},
	{0x66, 1, {0x11}},
	{0x67, 1, {0x10}},
	{0x68, 1, {0x02}},
	{0x69, 1, {0x0F}},
	{0x6A, 1, {0x0E}},
	{0x6B, 1, {0x02}},
	{0x6C, 1, {0x0D}},
	{0x6D, 1, {0x0C}},
	{0x6E, 1, {0x06}},
	{0x6F, 1, {0x02}},
	{0x70, 1, {0x02}},
	{0x71, 1, {0x02}},
	{0x72, 1, {0x02}},
	{0x73, 1, {0x02}},
	{0x74, 1, {0x02}},
	{0x75, 1, {0x0A}},
	{0x76, 1, {0x02}},
	{0x77, 1, {0x02}},
	{0x78, 1, {0x06}},
	{0x79, 1, {0x15}},
	{0x7A, 1, {0x14}},
	{0x7B, 1, {0x02}},
	{0x7C, 1, {0x10}},
	{0x7D, 1, {0x11}},
	{0x7E, 1, {0x02}},
	{0x7F, 1, {0x0C}},
	{0x80, 1, {0x0D}},
	{0x81, 1, {0x02}},
	{0x82, 1, {0x0E}},
	{0x83, 1, {0x0F}},
	{0x84, 1, {0x08}},
	{0x85, 1, {0x02}},
	{0x86, 1, {0x02}},
	{0x87, 1, {0x02}},
	{0x88, 1, {0x02}},
	{0x89, 1, {0x02}},
	{0x8A, 1, {0x02}},
	{0xFF, 3, {0x98, 0x81, 0x04}},
	{0x3B, 1, {0xC0}},
	{0x6C, 1, {0x15}},
	{0x6E, 1, {0x30}},
	{0x6F, 1, {0x55}},
	{0x3A, 1, {0x24}},
	{0x8D, 1, {0x1F}},
	{0x87, 1, {0xBA}},
	{0x26, 1, {0x76}},
	{0xB2, 1, {0xD1}},
	{0xB5, 1, {0x07}},
	{0x35, 1, {0x1F}},
	{0x88, 1, {0x0B}},
	{0x21, 1, {0x30}},
	{0xFF, 3, {0x98, 0x81, 0x01}},
	{0x22, 1, {0x0A}},
	{0x31, 1, {0x09}},
	{0x40, 1, {0x33}},
	{0x53, 1, {0x37}},
	{0x55, 1, {0x88}},
	{0x50, 1, {0x95}},
	{0x51, 1, {0x95}},
	{0x60, 1, {0x30}},
	{0xA0, 1, {0x0F}},
	{0xA1, 1, {0x17}},
	{0xA2, 1, {0x22}},
	{0xA3, 1, {0x19}},
	{0xA4, 1, {0x15}},
	{0xA5, 1, {0x28}},
	{0xA6, 1, {0x1C}},
	{0xA7, 1, {0x1C}},
	{0xA8, 1, {0x78}},
	{0xA9, 1, {0x1C}},
	{0xAA, 1, {0x28}},
	{0xAB, 1, {0x69}},
	{0xAC, 1, {0x1A}},
	{0xAD, 1, {0x19}},
	{0xAE, 1, {0x4B}},
	{0xAF, 1, {0x22}},
	{0xB0, 1, {0x2A}},
	{0xB1, 1, {0x4B}},
	{0xB2, 1, {0x6B}},
	{0xB3, 1, {0x3F}},
	{0xC0, 1, {0x01}},
	{0xC1, 1, {0x17}},
	{0xC2, 1, {0x22}},
	{0xC3, 1, {0x19}},
	{0xC4, 1, {0x15}},
	{0xC5, 1, {0x28}},
	{0xC6, 1, {0x1C}},
	{0xC7, 1, {0x1D}},
	{0xC8, 1, {0x78}},
	{0xC9, 1, {0x1C}},
	{0xCA, 1, {0x28}},
	{0xCB, 1, {0x69}},
	{0xCC, 1, {0x1A}},
	{0xCD, 1, {0x19}},
	{0xCE, 1, {0x4B}},
	{0xCF, 1, {0x22}},
	{0xD0, 1, {0x2A}},
	{0xD1, 1, {0x4B}},
	{0xD2, 1, {0x6B}},
	{0xD3, 1, {0x3F}},
	{0xFF, 3, {0x98, 0x81, 0x00}},
	{0x35, 0, {0}},
	{0x11, 0, {0}},
	{REGFLAG_DELAY, 120, {0}},
	{0x29, 0, {0}},
	{REGFLAG_DELAY, 20, {0}},
	{REGFLAG_END_OF_TABLE, 0, {0}},
};

static void LCD_panel_init(u32 sel)
{
	u32 i;
	u8 cmd;
	u32 count;
	u8 *para;

	pr_info("jl_hxr_ili9881c: panel_init\n");
	sunxi_lcd_dsi_clk_enable(sel);
	sunxi_lcd_delay_ms(20);
	/* 硬 reset 后直接发码。不做 DSI 读探针（屏不回会把 DPHY 卡死）。 */

	for (i = 0; ; i++) {
		cmd = lcm_initialization_setting[i].cmd;
		count = lcm_initialization_setting[i].count;
		para = lcm_initialization_setting[i].para_list;
		if (cmd == REGFLAG_END_OF_TABLE)
			break;
		if (cmd == REGFLAG_DELAY) {
			sunxi_lcd_delay_ms(count);
			continue;
		}
		dsi_gen_wr(sel, cmd, para, count);
	}
}

static void LCD_panel_exit(u32 sel)
{
	sunxi_lcd_dsi_dcs_write_0para(sel, 0x28);
	sunxi_lcd_delay_ms(20);
	sunxi_lcd_dsi_dcs_write_0para(sel, 0x10);
	sunxi_lcd_delay_ms(80);
}

static s32 LCD_user_defined_func(u32 sel, u32 para1, u32 para2, u32 para3)
{
	(void)sel;
	(void)para1;
	(void)para2;
	(void)para3;
	return 0;
}

struct __lcd_panel jl_hxr_ili9881c_panel = {
	.name = "jl_hxr_ili9881c",
	.func = {
		.cfg_panel_info = LCD_cfg_panel_info,
		.cfg_open_flow = LCD_open_flow,
		.cfg_close_flow = LCD_close_flow,
		.lcd_user_defined_func = LCD_user_defined_func,
	},
};
