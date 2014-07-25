class Api::V1::ReceiptsController < ApplicationController
  
  before_filter :restrict_access
  
  def create
    raise CustomError.new("No receipt_image provided", 412) unless params[:receipt_image].present?
    raise CustomError.new("This image type is not allowed", 400) unless validate_image(params[:receipt_image])

    receipt_image   = params[:receipt_image]
    image_processor = ImageProcessor.new(receipt_image)
    filename        = image_processor.sanitize_filename
    # receipt_words   = params[:receipt_words]

    raise CustomError.new("The receipt is already processed previously", 400) if already_extracted?(image_processor.md5_digest.to_s)

    receipt_image.rewind
    AWS::S3::S3Object.store(filename, receipt_image.read, ENV['BUCKET_NAME'], :access => :public_read)
    image_url = AWS::S3::S3Object.url_for(filename, ENV['BUCKET_NAME'], :authenticated => false)

    # receipt_words.split(',').each do |new_word|
    #   WORDS_HASH[new_word.downcase] = true
    # end

    extracted_text = image_processor.extract_text
    if extracted_text.present?
      @api_user.receipts << Receipt.new(extracted_text.merge({:filename => filename, :md5_digest => image_processor.md5_digest.to_s, :image_url => image_url}))
      @api_user.save(:validate => false)
      render json: extracted_text.merge({:meta => { :code => 200, :message => "Success" }})
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