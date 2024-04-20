### This is meant to be used along with the following Artisan CNC mod:  https://www.thingiverse.com/thing:6586754

### View te following video for more information: 


# Description

This script will take a luban generated CNC G-code file and modify it in the following 2 ways:

1: Will remove all M5 and M05 lines disabling the spindle from starting

2: Will grab a portion of the beginning lines of code for each shape and append it to the end in order to completely close the design. Since CNC G-code accounts for the width of a `bit` to complete a shape, it often cuts short of a completed shape.

However if you are using the cnc in, such as in this case; as a plotter or knife cutter, the point of these are often too thin and wont completely cut out a shape unless you add extra steps at the end.

# Instructions for cnc Gcode file

Create a tool with the following parameters:

<img width="424" alt="Screenshot 2024-04-19 at 8 23 43 PM" src="https://github.com/sloflo/artisan-cut/assets/539297/e618685f-e24a-48e6-837e-3d124b093554">


Create a toolpath for each shape with the following parameters:

<img width="458" alt="Screenshot 2024-04-19 at 8 23 33 PM" src="https://github.com/sloflo/artisan-cut/assets/539297/2cc5adde-378e-4a2d-a68e-9262e2dc9c03">



Jog height must be set to `5mm` the following script uses that number to reference the beginning of the gcode shapes.

If you need multiple passes lower the `step down` by a fraction of the amount of passses you need. For example if target depth is set to 1mm, two paases would be .5mm, 3 passes would be .33mm etc.



# Instructions for file processing

Open the `GCODE_Cricut` script in a terminal. On a mac simply drag and drop.

`Please enter the file name:` Enter the complete path of your luban exported cnc file.

`Offset in mm (default is 6):` this is the amount of overlap you would like the shape line to have (in order to completely cut out a shape)

Once you press enter it will read every line and perform the required operations. It will export a modified gcode file in the same path as the original file.

Send this file to the snapmaker artisan and continue as you usually would with a cnc job. With the following exception:

1: After setting the work coordinates and the tip of your knife or pen touches the surface, lower the z axix by 2mm. This is to ensure that differences in bed leveling dont affect the cut/plot.
