#include <lvgl/lvgl.h>

void imx6ull_pro_widgets()
{
    lv_obj_t *image = lv_image_create(lv_screen_active());
    lv_image_set_src(image, "A:images/hades.png");
    lv_obj_set_size(image, LV_PCT(100), LV_PCT(100));
    lv_image_set_inner_align(image, LV_IMAGE_ALIGN_STRETCH);
}
