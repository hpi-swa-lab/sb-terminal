Class {
	#name : #SBBashManpageHolder,
	#superclass : #Object,
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashManpageHolder class >> convert [

	^ 'convert-im6.q16(1)          General Commands Manual         convert-im6.q16(1)

NAME
       convert  -  convert  between  image formats as well as resize an image,
       blur, crop, despeckle, dither, draw on, flip, join, re-sample, and much
       more.

SYNOPSIS
       convert-im6.q16 [input-option] input-file [output-option] output-file

OVERVIEW
       The  convert-im6.q16 program is a member of the ImageMagick-ims6.q16(1)
       suite of tools.  Use it to convert between image formats as well as re‐
       size  an image, blur, crop, despeckle, dither, draw on, flip, join, re-
       sample, and much more.

       For more information about the convert command, point your  browser  to
       file:///usr/share/doc/imagemagick-6-common/html/www/convert.html    (on
       debian  system  you  may  install   the   imagemagick-6   package)   or
       https://www.imagemagick.org/script/convert.php.

DESCRIPTION
       Image Settings:
         -adjoin              join images into a single multi-image file
         -affine matrix       affine transform matrix
         -alpha  option         activate,  deactivate, reset, or set the alpha
       channel
         -antialias           remove pixel-aliasing
         -authenticate value  decrypt image with this password
         -attenuate value     lessen (or intensify) when adding  noise  to  an
       image
         -background color    background color
         -bias value          add bias when convolving an image
         -black-point-compensation
                              use black point compensation
         -blue-primary point  chromaticity blue primary point
         -bordercolor color   border color
         -caption string      assign a caption to an image
         -cdl filename        color correct with a color decision list
         -channel type        apply option to select image channels
         -clip                clip along the first path from the 8BIM profile
         -clip-mask filename  associate a clip mask with the image
         -clip-path id        clip along a named path from the 8BIM profile
         -colors value        preferred number of colors in the image
         -colorspace type     alternate image colorspace
         -comment string      annotate image with comment
         -compose operator    set image composite operator
         -compress type       type of pixel compression when writing the image
         -decipher filename   convert cipher pixels to plain pixels
         -define format:option
                              define one or more image format options
         -delay value         display the next image after pausing
         -density geometry    horizontal and vertical density of the image
         -depth value         image depth
         -direction type      render text right-to-left or left-to-right
         -display server      get image or font from this X server
         -dispose method      layer disposal method
         -dither method       apply error diffusion to image
         -encipher filename   convert plain pixels to cipher pixels
         -encoding type       text encoding type
         -endian type         endianness (MSB or LSB) of the image
         -family name         render text with this font family
         -features  distance   analyze image features (e.g. contrast, correla‐
       tion)
         -fill color          color to use when filling a graphic primitive
         -filter type         use this filter when resizing an image
         -flatten             flatten a sequence of images
         -font name           render text with this font
         -format "string"     output formatted image characteristics
         -fuzz distance       colors within this distance are considered equal
         -gravity type        horizontal and vertical text placement
         -green-primary point chromaticity green primary point
         -intensity method    method to generate intensity value from pixel
         -intent type         type of rendering intent when managing the image
       color
         -interlace type      type of image interlacing scheme
         -interline-spacing value
                              set the space between two text lines
         -interpolate method  pixel color interpolation method
         -interword-spacing value
                              set the space between two words
         -kerning value       set the space between two letters
         -label string        assign a label to an image
         -limit type value    pixel cache resource limit
         -loop  iterations      add Netscape loop extension to your GIF anima‐
       tion
         -mask filename       associate a mask with the image
         -matte               store matte channel if the image has one
         -mattecolor color    frame color
         -metric type         measure differences  between  images  with  this
       metric
         -moments             report image moments
         -monitor             monitor progress
         -orient type         image orientation
         -page geometry       size and location of an image canvas (setting)
         -ping                efficiently determine image attributes
         -pointsize value     font point size
         -precision value     maximum number of significant digits to print
         -preview type        image preview type
         -quality value       JPEG/MIFF/PNG compression level
         -quiet               suppress all warning messages
         -red-primary point   chromaticity red primary point
         -regard-warnings     pay attention to warning messages
         -remap filename      transform image colors to match this set of col‐
       ors
         -repage geometry     size and location of an image canvas
         -respect-parentheses settings  remain  in  effect  until  parenthesis
       boundary
         -sampling-factor geometry
                              horizontal and vertical sampling factor
         -scene value         image scene number
         -seed value          seed a new sequence of pseudo-random numbers
         -size geometry       width and height of image
         -statistic type geometry
                              replace  each pixel with corresponding statistic
       from the neighborhood
         -stretch type        render text with this font stretch
         -stroke color        graphic primitive stroke color
         -strokewidth value   graphic primitive stroke width
         -style type          render text with this font style
         -support factor      resize support: > 1.0 is blurry, < 1.0 is sharp
         -synchronize         synchronize image to storage device
         -taint               declare the image as modified
         -texture filename    name of texture to tile  onto  the  image  back‐
       ground
         -tile-offset geometry
                              tile offset
         -treedepth value     color tree depth
         -transparent-color color
                              transparent color
         -undercolor color    annotation bounding box color
         -units type          the units of image resolution
         -verbose             print detailed information about the image
         -view                FlashPix viewing transforms
         -virtual-pixel method
                              virtual pixel access method
         -weight type         render text with this font weight
         -white-point point   chromaticity white point

       Image Operators:
         -adaptive-blur geometry
                              adaptively  blur  pixels;  decrease  effect near
       edges
         -adaptive-resize geometry
                              adaptively resize image with data dependent tri‐
       angulation
         -adaptive-sharpen geometry
                              adaptively  sharpen pixels; increase effect near
       edges
         -annotate geometry text
                              annotate the image with text
         -auto-gamma          automagically adjust gamma level of image
         -auto-level          automagically adjust color levels of image
         -auto-orient         automatically orient image
         -bench iterations    measure performance
         -black-threshold value
                              force all pixels below the threshold into black
         -blue-shift factor   simulate a scene at nighttime in the moonlight
         -blur geometry       reduce image noise and reduce detail levels
         -border geometry     surround image with a border of color
         -brightness-contrast geometry
                               improve brightness / contrast of the image
         -canny geometry      detect edges in the image
         -charcoal radius     simulate a charcoal drawing
         -chop geometry       remove pixels from the image interior
         -clamp               keep pixel values in range (0-QuantumRange)
         -clip                clip along the first path from the 8BIM profile
         -clip-mask filename  associate a clip mask with the image
         -clip-path id        clip along a named path from the 8BIM profile
         -colorize value      colorize the image with the fill color
         -color-matrix matrix apply color correction to the image
         -connected-component connectivity
                              connected-components uniquely labeled
         -contrast            enhance or reduce the image contrast
         -contrast-stretch geometry
                              improve contrast by `stretching''  the  intensity
       range
         -convolve coefficients
                              apply a convolution kernel to the image
         -cycle amount        cycle the image colormap
         -deskew threshold    straighten an image
         -despeckle           reduce the speckles within an image
         -distort method args
                               distort  images  according  to given method and
       args
         -draw string         annotate the image with a graphic primitive
         -edge radius         apply a filter to detect edges in the image
         -emboss radius       emboss an image
         -enhance             apply a digital filter to enhance a noisy image
         -equalize            perform histogram equalization to an image
         -evaluate operator value
                              evaluate an arithmetic, relational,  or  logical
       expression
         -extent geometry     set the image size
         -extract geometry    extract area from image
         -fft                 implements the discrete Fourier transform (DFT)
         -flip                flip image vertically
         -floodfill geometry color
                              floodfill the image with color
         -flop                flop image horizontally
         -frame geometry      surround image with an ornamental border
         -function name       apply a function to the image
         -gamma value         level of gamma correction
         -gaussian-blur geometry
                              reduce image noise and reduce detail levels
         -geometry geometry   preferred size or location of the image
         -grayscale method    convert image to grayscale
         -hough-lines geometry
                              identify lines in the image
         -identify             identify  the format and characteristics of the
       image
         -ift                 implements the inverse discrete  Fourier  trans‐
       form (DFT)
         -implode amount      implode image pixels about the center
         -interpolative-resize geometry
                               resize  image  using ''point sampled'' interpola‐
       tion
         -lat geometry        local adaptive thresholding
         -layers method       optimize or compare image layers
         -level value         adjust the level of image contrast
         -level-colors color,color
                              level image with the given colors
         -linear-stretch geometry
                              improve contrast by `stretching with saturation''
       the intensity range
         -liquid-rescale geometry
                               rescale image with seam-carving
         -magnify              double  the  size  of  the image with pixel art
       scaling
         -mean-shift geometry delineate arbitrarily shaped clusters in the im‐
       age
         -median geometry     apply a median filter to the image
         -mode  geometry        make each pixel the ''predominant color'' of the
       neighborhood
         -modulate value      vary the brightness, saturation, and hue
         -monochrome          transform image to black and white
         -morphology method kernel
                              apply a morphology method to the image
         -motion-blur geometry
                              simulate motion blur
         -negate              replace each pixel with its complementary color
         -noise geometry      add or reduce noise in an image
         -normalize           transform image to span the full range of colors
         -opaque color        change this color to the fill color
         -ordered-dither NxN
                              add a noise pattern to the image  with  specific
       amplitudes
         -paint radius        simulate an oil painting
         -perceptible epsilon
                              pixel  value  less than |epsilon| become epsilon
       or -epsilon
         -polaroid angle      simulate a Polaroid picture
         -posterize levels    reduce the image to a limited  number  of  color
       levels
         -print string        interpret string and print to console
         -profile filename    add, delete, or apply an image profile
         -quantize colorspace reduce colors in this colorspace
         -radial-blur angle   radial blur the image
         -raise  value          lighten/darken image edges to create a 3-D ef‐
       fect
         -random-threshold low,high
                              random threshold the image
         -region geometry     apply options to a portion of the image
         -render              render vector graphics
         -resample geometry   change the resolution of an image
         -resize geometry     resize the image
         -roll geometry       roll an image vertically or horizontally
         -rotate degrees      apply Paeth rotation to the image
         -sample geometry     scale image with pixel sampling
         -scale geometry      scale the image
         -segment values      segment an image
         -selective-blur geometry
                              selectively  blur  pixels  within   a   contrast
       threshold
         -sepia-tone threshold
                              simulate a sepia-toned photo
         -set property value  set an image property
         -shade degrees       shade the image using a distant light source
         -shadow geometry     simulate an image shadow
         -sharpen geometry    sharpen the image
         -shave geometry      shave pixels from the image edges
         -shear  geometry       slide  one  edge of the image along the X or Y
       axis
         -sigmoidal-contrast geometry
                              lightness rescaling using sigmoidal contrast en‐
       hancement
         -sketch geometry     simulate a pencil sketch
         -solarize threshold  negate all pixels above the threshold level
         -sparse-color method args
                               fill in a image based on a few color points
         -splice geometry     splice the background color into the image
         -spread amount       displace image pixels by a random amount
         -strip               strip image of all profiles and comments
         -swirl degrees       swirl image pixels about the center
         -threshold value     threshold the image
         -thumbnail geometry  create a thumbnail of the image
         -tile filename       tile image when filling a graphic primitive
         -tint value          tint the image with the fill color
         -transform           affine transform image
         -transparent color   make this color transparent within the image
         -transpose           flip image vertically and rotate 90 degrees
         -transverse          flop image horizontally and rotate 270 degrees
         -trim                trim image edges
         -type type           image type
         -unique-colors       discard all but one of any pixel color
         -unsharp geometry    sharpen the image
         -vignette geometry   soften the edges of the image in vignette style
         -wave geometry       alter an image along a sine wave
         -wavelet-denoise threshold
                               removes  noise  from  the image using a wavelet
       transform
         -white-threshold value
                              force all pixels above the threshold into white

       Image Sequence Operators:
         -append              append an image sequence top to bottom (use +ap‐
       pend for left to right)
         -clut                apply a color lookup table to the image
         -coalesce            merge a sequence of images
         -combine             combine a sequence of images
         -compare             mathematically and visually annotate the differ‐
       ence between an image and its reconstruction
         -complex operator    perform complex mathematics on an image sequence
         -composite           composite image
         -copy geometry offset,
                              copy pixels from one area of an image to another
         -crop geometry       cut out a rectangular region of the image
         -deconstruct         break down an image  sequence  into  constituent
       parts
         -evaluate-sequence operator
                              evaluate  an  arithmetic, relational, or logical
       expression
         -flatten             flatten a sequence of images
         -fx expression       apply mathematical expression to an image  chan‐
       nel(s)
         -hald-clut           apply a Hald color lookup table to the image
         -morph value         morph an image sequence
         -mosaic              create a mosaic from an image sequence
         -poly  terms           build a polynomial from the image sequence and
       the corresponding terms (coefficients and degree pairs)
         -process arguments   process the image with a custom image filter
         -separate            separate an image channel into a grayscale image
         -smush geometry      smush an image sequence together
         -write filename      write images to this file

       Image Stack Operators:
         -clone indexes       clone an image
         -delete indexes      delete the image from the image sequence
         -duplicate count,indexes
                              duplicate an image one or more times
         -insert index        insert last image into the image sequence
         -reverse             reverse image sequence
         -swap indexes        swap two images in the image sequence

       Miscellaneous Options:
         -debug events        display copious debugging information
         -distribute-cache port
                              distributed pixel cache  spanning  one  or  more
       servers
         -help                print program options
         -log format          format of debugging information
         -list type           print a list of supported option arguments
         -version             print version information

       Use any setting or operator as an output-option.  Only a limited number
       of setting are  input-option. They include: -antialias, -caption, -den‐
       sity,  -define,  -encoding,  -font,  -pointsize, -size, and -texture as
       well as any of the miscellaneous options.

       By default, the image format of `file'' is determined by its magic  num‐
       ber.   To  specify a particular image format, precede the filename with
       an image format name and a colon (i.e. ps:image) or specify  the  image
       type as the filename suffix (i.e. image.ps).  Specify ''file'' as ''-'' for
       standard input or output.

SEE ALSO
       ImageMagick-ims6.q16(1)

COPYRIGHT
       Copyright (C) 1999-2019 ImageMagick Studio LLC.  Additional  copyrights
       and  licenses  apply to this software, see file:///usr/share/doc/image‐
       magick-6-common/html/www/license.html (on debian system you may install
       the  imagemagick-6  package)  or https://www.imagemagick.org/script/li‐
       cense.php

ImageMagick                Date: 2009/01/10 01:00:00        convert-im6.q16(1)
'
]

{ #category : #'as yet unclassified' }
SBBashManpageHolder class >> dwebp [

	^ 'DWEBP(1)                    General Commands Manual                   DWEBP(1)

NAME
       dwebp - decompress a WebP file to an image file

SYNOPSIS
       dwebp [options] input_file.webp

DESCRIPTION
       This manual page documents the dwebp command.

       dwebp decompresses WebP files into PNG, PAM, PPM or PGM images.

OPTIONS
       The basic options are:

       -h     Print usage summary.

       -version
              Print the version number (as major.minor.revision) and exit.

       -o string
              Specify  the name of the output file (as PNG format by default).
              Using "-" as output name will direct output to ''stdout''.

       -- string
              Explicitly specify the input file. This option is useful if  the
              input file starts with an ''-'' for instance. This option must ap‐
              pear last.  Any other options afterward will be ignored. If  the
              input file is "-", the data will be read from stdin instead of a
              file.

       -bmp   Change the output format to uncompressed BMP.

       -tiff  Change the output format to uncompressed TIFF.

       -pam   Change the output format to PAM (retains alpha).

       -ppm   Change the output format to PPM (discards alpha).

       -pgm   Change  the  output  format  to  PGM.  The  output  consists  of
              luma/chroma  samples instead of RGB, using the IMC4 layout. This
              option is mainly for verification and debugging purposes.

       -yuv   Change the output format to raw  YUV.  The  output  consists  of
              luma/chroma-U/chroma-V  samples  instead  of  RGB, saved sequen‐
              tially as individual planes. This option is mainly for verifica‐
              tion and debugging purposes.

       -nofancy
              Don''t  use the fancy upscaler for YUV420. This may lead to jaggy
              edges (especially the red ones), but should be faster.

       -nofilter
              Don''t use the in-loop filtering process even if it  is  required
              by  the  bitstream.  This may produce visible blocks on the non-
              compliant output, but it will make the decoding faster.

       -dither strength
              Specify a dithering strength between 0 and 100. Dithering  is  a
              post-processing  effect  applied  to  chroma components in lossy
              compression.  It helps by smoothing gradients and avoiding band‐
              ing artifacts.

       -alpha_dither
              If  the  compressed  file contains a transparency plane that was
              quantized during compression, this flag will allow dithering the
              reconstructed  plane  in order to generate smoother transparency
              gradients.

       -nodither
              Disable all dithering (default).

       -mt    Use multi-threading for decoding, if possible.

       -crop x_position y_position width height
              Crop the decoded picture to a rectangle with top-left corner  at
              coordinates  (x_position,  y_position)  and size width x height.
              This cropping area must be fully  contained  within  the  source
              rectangle.   The top-left corner will be snapped to even coordi‐
              nates if needed.  This option is  meant  to  reduce  the  memory
              needed for cropping large images.  Note: the cropping is applied
              before any scaling.

       -flip  Flip decoded image vertically (can be useful for OpenGL textures
              for instance).

       -resize, -scale width height
              Rescale  the  decoded  picture to dimension width x height. This
              option is mostly intended to reducing the memory needed  to  de‐
              code  large  images, when only a small version is needed (thumb‐
              nail, preview, etc.). Note: scaling is applied  after  cropping.
              If either (but not both) of the width or height parameters is 0,
              the value will be calculated preserving the aspect-ratio.

       -quiet Do not print anything.

       -v     Print extra information (decoding time in particular).

       -noasm Disable all assembly optimizations.

BUGS
       Please    report     all     bugs     to     the     issue     tracker:
       https://bugs.chromium.org/p/webp
       Patches  welcome!  See  this  page  to get started: http://www.webmpro‐
       ject.org/code/contribute/submitting-patches/

EXAMPLES
       dwebp picture.webp -o output.png
       dwebp picture.webp -ppm -o output.ppm
       dwebp -o output.ppm -- ---picture.webp
       cat picture.webp | dwebp -o - -- - > output.ppm

AUTHORS
       dwebp is a part of libwebp and was written by the WebP team.
       The  latest  source  tree  is  available  at   https://chromium.google‐
       source.com/webm/libwebp

       This   manual   page  was  written  by  Pascal  Massimino  <pascal.mas‐
       simino@gmail.com>, for the Debian project (and may be used by others).

SEE ALSO
       cwebp(1), gif2webp(1), webpmux(1)
       Please refer to http://developers.google.com/speed/webp/ for additional
       information.

   Output file format details
       PAM: http://netpbm.sourceforge.net/doc/pam.html
       PGM: http://netpbm.sourceforge.net/doc/pgm.html
       PPM: http://netpbm.sourceforge.net/doc/ppm.html
       PNG: http://www.libpng.org/pub/png/png-sitemap.html#info

                                 June 23, 2016                        DWEBP(1)
'
]

{ #category : #'as yet unclassified' }
SBBashManpageHolder class >> ln [

	^ 'LN(1)                            User Commands                           LN(1)

NAME
       ln - make links between files

SYNOPSIS
       ln [OPTION]... [-T] TARGET LINK_NAME
       ln [OPTION]... TARGET
       ln [OPTION]... TARGET... DIRECTORY
       ln [OPTION]... -t DIRECTORY TARGET...

DESCRIPTION
       In  the  1st form, create a link to TARGET with the name LINK_NAME.  In
       the 2nd form, create a link to TARGET in the current directory.  In the
       3rd  and  4th  forms, create links to each TARGET in DIRECTORY.  Create
       hard links by default, symbolic links  with  --symbolic.   By  default,
       each  destination  (name  of  new link) should not already exist.  When
       creating hard links, each TARGET must exist.  Symbolic links  can  hold
       arbitrary  text;  if  later resolved, a relative link is interpreted in
       relation to its parent directory.

       Mandatory arguments to long options are  mandatory  for  short  options
       too.

       --backup[=CONTROL]
              make a backup of each existing destination file

       -b     like --backup but does not accept an argument

       -d, -F, --directory
              allow  the  superuser to attempt to hard link directories (note:
              will probably fail due to system restrictions, even for the  su‐
              peruser)

       -f, --force
              remove existing destination files

       -i, --interactive
              prompt whether to remove destinations

       -L, --logical
              dereference TARGETs that are symbolic links

       -n, --no-dereference
              treat  LINK_NAME  as a normal file if it is a symbolic link to a
              directory

       -P, --physical
              make hard links directly to symbolic links

       -r, --relative
              create symbolic links relative to link location

       -s, --symbolic
              make symbolic links instead of hard links

       -S, --suffix=SUFFIX
              override the usual backup suffix

       -t, --target-directory=DIRECTORY
              specify the DIRECTORY in which to create the links

       -T, --no-target-directory
              treat LINK_NAME as a normal file always

       -v, --verbose
              print name of each linked file

       --help display this help and exit

       --version
              output version information and exit

       The  backup  suffix  is  ''~'',  unless  set  with   --suffix   or   SIM‐
       PLE_BACKUP_SUFFIX.   The version control method may be selected via the
       --backup option or through the  VERSION_CONTROL  environment  variable.
       Here are the values:

       none, off
              never make backups (even if --backup is given)

       numbered, t
              make numbered backups

       existing, nil
              numbered if numbered backups exist, simple otherwise

       simple, never
              always make simple backups

       Using  -s ignores -L and -P.  Otherwise, the last option specified con‐
       trols behavior when a TARGET is a symbolic link, defaulting to -P.

AUTHOR
       Written by Mike Parker and David MacKenzie.

REPORTING BUGS
       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
       Report ln translation bugs to <https://translationproject.org/team/>

COPYRIGHT
       Copyright © 2018 Free Software Foundation, Inc.   License  GPLv3+:  GNU
       GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
       This  is  free  software:  you  are free to change and redistribute it.
       There is NO WARRANTY, to the extent permitted by law.

SEE ALSO
       link(2), symlink(2)

       Full documentation at: <https://www.gnu.org/software/coreutils/ln>
       or available locally via: info ''(coreutils) ln invocation''

GNU coreutils 8.30              September 2019                           LN(1)
'
]

{ #category : #'as yet unclassified' }
SBBashManpageHolder class >> ls [

	^ 'LS(1)                            User Commands                           LS(1)

NAME
       ls - list directory contents

SYNOPSIS
       ls [OPTION]... [FILE]...

DESCRIPTION
       List  information  about  the FILEs (the current directory by default).
       Sort entries alphabetically if none of -cftuvSUX nor --sort  is  speci‐
       fied.

       Mandatory  arguments  to  long  options are mandatory for short options
       too.

       -a, --all
              do not ignore entries starting with .

       -A, --almost-all
              do not list implied . and ..

       --author
              with -l, print the author of each file

       -b, --escape
              print C-style escapes for nongraphic characters

       --block-size=SIZE
              with  -l,  scale  sizes  by  SIZE  when  printing  them;   e.g.,
              ''--block-size=M''; see SIZE format below

       -B, --ignore-backups
              do not list implied entries ending with ~

       -c     with -lt: sort by, and show, ctime (time of last modification of
              file status information); with -l: show ctime and sort by  name;
              otherwise: sort by ctime, newest first

       -C     list entries by columns

       --color[=WHEN]
              colorize  the output; WHEN can be ''always'' (default if omitted),
              ''auto'', or ''never''; more info below

       -d, --directory
              list directories themselves, not their contents

       -D, --dired
              generate output designed for Emacs'' dired mode

       -f     do not sort, enable -aU, disable -ls --color

       -F, --classify
              append indicator (one of */=>@|) to entries

       --file-type
              likewise, except do not append ''*''

       --format=WORD
              across -x, commas -m, horizontal -x, long -l, single-column  -1,
              verbose -l, vertical -C

       --full-time
              like -l --time-style=full-iso

       -g     like -l, but do not list owner

       --group-directories-first
              group directories before files;

              can   be  augmented  with  a  --sort  option,  but  any  use  of
              --sort=none (-U) disables grouping

       -G, --no-group
              in a long listing, don''t print group names

       -h, --human-readable
              with -l and -s, print sizes like 1K 234M 2G etc.

       --si   likewise, but use powers of 1000 not 1024

       -H, --dereference-command-line
              follow symbolic links listed on the command line

       --dereference-command-line-symlink-to-dir
              follow each command line symbolic link

              that points to a directory

       --hide=PATTERN
              do not list implied entries matching shell  PATTERN  (overridden
              by -a or -A)

       --hyperlink[=WHEN]
              hyperlink file names; WHEN can be ''always'' (default if omitted),
              ''auto'', or ''never''

       --indicator-style=WORD
              append indicator with style WORD to entry names: none (default),
              slash (-p), file-type (--file-type), classify (-F)

       -i, --inode
              print the index number of each file

       -I, --ignore=PATTERN
              do not list implied entries matching shell PATTERN

       -k, --kibibytes
              default  to  1024-byte  blocks for disk usage; used only with -s
              and per directory totals

       -l     use a long listing format

       -L, --dereference
              when showing file information for a symbolic link, show informa‐
              tion  for  the file the link references rather than for the link
              itself

       -m     fill width with a comma separated list of entries

       -n, --numeric-uid-gid
              like -l, but list numeric user and group IDs

       -N, --literal
              print entry names without quoting

       -o     like -l, but do not list group information

       -p, --indicator-style=slash
              append / indicator to directories

       -q, --hide-control-chars
              print ? instead of nongraphic characters

       --show-control-chars
              show nongraphic characters as-is (the default, unless program is
              ''ls'' and output is a terminal)

       -Q, --quote-name
              enclose entry names in double quotes

       --quoting-style=WORD
              use  quoting style WORD for entry names: literal, locale, shell,
              shell-always,  shell-escape,  shell-escape-always,   c,   escape
              (overrides QUOTING_STYLE environment variable)

       -r, --reverse
              reverse order while sorting

       -R, --recursive
              list subdirectories recursively

       -s, --size
              print the allocated size of each file, in blocks

       -S     sort by file size, largest first

       --sort=WORD
              sort  by  WORD instead of name: none (-U), size (-S), time (-t),
              version (-v), extension (-X)

       --time=WORD
              with -l, show time as WORD instead of default modification time:
              atime  or  access  or  use  (-u); ctime or status (-c); also use
              specified time as sort key if --sort=time (newest first)

       --time-style=TIME_STYLE
              time/date format with -l; see TIME_STYLE below

       -t     sort by modification time, newest first

       -T, --tabsize=COLS
              assume tab stops at each COLS instead of 8

       -u     with -lt: sort by, and show, access time; with -l:  show  access
              time  and  sort  by name; otherwise: sort by access time, newest
              first

       -U     do not sort; list entries in directory order

       -v     natural sort of (version) numbers within text

       -w, --width=COLS
              set output width to COLS.  0 means no limit

       -x     list entries by lines instead of by columns

       -X     sort alphabetically by entry extension

       -Z, --context
              print any security context of each file

       -1     list one file per line.  Avoid ''\n'' with -q or -b

       --help display this help and exit

       --version
              output version information and exit

       The SIZE argument is an integer and  optional  unit  (example:  10K  is
       10*1024).   Units  are  K,M,G,T,P,E,Z,Y  (powers  of 1024) or KB,MB,...
       (powers of 1000).

       The TIME_STYLE argument can be  full-iso,  long-iso,  iso,  locale,  or
       +FORMAT.   FORMAT  is  interpreted  like in date(1).  If FORMAT is FOR‐
       MAT1<newline>FORMAT2, then FORMAT1 applies to non-recent files and FOR‐
       MAT2  to  recent files.  TIME_STYLE prefixed with ''posix-'' takes effect
       only outside the POSIX locale.  Also the TIME_STYLE  environment  vari‐
       able sets the default style to use.

       Using  color  to distinguish file types is disabled both by default and
       with --color=never.  With --color=auto, ls emits color codes only  when
       standard  output is connected to a terminal.  The LS_COLORS environment
       variable can change the settings.  Use the dircolors command to set it.

   Exit status:
       0      if OK,

       1      if minor problems (e.g., cannot access subdirectory),

       2      if serious trouble (e.g., cannot access command-line argument).

AUTHOR
       Written by Richard M. Stallman and David MacKenzie.

REPORTING BUGS
       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
       Report ls translation bugs to <https://translationproject.org/team/>

COPYRIGHT
       Copyright © 2018 Free Software Foundation, Inc.   License  GPLv3+:  GNU
       GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
       This  is  free  software:  you  are free to change and redistribute it.
       There is NO WARRANTY, to the extent permitted by law.

SEE ALSO
       Full documentation at: <https://www.gnu.org/software/coreutils/ls>
       or available locally via: info ''(coreutils) ls invocation''

GNU coreutils 8.30              September 2019                           LS(1)
'
]

{ #category : #'as yet unclassified' }
SBBashManpageHolder class >> wcJSON [

	^ STON fromString: '{ 
		"options": [{
			"long": "bytes", 
			"short": "c", 
			"description": "print the byte counts"
		},
		{
			"long": "chars", 
			"short": "m", 
			"description": "print the character counts"
		},
		{
			"long": "lines", 
			"short": "l", 
			"description": "print the newline counts"
		}]
	 }'.
]
