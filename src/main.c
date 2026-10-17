#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lvgl/lvgl.h>
#include "lib/driver_backends.h"
#include "lib/simulator_util.h"
#include "lib/simulator_settings.h"

/* Internal functions */

/* contains the name of the selected backend if user
 * has specified one on the command line */
static char * selected_backend;

/* Global simulator settings, defined in lv_linux_backend.c */
extern simulator_settings_t settings;

int main(int argc, char ** argv)
{
    /* Initialize LVGL. */
    lv_init();

    driver_backends_register();
    settings.window_width = 800;
    settings.window_height = 480;

	lv_group_t * default_group = lv_group_create();
    if(default_group == NULL) {
        die("Failed to create default input group");
    }
    lv_group_set_default(default_group);

    /* Initialize the configured backend */
    if(driver_backends_init_backend(selected_backend) == -1) {
        die("Failed to initialize display backend");
    }
    if(settings.rotation) {
#if LV_USE_DRAW_NANOVG && LV_DRAW_TRANSFORM_USE_MATRIX
        lv_display_set_matrix_rotation(NULL, true);
#endif
        lv_display_set_rotation(NULL, settings.rotation);
    }

    /* Enable for EVDEV support */
#if LV_USE_EVDEV
    if(driver_backends_init_backend("EVDEV") == -1) {
        die("Failed to initialize evdev");
    }
#endif

	lv_obj_t * label = lv_label_create(lv_screen_active());
    lv_label_set_text_static(label, "Demos not enabled, create your own ui in `src/main.c`");
    lv_obj_center(label);

    while(1) {
        uint32_t ms = lv_timer_handler();
        if(ms == LV_NO_TIMER_READY) {
            ms = LV_DEF_REFR_PERIOD;
        }
        usleep(ms * 1000);
    }

    return 0;
}
