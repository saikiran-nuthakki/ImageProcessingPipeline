# ImageProcessingPipeline

Initials: Load the image into Matlab. Originally, it will be in the form of a 2D-array of unsigned integers. Check and report how many bits per integer the image has, and what its width and height is. Then, convert the image into a double- precision array.

Linearization: Convert the image into a linear array within the range [0, 1]. Do this by applying a linear transform (shift and scale) to the image, so that the value 2047 is mapped to 0, and the value 15000 is mapped to 1. Then, clip negative values to 0, and values greater than 1 to 1. 

Identifying the correct Bayer pattern: Think of a way for identifying which version of the Bayer patterns applies to our image file, and report which version
you identified.

White balancing: Two of the most common algorithms for white balancing use the so-called gray world and white world assumptions, and correspond to the transformations show in Figure 4. Implement both gray world and white world white balancing.

Demosaicing: After white balancing, you want to demosaic the image. This means that you want to convert the partial red, green, and blue color channels you have available because of mosaicing, into three full-resolution color channels. Use bilinear interpolation for demosaicing

Brightness adjustment and gamma correction: Brighten the image by linearly scaling it by some number. Select the scale as a percentage of the pre- brightening maximum grayscale value.

Compression: Use the imwrite command to store the image in .PNG format (no compression), and also in .JPEG format with quality setting 95.
