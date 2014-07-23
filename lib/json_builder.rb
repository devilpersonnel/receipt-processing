class JsonBuilder
  attr_accessor :lines, :accuracy

  def initialize(extracted_text)
    @text       = extracted_text
    @lines      = @text.split /[\r\n]+/ # ignores blank lines like \r\n\r\n
    @accuracy   = 0
  end

  def generate_json
    check_accuracy
    data = Hash.new
    data[:totalLines]   = @lines.count
    data[:accuracy]     = "#{check_accuracy}%"
    data[:lines]        = lines_with_index(@lines)
    return data
  end

  def lines_with_index(lines)
    lines_array = []
    lines.each_with_index do |text, index|
      lines_array << { :line => "#{index}", :text => "#{text}" }
    end
    return lines_array
  end

  def check_accuracy
    accuracy_checker = AccuracyChecker.new(@text)
    @accuracy = accuracy_checker.calculate_accuracy.round(2)
  end

end