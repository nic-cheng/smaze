This code serves as an example that illustrates usage of the VGA output in the DESim 
application. The code uses a "VGA adapter" to send pixel colors to the VGA window. First, 
press KEY[0] to reset the circuit. It will display the contents of a video memory in the 
VGA adapter as a background image. LEDR[9] will be illuminated to indicate when this process 
is completed. Then, the user can choose to draw a colored box that is centered in the VGA 
display, by pressing KEY[3]. The box color is displayed on LEDR[8:0], and the size of the 
box is displayed as a hexadecimal number on HEX1-0. You can set the color of the box by 
specifying any color on the SW switches and then pressing KEY[1]. You can set the size of 
the box by specifying a new size on the SW switches and then pressing KEY[2].

Note: the video memory is optional and is included only if VGA_MEMORY is defined.

The VGA resolution can be set to 640x480, 320x240, or 160x120. The color depth can be set 
to 3-, 6-, or 9-bit color. Set these parameters in top.v.

