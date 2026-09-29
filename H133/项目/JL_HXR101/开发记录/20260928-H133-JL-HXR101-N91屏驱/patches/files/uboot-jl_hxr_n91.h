/* HXR10106B-28 LB 10.1" 800x1280 MIPI, ILI9881C, N91 init */
#ifndef __JL_HXR_N91_H__
#define __JL_HXR_N91_H__

#include "panels.h"

extern __lcd_panel_t jl_hxr_n91_panel;
extern s32 dsi_gen_wr(u32 sel, u8 cmd, u8 *para_p, u32 para_num);

#endif
