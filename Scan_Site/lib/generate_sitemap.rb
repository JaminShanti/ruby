#!/usr/bin/env ruby
require 'erb'
require 'json'
require 'date'
require 'rest-client'
require 'socket'

# Script Defaults
myLogFile='siteMap.log'
applicationUser=ENV['USER']
HOST=Socket.gethostname
debug=false
siteURL= nil
####################################################################################
#
# Verbose Logger
#
####################################################################################
def run_Log_Print(logMessage,logLevel)

# logging function for ERROR, WARN, INFO, and DEBUG
{
    # Throws Log Statement if not classified as ERROR Level.
    if logLevel == ''
      logLevel = 'ERROR'
    end
    if (logLevel != 'DEBUG') || (debug)
           puts " #{DateTime.parse(time).strftime('%m/%d/%y %H:%M:%S')}  #{logLevel}   #{HOST}   #{applicationUser}   #{logMessage}"
    end
    open("#{myLogFile}", 'w') { |f|
        f.puts  "#{DateTime.parse(time).strftime('%m/%d/%y %H:%M:%S')}  LEVEL=#{logLevel}  HOST=#{HOST}  APPLICATION-USER=#{applicationUser}  APPLICATION=#{$PROGRAM_NAME}  MESSAGE=#{logMessage}"
     }
 end

def runHandleOptions
  ARGV.each do|a|
    puts "Argument: #{a}"
  end
  siteURL=ARGV[0]
end

def runInitializeLogfile
  puts"Create #{myLogFile}"
end



runHandleOptions
runInitializeLogfile
run_Log_Print "#{DateTime.parse(time).strftime('%m/%d/%y %H:%M:%S')}", 'INFO'
run_Log_Print "#{$PROGRAM_NAME}",'INFO'
runValidateSetArgs
runMain
runExit