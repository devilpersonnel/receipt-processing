WORDS_HASH = {}
File.open("#{Rails.root}/public/dict_words") do |file|
  file.each do |line|
    WORDS_HASH[line.strip.downcase] = true
  end
end