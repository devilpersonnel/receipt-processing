class AccuracyChecker
  attr_accessor :words, :accuracy

  def initialize(extracted_text)
    @text = extracted_text
    @words = WORDS_HASH
  end

  def calculate_accuracy
    extracted_words = @text.gsub(/\d+/, '').split(/\W+/)
    total_words     = extracted_words.count
    match_count     = 0.0
    extracted_words.each do |w|
      if @words[w.downcase]
        match_count += 1
      end
    end
    @accuracy = match_count/total_words * 100
  end

end