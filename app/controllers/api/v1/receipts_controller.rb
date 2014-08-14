class Api::V1::ReceiptsController < ApplicationController
  
  before_filter :restrict_access
  
  def create
    raise CustomError.new("No receipt_image provided", 412) unless params[:receipt_image].present?
    raise CustomError.new("This image type is not allowed", 400) unless validate_image(params[:receipt_image])

    receipt_image   = params[:receipt_image]
    image_processor = ImageProcessor.new(receipt_image)
    filename        = image_processor.sanitize_filename
    receipt_words   = params[:receipt_words]

    raise CustomError.new("The receipt is already processed previously", 400) if already_extracted?(image_processor.md5_digest.to_s)

    if receipt_words.present?
      receipt_words.each do |new_word|
        WORDS_HASH[new_word.downcase] = true
      end
    end

    extracted_text = image_processor.extract_text
    if extracted_text.present?
      receipt = @api_user.receipts.new(extracted_text.merge({:filename => filename, :md5_digest => image_processor.md5_digest.to_s}))
      receipt_image.rewind
      receipt.image = receipt_image
      receipt.save(:validate => false)
      receipt.reload
      @api_user.save(:validate => false)
      render json: extracted_text.merge({:image_url => receipt.image_url, :meta => { :code => 200, :message => "Success" }})
    else
      raise CustomError.new("Something went wrong", 400)
    end
  end

  private

  def validate_image(image)
    extension = image.original_filename.split('.')[1]
    ["jpg", "jpeg", "png", "gif", "tif", "tiff", "bmp"].include? extension.downcase
  end

  def already_extracted?(md5_digest)
    @api_user.receipts.detect{|r| r.md5_digest == md5_digest}.present?
  end

end