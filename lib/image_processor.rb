class ImageProcessor

  # For Conversion
  #=> All colors to black except white
  # => convert receipt.jpg -fill black -fuzz 50% +opaque "#ffffff" today_receipt.jpg
  # => convert receipt1.jpg -fill black -fuzz 50% +opaque "#ffffff" today_receipt1.jpg
  # tesseract receipt.jpg receipt
  # tesseract today_receipt.jpg today_receipt
  # tesseract receipt1.jpg receipt1
  # tesseract today_receipt1.jpg today_receipt1

  # Image#opaque_channel(color, fill, opacity, true)

  def initialize(receipt_image)
    @receipt_image = receipt_image
  end

  def extract_text
    e = Tesseract::Engine.new {|e|
      e.language  = :eng
    }
    #img =  Magick::Image.read(@receipt_image.path).first
    `chmod 777 remove_border`
    `./remove_border #{@receipt_image.path}`

#   `convert #{@receipt_image.path} -colorspace Gray -lat 25x25-5% outfile.jpg`

#  `chmod 777 outfile.jpg`
#     initial_file = File.absolute_path("outfile.jpg")
#     binding.pry
#     `convert #{initial_file} -crop \`convert #{@receipt_image.path} -negate -morphology Erode Square -lat 70x70-5% -trim -format '%wx%h%O' info:\`  +repage   cropped.jpg`
#binding.pry
    if File.exists?("cropped.jpg")
      img = File.absolute_path("cropped.jpg")
      extracted_text = e.text_for(img).strip
      if extracted_text.present?
        json_builder = JsonBuilder.new(extracted_text)
        image_json = json_builder.generate_json
        return image_json
        #remove all the temporary images  
      else
        return nil
      end
    else
      return "Something wrong went in script"
    end
  end

  def sanitize_filename
    just_filename = File.basename(@receipt_image.original_filename)
    just_filename.sub(/[^\w\.\-]/,'_')
  end

  def md5_digest
    Digest::MD5.file(@receipt_image.path)
  end

end