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
    image_json = nil
    secure_hex = SecureRandom.hex
    tmp_folder_path = "#{Rails.root.join('tmp'+secure_hex)}"
    resized_image_path = "#{Rails.root.join(('tmp'+secure_hex), ('resized'+secure_hex+'.jpg'))}"
    polished_image_path = "#{Rails.root.join(('tmp'+secure_hex), ('polished'+secure_hex+'.jpg'))}"
    cropped_image_path = "#{Rails.root.join(('tmp'+secure_hex),('cropped'+secure_hex+'.jpg'))}"

    create_tmp_directory = Cocaine::CommandLine.new("mkdir", "-p :tmp_folder_path")
    p create_tmp_directory.run(tmp_folder_path: tmp_folder_path)
    # => "mkdir /tmp"

    e = Tesseract::Engine.new {|e|
      e.language  = :eng
    }

    resize_img = Cocaine::CommandLine.new("convert", ":in -resize 1000 :out")
    p resize_img.run(in: @receipt_image.path,
     out: resized_image_path)
    # => convert <image_path> -resize 1200 resized.jpg

    polish_image = Cocaine::CommandLine.new("convert", ":in -colorspace Gray -lat 25x25-5% :out")
    p polish_image.run(in: resized_image_path,
     out: polished_image_path)
    # => "convert <image_path> -colorspace Gray -lat 25x25-5% polished.jpg"

    trim_image = Cocaine::CommandLine.new("convert", ":polished -crop `convert :original_image -colorspace Gray -negate -morphology Erode Square -lat 70x70-5% -trim -format :crop_info_format info:` +repage :cropped_path")
    p trim_image.run(polished: polished_image_path,
      original_image: @receipt_image.path,
      crop_info_format: "%wx%h%O",
      cropped_path: cropped_image_path
      )
    # => "convert outfile.jpg -crop `convert $1 -colorspace Gray -negate -morphology Erode Square -lat 70x70-5% -trim -format '%wx%h%O' info:` +repage cropped.jpg"

    if File.exists?(cropped_image_path)
      img = File.absolute_path(cropped_image_path)
      extracted_text = e.text_for(img).strip
      if extracted_text.present?
        json_builder = JsonBuilder.new(extracted_text)
        image_json = json_builder.generate_json
        image_json
      end
    end

    delete_images = Cocaine::CommandLine.new("rm", "-rf :tmp_folder_path")
    p delete_images.run(tmp_folder_path: tmp_folder_path)
    # => "rm -rf /tmp"

    if image_json.present?
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