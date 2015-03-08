#!/usr/bin/ruby
#########################################################################
#     ####    #   #          #####  #           #   #  ####   #####     #
#     #   #    # #          #        #   # #   #    #  #   #  #         #
#     ####      #     ###    ####     #   #   #     #  ####   ###       #
#     # #      # #               #     # # # #      #  #      #         #
#     #  #    #   #         #####       #   #       #  #      #####     #
#########################################################################
# This is the Ruby version of xSwipe (written in Perl).                 #
# It uses an external Perl script in order to simulate X11 interactions #
#########################################################################

Dir.chdir File.dirname(__FILE__)

load "Utils.rb"
load "Config.rb"
load "InputController.rb"
load "InputHandler.rb"
load "ActionHandler.rb"
load "MainController.rb"

runDaemon = ARGV.include?("-d") || ARGV.include?("--daemon")
run = ARGV.include?("-r") || ARGV.include?("--run")
$debug = ARGV.include?("-D") || ARGV.include?("--debug")

MainController.new.main(runDaemon) if run
