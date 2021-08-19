# extract metadata from jpg files

library(data.table)
library(mapview)
library(exiftoolr)
library(magick)
library(sf)

# install exiftool: https://exiftool.org/install.html#Unix
# see https://github.com/JoshOBrien/exiftoolr

# list all jpgs
fls = list.files("data/jpg/2_6c_Baumumfang/"
                 , pattern = "\\.jpg"
                 , full.names = TRUE)

meta = exif_read(fls[1])
dt  = meta[["CreateDate"]]
lon = meta[["GPSLongitude"]]
lat = meta[["GPSLatitude"]]
