## extract timestamp from jpg files using ocr ====

## setup ----
# install.packages("tesseract")
library(data.table)
library(magick)

# list all jpgs
fls = list.files("image/2_6c_Baumumfang/"
                 , pattern = "\\.jpg"
                 , full.names = TRUE)

## ocr using magick ----
mdata = exif_read(fls, tags = "*Image*")

i = 16

image_read(fls[i]) |> 
    # resize due to different original extents
    image_resize(geometry = "922x2000") |> 
    # extract area of timestamp
    # image_crop(geometry = "300x50+610+1925") |> 
    image_crop(geometry = "100x50+800+1925") |> 
    image_convert(colorspace = "gray") |> 
    image_negate() |> 
    image_normalize() |> 
    image_quantize(max = 64) |> 
    
    
    image_convolve('DoG:0,0,2') |> 
    # image_negate() |> 
    image_threshold(type = "black", threshold = "80%") |> 
    image_ocr(language = "eng") 

l_ocr = lapply(fls, \(i){
    try({
        image_read(i) |> 
            image_resize(geometry = "922x2000") |> 
            image_crop(geometry = "300x50+610+1925") |> 
            image_convert(colorspace = "gray") |> 
            image_convolve('DoG:0,0,2') |> 
            image_negate() |> 
            image_threshold(type = "black", threshold = "80%") |> 
            image_ocr(language = "eng") 
    })
})

v_ocr = lapply(l_ocr, \(i) {
    try({
        # i = l[[1]]
        i = gsub("/", " ", i)
        i = gsub("\\\n|()[[:punct:]]|()[a-z]|()[A-Z]", " ", i)
        i = gsub("\\s+", " ", i)
        i = trimws(i, which = "both")
        return(i)
    })
}) |> 
    unlist()

datetime = data.table(file = basename(fls)
                      , dt_ocr = v_ocr)

datetime[, dt := dt_ocr]
datetime[, dt := gsub("202117122", "2021 7 22", dt)]
datetime[, dt := gsub("202177122", "2021 7 22", dt)]
datetime[, dt := gsub("22 0 16", "22 10 16", dt)]
datetime[, dt := gsub("7122", "7 22", dt)]
datetime[, dt := as.POSIXct(dt, format = "%Y %m %d %H %M")]

datetime |> 
    readr::write_excel_csv2(file = "data/jpg_ocr.csv"
                            , na = ""
                            , col_names = TRUE)
