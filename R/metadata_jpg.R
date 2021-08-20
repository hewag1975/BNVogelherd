# extract metadata from jpg files

library(data.table)
library(mapview)
library(exiftoolr)
library(magick)
library(sf)

# install.packages("tesseract")
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
# image_attributes(img)
# image_display(img)

# attempt to extract timestamps printed onto the images
image_read(fls[1]) |> 
    image_crop(geometry = "300x100+610+1900") |> 
    image_convert(colorspace = "gray") |> 
    image_convolve('DoG:0,0,2') |> 
    image_negate() |> 
    image_threshold(type = "black", threshold = "80%") |> 
    image_ocr(language = "eng") 

l = lapply(fls, \(i){
    try({
        image_read(i) |> 
            image_crop(geometry = "300x100+610+1900") |> 
            image_convert(colorspace = "gray") |> 
            image_convolve('DoG:0,0,2') |> 
            image_negate() |> 
            image_threshold(type = "black", threshold = "80%") |> 
            image_ocr(language = "eng") 
    })
})

lapply(l, \(i) {
    try({
        # i = l[[1]]
        i = gsub("/", " ", i)
        i = gsub("\\\n|()[[:punct:]]|()[a-z]|()[A-Z]", " ", i)
        i = gsub("\\s+", " ", i)
        i = trimws(i, which = "both")
        # i = as.POSIXct(i, format = "%Y %m %d %H %M")
        # i = as.character(i)
        return(i)
    })
}) |> 
    unlist()

# exif
meta = exif_read(fls[1], tags = "*GPS*")
grep("File", names(meta), value = TRUE)
exif_call(args = c("-n", "-j", "-q", "-*GPS*"), path = fls[1])
