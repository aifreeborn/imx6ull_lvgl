#include <lvgl/lvgl.h>

void imx6ull_board_widgets()
{
	lv_obj_t * label = lv_label_create(lv_screen_active());
    lv_label_set_text_static(label, "imx6ull board widgets");
    lv_obj_center(label);
}
