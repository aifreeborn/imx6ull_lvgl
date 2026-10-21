add_library(imx6ull_pro STATIC
    imx6ull_pro.c
)
add_library(imx6ull_pro::imx6ull_pro ALIAS imx6ull_pro)

target_include_directories(imx6ull_pro PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(imx6ull_pro PUBLIC lvgl::lvgl)
