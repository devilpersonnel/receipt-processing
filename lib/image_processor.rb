class ImageProcessor

  def initialize(receipt_image)
    @receipt_image = receipt_image
  end

  def extract_text
    e = Tesseract::Engine.new {|e|
      e.language  = :eng
    }
    img =  Magick::Image.read(@receipt_image.path).first
    if img.filesize < 1048576
      img.change_geometry!("#{img.columns}x") { |cols, rows, img|
        img.resize!(cols*3, rows*3, Magick::UndefinedFilter).quantize(256, Magick::GRAYColorspace).contrast(true)
      }
    end
    img.format = "JPEG" if img.format == "GIF" || img.format == "TIFF" || img.format == "BMP"
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