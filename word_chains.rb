require 'set'

class WordChainer
  def initialize(dictionary_file_name)
    @dictionary = Set.new(File.readlines(dictionary_file_name).map(&:chomp))
    @words_of_a_particular_length = Hash.new
  end

  def adjacent_words(word)
    possible_words = filter_by_length(word.length)

    possible_words.select do |possibility|
      non_matches = 0
      possibility.split("").each_with_index do |letter, idx|
        non_matches += 1 if letter != word[idx]
        break if non_matches > 1
      end
      non_matches == 1
    end
  end

  def filter_by_length(length)
    @words_of_a_particular_length[length] ||=
      @dictionary.select { |word| word.length == length }
  end

  def run(source, target)
    @current_words = [source]
    @all_seen_words = { source => nil }

    until @current_words.empty?
      @current_words = explore_current_words(target)
      break if @all_seen_words.include?(target)
    end

    puts build_path(target)
  end

  def explore_current_words(target)
    new_current_words = []

    @current_words.each do |current_word|
      adjacent_words(current_word).each do |adjacent_word|
        next if @all_seen_words.include?(adjacent_word)
        new_current_words << adjacent_word
        @all_seen_words[adjacent_word] = current_word
        return new_current_words if current_word == target
      end
    end

    new_current_words
  end

  def build_path(target)
    path = []
    current_word = target

    until @all_seen_words[current_word].nil?
      path.unshift(current_word)
      current_word = @all_seen_words[current_word]
    end

    path.unshift(current_word)

    path
  end
end
