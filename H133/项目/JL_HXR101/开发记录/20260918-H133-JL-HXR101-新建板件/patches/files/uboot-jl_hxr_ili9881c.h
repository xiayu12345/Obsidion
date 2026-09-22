/* HXR10106B-28 LB 10.1" 800x1280 MIPI, driver IC ILI9881C-0H */
#ifndef __JL_HXR_ILI9881C_H__
#define __JL_HXR_ILI9881C_H__

#include "panels.h"

extern __lcd_panel_t jl_hxr_ili9881c_panel;
extern s32 dsi_gen_wr(u32 sel, u8 cmd, u8 *para_p, u32 para_num);

#endif
