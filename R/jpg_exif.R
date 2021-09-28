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
pathimg = "data/img/Baumumfang"
pathimg = "data/img/2_6c_Baumumfang"
fls = list.files(pathimg, pattern = "\\.jpg", full.names = TRUE)

## approach 1: base R ----
# file.info(fls[1])

## approach 2: magick ----
# img = image_read(fls[1])
# image_attributes(img)

## approach 3: exif ----
# exif_call(args = c("-n", "-j", "-q", "-*GPS*"), path = fls[1])
meta = exif_read(fls) |> 
    as.data.table()

vars = c(grep("^File|^GPS", names(meta), value = TRUE)
         , "Megapixels")

meta |> 
    subset(select = vars) |> 
    readr::write_excel_csv2(file = paste0(pathimg, "_exif.csv")
                            , na = ""
                            , col_names = TRUE)

meta |> 
    subset(select = vars) |> 
    subset(!is.na(GPSLongitude)) |> 
    st_as_sf(coords = c("GPSLongitude", "GPSLatitude"), crs = 4326) |> 
    st_write(dsn = paste0(pathimg, ".shp"))

