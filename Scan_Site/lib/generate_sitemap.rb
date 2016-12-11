#!/usr/bin/env ruby
require 'logger'

class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

def runHandleOptions
  ARGV.each do|a|
    puts "Argument: #{a}"
  end
  statusfile=ARGV[0]
end

def runInitializeLogfile
  log_file = File.open("log/debug.log", "a")
  Logger.new MultiIO.new(STDOUT, log_file)
end



runHandleOptions
runInitializeLogfile
Logger.info("$( date "+%m/%d/%y %H:%M:%S" )")
Logger.info("$( basename "$0" )")
runValidateSetArgs
runMain
runExit