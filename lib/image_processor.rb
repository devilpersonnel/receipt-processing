class ImageProcessor
  require 'tesseract'
  require 'rtesseract'
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
    @secure_hex = SecureRandom.hex
    tmp_folder_path = Rails.root.join('tmp').to_s

    create_tmp_directory = Cocaine::CommandLine.new("mkdir", "-p :tmp_folder_path")
    p create_tmp_directory.run(tmp_folder_path: tmp_folder_path)
    # => "mkdir /tmp"

    cleaned_image_path=clean_the_image(@receipt_image.path)
    grayscale_the_image(cleaned_image_path)

    if File.exists?(@tiff_image_path)
      extracted_text = image_to_text(@tiff_image_path)
      extracted_text = compare(extracted_text)
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

  def image_to_text(image)
    text = RTesseract.read(image){|img| img=img}
    clean_the_text(text.to_s)
  end

  def clean_the_text(text)
    text.gsub(/[^$\/0-9A-Za-z\n]/,' ')
  end
  def compare(text)
    accuracy_of_processed_image = check_accuracy(text)
    grayscale_the_image(@receipt_image.path)
    text_of_unprocessed_image = image_to_text(@tiff_image_path)
    accuracy_of_unprocessed_image = check_accuracy(text_of_unprocessed_image)
    accuracy_of_processed_image > accuracy_of_unprocessed_image ? text : text_of_unprocessed_image
  end

  def check_accuracy(text)
    accuracy_checker = AccuracyChecker.new(text)
    accuracy_checker.calculate_accuracy.round(2)
  end

  def clean_the_image(image_path)
    cleaned_image_path = Rails.root.join('tmp', "cropped-#{@secure_hex}.jpg").to_s
    cleaner_path = Rails.root.join('bash_script', 'textcleaner').to_s
    #cleaning up image
    args = '-e normalize -f 25 -o 10 -t 50'
    # -g -f 20 -o 10 -t 50
    p args
    p Cocaine::CommandLine.new(cleaner_path, "#{args} :in :out").run(in: image_path, out: cleaned_image_path)
    cleaned_image_path
  end

  def grayscale_the_image(image_path)
    grayscaled_image_path = Rails.root.join('tmp', "grayscaled-#{@secure_hex}.png").to_s
    args = "-colorspace Gray -unsharp 6.8x7.8+2.69+0 -quality 100"
    p Cocaine::CommandLine.new("convert", "#{args} :in :out").run(in: image_path, out: grayscaled_image_path)
    @tiff_image_path = Rails.root.join('tmp',"tiff-#{@secure_hex}.tiff").to_s
    p Cocaine::CommandLine.new("convert", ":in :out").run(in: grayscaled_image_path, out: @tiff_image_path)
  end


end