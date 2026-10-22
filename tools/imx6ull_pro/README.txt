i.MX6ULL LVGL Linux runtime package

Target
------
32-bit ARM hard-float (armhf), EABI5. The target Linux image must provide
/lib/ld-linux-armhf.so.3 and a compatible glibc runtime. The ARM libgcc
runtime is included in this package.

Package contents
----------------
lvglsim                                  LVGL application
lib/libevdev.so.2.3.0                    libevdev runtime shared library
lib/libevdev.so.2                        libevdev SONAME link
lib/libgcc_s.so.1                        ARM compiler runtime
images/hades.png                         Image loaded by the application
run.sh                                   Sets the working directory and library path

Install
-------
Copy the generated package to the board (replace the host path as needed):

    scp out/imx6ull_pro-lvgl_1.0.0_armhf.deb root@<board-ip>:/tmp/

Install it on the board:

    sudo dpkg -i /tmp/imx6ull-pro-lvgl_1.0.0_armhf.deb

The package installs the application and its assets under /opt/imx6ull_pro-lvgl
and the launcher as /usr/bin/imx6ull_pro-lvgl. It requires a compatible armhf
Debian-based Linux system with libc6 2.34 or newer.

Run
---
Start the application on the board:

    imx6ull_pro-lvgl

The application runs in the foreground. Press Ctrl+C to stop it.

Upgrade
-------
Build a new package with TARGET_OS=arm ./aibuild.sh, then copy the new .deb
to the board. Stop the currently running application with Ctrl+C, or, if it
was started in the background:

    sudo pkill -x lvglsim

Install the new package using the same package name:

    sudo dpkg -i /tmp/imx6ull-pro-lvgl_1.0.0_armhf.deb

Start the updated application again with imx6ull_pro-lvgl. dpkg replaces the
previous package version and its package-managed files.

Uninstall
---------
Stop the application first (Ctrl+C if it is running in the foreground):

    sudo pkill -x lvglsim

Remove the package and its package-managed files:

    sudo apt-get purge imx6ull-pro-lvgl

Optionally remove automatically installed dependencies that are no longer
needed:

    sudo apt-get autoremove --purge

This package does not currently install or create configuration files under
/etc. If you created configuration files yourself under /etc/imx6ull_pro-lvgl,
back them up if needed, then remove that package-specific directory:

    sudo rm -r /etc/imx6ull_pro-lvgl

Only run the final command if that directory exists and you intend to delete
its contents. The tar.gz package can also be extracted and started with
./run.sh; files extracted manually are not removed by dpkg and must be deleted
separately.

The application uses the Linux framebuffer. Ensure the display device is
available and the current user has permission to access it.
The launcher uses /dev/input/event1 as the Goodix touchscreen by default.
Set LV_LINUX_EVDEV_POINTER_DEVICE before launching if the touchscreen uses a
different event device, for example:

    LV_LINUX_EVDEV_POINTER_DEVICE=/dev/input/event3 imx6ull_pro-lvgl
