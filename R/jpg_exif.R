## extract metadata from jpg files ====

## setup ----
library(data.table)
library(mapview)
library(exiftoolr)
library(sf)

# install exiftool: https://exiftool.org/install.html#Unix
# github: https://github.com/JoshOBrien/exiftoolr
# stackoverflow: https://stackoverflow.com/questions/59707871/extracting-metadata-from-large-set-of-images
# https://superuser.com/questions/1370420/how-to-find-geolocation-of-a-photo-in-linux

# list all jpgs
fls = list.files("image/2_6c_Baumumfang/"
                 , pattern = "\\.jpg"
                 , full.names = TRUE)

## approach 1: base R ----
file.info(fls[1])

## approach 2: magick ----
img = image_read(fls[1])
image_attributes(img)

## approach 3: exif ----
meta = exif_read(fls)
# grep("File", names(meta), value = TRUE)
# exif_call(args = c("-n", "-j", "-q", "-*GPS*"), path = fls[1])

vars = c(grep("^File|^Image", names(meta), value = TRUE)
         , "Megapixels")

meta |> 
    subset(select = vars) |> 
    readr::write_excel_csv2(file = "data/jpg_exif.csv"
                            , na = ""
                            , col_names = TRUE)
