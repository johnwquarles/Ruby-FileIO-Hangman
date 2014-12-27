Ruby-FileIO-Hangman
============

Hangman game made in Ruby for the Odin Project: http://www.theodinproject.com/ruby-programming/file-i-o-and-serialization?ref=lc-pb#

The idea behind making this game was to utilize Ruby's File IO methods-- pulling a secret word randomly from a giant list of words, for example, and saving the user's game via object serialization.

The latter has been accomplished by using yaml.

Users are able to save multiple times and choose which save they'd like to load from a menu. They may also delete all save files from an option in the main menu.