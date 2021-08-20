# extract metadata from jpg files

library(data.table)
library(mapview)
library(exiftoolr)
library(magick)
library(sf)

# install exiftool: https://exiftool.org/install.html#Unix
# github: https://github.com/JoshOBrien/exiftoolr
# stackoverflow: https://stackoverflow.com/questions/59707871/extracting-metadata-from-large-set-of-images
# https://superuser.com/questions/1370420/how-to-find-geolocation-of-a-photo-in-linux

# list all jpgs
fls = list.files("data/jpg/2_6c_Baumumfang/"
                 , pattern = "\\.jpg"
                 , full.names = TRUE)

# base
file.info(fls[1])

# magick
img = image_read(fls[1])
image_attributes(img)

# exif
meta = exif_read(fls[1], tags = "*GPS*")
grep("File", names(meta), value = TRUE)
exif_call(args = c("-n", "-j", "-q", "-*GPS*"), path = fls[1])
