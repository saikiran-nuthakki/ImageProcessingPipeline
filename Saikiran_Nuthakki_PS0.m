%% Initials

image = imread('banana_slug.tiff');

% Data type and Size
class(image)
[Ysize, Xsize] = size(image);


% make it into a double
image = double(image);

%% Linearization

blk = 2047;
sat = 15000;
bay = (image - blk) / (sat - blk);

bay = max(0, min(bay, 1));

%% Bayer pattern

% making sub-images of 1/4 res.
first = bay(1:2:end, 1:2:end );

second = bay(1:2:end, 2:2:end );

third = bay(2:2:end, 1:2:end );

fourth = bay(2:2:end, 2:2:end );

% making RGB images of 1/4 res.
gbrg = cat(3, third, first, second);

rggb = cat(3, first, second, fourth);

grbg = cat(3, second, first, third);

bggr = cat(3, fourth, second, first);


% displaying 4 different images
figure; imshow(grbg * 4); title('grbg');

figure; imshow(rggb * 4); title('rggb');

figure; imshow(bggr * 4); title('bggr');

figure; imshow(gbrg * 4); title('gbrg');

% the image rggb is the best

%% White balancing

pix_red = bay(1:2:end, 1:2:end);

pix_blue = bay(2:2:end, 2:2:end);

pix_1_green = bay(1:2:end, 2:2:end);

pix_2_green = bay(2:2:end, 1:2:end);


% white world assumption:
top_red = max(pix_red(:));
top_green = max([pix_1_green(:); pix_2_green(:)]);
top_blue = max(pix_blue(:));

% New image with different wb val.
white_world = zeros(size(bay));

white_world(1:2:end, 1:2:end) = pix_red * top_green / top_red;

white_world(1:2:end, 2:2:end) = pix_1_green;

white_world(2:2:end, 1:2:end) = pix_2_green;

white_world(2:2:end, 2:2:end) = pix_blue * green_max / top_blue;

% gray world assumption:
avg_red = mean(pix_red(:));

avg_green = mean([pix_1_green(:); pix_2_green(:)]);

avg_blue = mean(pix_blue(:));

% New image with different wb value
gray_world = zeros(size(bay));

gray_world(1:2:end, 1:2:end) = pix_red * avg_green / avg_red;

gray_world(1:2:end, 2:2:end) = pix_1_green;

gray_world(2:2:end, 1:2:end) = pix_2_green;

gray_world(2:2:end, 2:2:end) = pix_blue * avg_green / avg_blue;


%% Demosaicing

pic = white_world;

% demosaic the red channel
[Y, X] = meshgrid(1:2:Xsize, 1:2:Ysize);
updated = pic(1:2:end, 1:2:end);

demosaic = zeros(size(pic));
demosaic(1:2:end, 1:2:end) = updated;

[Yin, Xin] = meshgrid(2:2:Xsize, 1:2:Ysize);
demosaic(2:2:end, 1:2:end) = interp2(Y, X, updated, Yin, Xin);

[Yin, Xin] = meshgrid(1:2:Xsize, 2:2:Ysize);
demosaic(1:2:end, 2:2:end) = interp2(Y, X, updated, Yin, Xin);

[Yin, Xin] = meshgrid(2:2:Xsize, 2:2:Ysize);
demosaic(2:2:end, 2:2:end) = interp2(Y, X, updated, Yin, Xin);

demosaic_red = demosaic;

% demosaic the blue channel
[Y, X] = meshgrid(2:2:Xsize, 2:2:Ysize);
updated = pic(2:2:end, 2:2:end);

demosaic = zeros(size(im));
demosaic(1:2:end, 2:2:end) = updated;

[Yin, Xin] = meshgrid(1:2:Xsize, 1:2:Ysize);
demosaic(1:2:end, 1:2:end) = interp2(Y, X, updated, Yin, Xin);

[Yin, Xin] = meshgrid(1:2:Xsize, 2:2:Ysize);
demosaic(1:2:end, 2:2:end) = interp2(Y, X, updated, Yin, Xin);

[Yin, Xin] = meshgrid(2:2:Xsize, 1:2:Ysize);
demosaic(2:2:end, 1:2:end) = interp2(Y, X, updated, Yin, Xin);

demosaic_blue = demosaic;

% demosaic the green channel
[Y1, X1] = meshgrid(1:2:Xsize, 2:2:Ysize);
first_vals = pic(1:2:end, 2:2:end);

[Y2, X2] = meshgrid(2:2:Xsize, 1:2:Ysize);
sec_vals = pic(2:2:end, 1:2:end);

demosaic = zeros(size(im));
demosaic(1:2:end, 2:2:end) = first_vals;
demosaic(2:2:end, 1:2:end) = sec_vals;


[Yin, Xin] = meshgrid(1:2:Xsize, 1:2:Ysize);
demosaic(1:2:end, 1:2:end) = (interp2(Y1, X1, first_vals, Yin, Xin)... 
						+ interp2(Y2, X2, sec_vals, Yin, Xin)) / 2;
                    
[Yin, Xin] = meshgrid(2:2:Xsize, 2:2:Ysize);
demosaic(2:2:end, 2:2:end) = (interp2(Y1, X1, first_vals, Yin, Xin)...
						+ interp2(Y2, X2, sec_vals, Yin, Xin)) / 2;

demosaic_green = demosaic;

draft = cat(3, demosaic_red, demosaic_green, demosaic_blue);

%% Brightness adjustment and gamma correction

graysc = rgb2gray(draft);

percentage = 4;

im_rgb_brightened = draft * percentage * max(graysc(:));

final = zeros(size(im_rgb_brightened));

inds = (im_rgb_brightened <= 0.0031308);

final(inds) = 12.92 * im_rgb_brightened(inds);

final(~inds) = real(1.055 * im_rgb_brightened(~inds) .^ (1 / 2.4) - 0.055);

figure; imshow(final);

%% Compression

imwrite(im_final,"image.png");

imwrite(im_final, "image.jpeg",'Quality',95);
