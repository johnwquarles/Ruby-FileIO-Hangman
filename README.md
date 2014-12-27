Ruby-FileIO-Hangman
============

Hangman game made in Ruby for the Odin Project: http://www.theodinproject.com/ruby-programming/file-i-o-and-serialization?ref=lc-pb#

The idea behind making this game was to utilize Ruby's File IO methods-- pulling a secret word randomly from a giant list of words, for example, and saving the user's game via object serialization.

I accomplished the latter using yaml.

At the moment you're able to save and load your game to one save slot. I'd like to expand on this and let the user create/load multiple saves.