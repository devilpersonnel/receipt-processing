class ImageProcessor
  require 'tesseract'
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
    # image_json = nil
    secure_hex = SecureRandom.hex
    tmp_folder_path = Rails.root.join('tmp').to_s
    cleaned_image_path = Rails.root.join('tmp', "cropped-#{secure_hex}.jpg").to_s
    cleaner_path = Rails.root.join('bash_script', 'textcleaner').to_s

    create_tmp_directory = Cocaine::CommandLine.new("mkdir", "-p :tmp_folder_path")
    p create_tmp_directory.run(tmp_folder_path: tmp_folder_path)
    # => "mkdir /tmp"

    e = Tesseract::Engine.new {|e| e.language  = :eng }

    #cleaning up image
    args = "-e normalize -f 15 -o 5 -S 400"

    p args
    p Cocaine::CommandLine.new(cleaner_path, "#{args} :in :out").run(in: @receipt_image.path, out: cleaned_image_path)


    # convert image to grayscale

    graysclaed_image_path = Rails.root.join('tmp', "grayscaled-#{secure_hex}.jpg").to_s
    args = "-colorspace Gray -gamma 2.2"
    p Cocaine::CommandLine.new("convert", "#{args} :in :out").run(in: cleaned_image_path, out: graysclaed_image_path)

    # blured image 2 times
    blured_image_path = Rails.root.join('tmp', "blured-#{secure_hex}.jpg").to_s
    args = "-blur 0x2"
    p Cocaine::CommandLine.new("convert", "#{args} :in :out").run(in: graysclaed_image_path, out: blured_image_path)

    # Now divide the blurred image and greyed image with each other.
    normalized_image_path = Rails.root.join('tmp', "normalized-#{secure_hex}.jpg").to_s
    # convert text_scan.png \( +clone -blur 0x20 \) \
    #       -compose Divide_Src -composite  text_scan_divide.png
    # args = "-compose ColorDodge -composite"
    # p Cocaine::CommandLine.new("convert", "#{args} :in :out").run(in: blured_image_path, out: graysclaed_image_path)



    if File.exists?(blured_image_path)
      img = File.absolute_path(blured_image_path)
      extracted_text = e.text_for(img).strip
      if extracted_text.present?
        # extracted_text = extracted_text.gsub(/[^\p{Alnum} & % . * $]/, '')
        json_builder = JsonBuilder.new(extracted_text)
        image_json = json_builder.generate_json
        image_json
      end
    end

    delete_images = Cocaine::CommandLine.new("rm", ":path")
    # p delete_images.run(path: cleaned_image_path)
    # => "rm /tmp/cleanedimage-hex.jpg"

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