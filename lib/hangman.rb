require 'yaml'
class Hangman
  
  class Game
    def initialize(errors_allowed)
      @secret_word = secret_word().split('')
      secret_word_copy = []
      @secret_word.each{|char| secret_word_copy << char}
      @secret_word_rem = secret_word_copy
      @hits = ("-" * @secret_word.length).split('')
      @misses = []
      remaining = []
      ("a".."z").each{|char| remaining << char}
      @rem_letters = remaining
      @yays = ["Hooray!", "Alright!", "Oh man, great!", "Super!", "Super-Duper!", "Nice!", "Fantastic!", "Excelsior!", "Nice goin'!", "You're the best!", "There ya go!", "Good going!", "Great!", "Whoopee!", "Excellent!",\
        "Radical!", "Magnificent!", "Hey!", "Oh!", "Wow!", "I am so psyched for you!", "That's what I'm talkin' 'bout!", "Way to go!", "That's how we do it!", "You're so smart!", "Clever!", "I knew you knew!"]
      @curses = ["Rats!", "Aw, dang!", "Darnit!", "Gee whiz!", "Well golly gee!", "Jeepers!", "Lord have mercy!", "Well I'll be...", "What in tarnations?", "Confound it!", "Dag-nabbit!", "Curses!", "Fiddlesticks!", "Well wouldn't you just know it.",\
        "Phooey.", "Grumble!", "Shucks.", "Great Googley-Moogley!", "Egads!", "Alas!", "Abandon ship!", "Bah-humbug!", "Really, though?", "I can't even!", "It wasn't supposed to be like this!", "If I had a nickel.."]
      @errors_allowed = errors_allowed
      @guesses = 0
    end
    
    def secret_word()
      file = File.readlines("../data/5desk.txt")
      word_cand = ""
      while ( (word_cand.length < 5) || (word_cand.length > 12) )
        word_cand = file[rand(0..file.length - 1)].chomp.downcase
      end
      word_cand
    end
    
    def check_guess(guess)
      indices = get_secret_word_indices(guess)
    end
    
    def good_guess(guess, indices)
      number_of_letter = indices.length
      if number_of_letter == 1
        to_be_verb = "is"
        plural = ""
      else
        to_be_verb = "are"
        plural = "s"
      end
      random_yay = @yays[rand(0..@yays.length - 1)]
      puts "", "#{random_yay} There #{to_be_verb} #{number_of_letter} \'#{guess}\'#{plural} in the secret word!", "Press enter to continue"
      gets
      indices.each do |index|
        @hits[index] = @secret_word[index]
      end
      (indices.length).times {@secret_word_rem.delete(guess)}

      @rem_letters = @rem_letters.map do |letter|
        if letter == guess
          "-"
        else
          letter
        end
      end
      @guesses += 1
    end
    
    def bad_guess(guess)
      random_curse = @curses[rand(0..@curses.length - 1)]
      puts "", "#{random_curse} There aren't any \'#{guess}\'s in the secret word!", "Press enter to continue"
      gets
      @misses << guess
      @rem_letters = @rem_letters.map do |letter|
        if letter == guess
          "-"
        else
          letter
        end
      end
      @guesses += 1
    end
    
    def get_secret_word_indices(letter)
      indices = []
      @secret_word.each_with_index {|char, index| indices << index if char == letter}
      indices
    end
    
    def sanitize_guess(user_input)
      if ( (/[A-Za-z]/.match(user_input)) && (user_input.length == 1) )
        return user_input.downcase
      elsif ( (user_input == "1") || (user_input == "2") )
        return user_input
      else  
        return :no_good
      end
    end
    
    def already_guessed?(user_input)
      if @rem_letters.include?(user_input)
        return false
      else
        return true
      end
    end
    
    def win_message()
      puts "", "That's a wrap! You win! You conquered the word \'#{@secret_word.join('')}\' in a mere #{@guesses} turns!", "Press enter to continue"
      gets
    end
    
    def lose_message()
      puts "", "Oh no! You didn't quite guess the secret word \'#{@secret_word.join('')}\' in your allowable error allotment of #{@errors_allowed} errors!"
      puts "", "Game over!", "", "Press enter to continue"
      gets
    end
    
    def save_game()
      yaml = YAML::dump(self)
      Dir.mkdir("../save") unless File.exists?("../save")
      File.open("../save/save_game_#{Time.now.strftime('%m-%d-%Y, %H:%M:%S')}.yaml", "w"){|f| f.puts yaml}
      puts "", "Game has been saved!", "Press enter to continue"
      gets
    end
    
    def game_start()
      puts "","Let's play Hangman!"
      while @misses.length < @errors_allowed
        puts "", "#{@misses.length}/#{@errors_allowed} allotted allowable errors"
        puts "Progress: #{@hits.join('')}"
        if @secret_word.join('') == @hits.join('')
          return win_message()
        end  
        puts "Letters remaining to be guessed:", "#{@rem_letters.join(' ')}"
        puts "", "Please enter your guess (one letter), or", "1. Save game", "2. Return to the main menu"
        user_input = gets.chomp
        user_input_san = sanitize_guess(user_input)
        if user_input_san == :no_good
          puts "", "Please try again! One letter for your guess, please.", "Press enter to continue"
          gets
        elsif user_input_san == "1"
          save_game()
        elsif user_input_san == "2"
          return
        elsif already_guessed?(user_input_san)
          puts "", "You've already guessed \'#{user_input}\'! Please try again.", "Press enter to continue"
          gets
        else
          @secret_word.include?(user_input_san) ? good_guess(user_input_san, get_secret_word_indices(user_input_san)) : bad_guess(user_input_san)
        end  
      end
      return lose_message()
    end
  end
  
  def sanitize_errors_allowed(user_input)
    if ( (user_input.to_i.to_s == user_input) && user_input.to_i >= 12 && user_input.to_i <= 18 )
      return user_input.to_i
    else
      return :no_good
    end
  end
  
  def sanitize_menu_option(user_input)
    if user_input.to_i.to_s == user_input && user_input.to_i >= 1 && user_input.to_i <= 4
      return user_input.to_i
    else
      return :no_good
    end
  end 
  
  def get_errors_allowed()
    puts "", "How many errors would you like to allow yourself before reaching a game over?"
    puts "Please enter a number between 12 (difficult) and 18 (easy)."
    loop do
      user_input = gets.chomp
      user_input_san = sanitize_errors_allowed(user_input)
      if user_input_san == :no_good
        puts "Please enter a number from 12 to 18."
      else
        return user_input_san
      end
    end
  end
  
  def sanitize_load_input(user_input, saves)
    if user_input.to_i.to_s == user_input && user_input.to_i >= 0 && user_input.to_i <= saves.length
      return user_input.to_i
    else
      return :no_good
    end
  end
  
  def load_game()
    if File.exists?("../save") && Dir.glob("../save/*").length > 0
      saves = Dir.glob("../save/*")
      puts "", "Please enter a number:", "0. cancel"
      saves.each_with_index do |save, index|
        puts "#{index + 1}. #{File.basename(save).split(".")[0]}"
      end
      loop do
        user_input = gets.chomp
        user_input_san = sanitize_load_input(user_input, saves)
        if user_input_san == :no_good
          puts "Please enter a number corresponding to a saved game, or 0 to cancel and go back."
        elsif user_input_san == 0
          return
        else
          yaml = File.read(saves[user_input_san - 1])
          game = YAML::load(yaml)
          puts "", "Game loaded!"
          game.game_start()
          return
        end
      end
    else
      puts "", "No save game files found!"
    end
  end
      
  def delete_saves()
    puts "", "Are you sure?", "1. Yes, delete all save files.", "2. No, let's not."
    loop do
      user_input = gets.chomp.to_i
      case user_input
      when 1
        saves = Dir.glob("../save/*")
        saves.each {|file| File.delete(file)}
        puts "", "Save data cleared!"
        return
      when 2
        return
      else
        puts "", "Please enter 1 or 2!"
      end
    end
  end
      
  def hangman()
    puts "", "Welcome to generic command-line Hangman!"  
    loop do
      puts "", "Please enter a number:", "1. Start a new game", "2. Load a saved game", "3. Clear saved game files", "4. Exit the program"
      user_input = gets.chomp
      user_input_san = sanitize_menu_option(user_input)
      if user_input_san == :no_good
        puts "", "Please re-enter your menu choice!"
      else
        case user_input_san
        when 1
          errors_allowed = get_errors_allowed()
          game = Game.new(errors_allowed)
          game.game_start()
        when 2
          load_game()
        when 3
          saves = Dir.glob("../save/*")
          if saves.length == 0
            puts "", "I'm afraid there's no data to clear!"
          else
            delete_saves()
          end
        when 4
          puts "", "Thanks for playing!"
          return
        end
      end
    end
  end    
end 

hangman = Hangman.new
hangman.hangman()