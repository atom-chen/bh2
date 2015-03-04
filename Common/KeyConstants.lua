single_type = 0x00
alt_type = 0x01
ctrl_type = 0x02
shift_type = 0x04
a_c_type = bor(alt_type,ctrl_type)
a_s_type = bor(alt_type,shift_type)
s_c_type = bor(ctrl_type,shift_type)
a_c_s_type = bor(a_c_type,shift_type)

keylog = 
{
	[single_type] = "",
	[alt_type] = "ALT+",
	[ctrl_type] = "CTRL+",
	[shift_type] = "SHIFT+",
	[a_c_type] = "ALT+CTRL+",
	[a_s_type] = "ALT+SHIFT+",
	[s_c_type] = "CTRL+SHIFT+",
	[a_c_s_type] = "ALT+CTRL+SHIFT+",
}