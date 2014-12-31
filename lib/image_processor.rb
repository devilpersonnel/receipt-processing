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
    img =  Magick::Image.read(@receipt_image.path).first
    if img.filesize < 200000
      img.change_geometry!("#{img.columns}x") { |cols, rows, img|
        img.resize!(cols*3, rows*3, Magick::UndefinedFilter).quantize(256, Magick::GRAYColorspace).contrast(true)
      }
    end
    img.density = "300x300"
    img.format = "TIFF"
    img.fuzz = "50%"
    img = img.opaque_channel("#ffffff","#000000",true)
    extracted_text = e.text_for(img).strip
    if extracted_text.present?
      json_builder = JsonBuilder.new(extracted_text)
      image_json = json_builder.generate_json
      return image_json
    else
      return nil
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