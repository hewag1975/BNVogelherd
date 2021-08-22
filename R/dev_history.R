## 2021-08-22

# vary extracted area for OCR based on image size
library(data.table)
library(exiftoolr)
library(magick)

# list all jpgs
fls = list.files("image/2_6c_Baumumfang/"
                 , pattern = "\\.jpg"
                 , full.names = TRUE)

mdata = exif_read(fls, tags = "*Image*")

i = 3
w = mdata[i, "ImageWidth"]
h = mdata[i, "ImageHeight"]
geomstring = paste0("300x100+", w - 310, "+", h - 100)

image_read(fls[i]) |> 
    image_crop(geometry = geomstring) |> 
    image_convert(colorspace = "gray") |> 
    image_convolve('DoG:0,0,2') |> 
    image_negate() |> 
    image_threshold(type = "black", threshold = "80%") 
    # image_ocr(language = "eng") 

