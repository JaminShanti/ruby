require 'erb'
require 'json'
require 'date'
require 'rest-client'
require 'mail'
require 'logger'
require 'set'

logger = Logger.new(STDERR)
logger = Logger.new(STDOUT)
logger.datetime_format = '%Y-%m-%d %H:%M:%S:%3N'
logger.info('initialize') { "Initializing..." }


ARGV.each do |a|
  puts "Argument: #{a}"
end


statusfile=ARGV[0]

unless statusfile
  statusfile ='statusfile'
end

ENV['email_name'] = nil
ENV['email_password'] = nil
ENV['email_address'] = nil
ENV['domain'] = nil
ENV['jira_name'] = nil
ENV['jira_password'] = nil
ENV['manager'] = nil
ENV['jira_site'] = nil
ENV['systemdashboardURL'] = nil
ENV['extraLine'] = nil

# Script Default Values
#Mailserver='smtp.office365.com'
#Mailserver='smtp.gmail.com'
Mailserver='email-smtp.us-west-2.amazonaws.com'
authenticationType='login'
#authenticationType='plain'
To_Do = ['Open', 'ReOpened', 'Approved', 'Defined', 'Design Complete']
In_Progress = ['In_Progress', 'Dev Active', 'Dev Complete']
Complete = %w(Resolved Rejected Cancelled Closed)
worklist = []


# source in secrets
File.readlines("#{ENV['HOME']}/.password/#{statusfile}").each do |line|
  key, value = line.split('=', 2)
  ENV[key] = value.strip
end

logger.debug { "email_name set to #{ENV['email_name']}" }
logger.debug { "email_address set to #{ENV['email_address']}" }
logger.debug { "domain set to #{ENV['domain']}" }
logger.debug { "jira_name set to #{ENV['jira_name']}" }
logger.debug { "domain set to #{ENV['domain']}" }
logger.debug { "manager set to #{ENV['manager']}" }
logger.debug { "jira_site set to #{ENV['jira_site']}" }
logger.debug { "systemdashboardURL set to #{ENV['systemdashboardURL']}" }
logger.debug { "extraLine set to #{ENV['extraLine']}" }
logger.debug { "displayName set to #{ENV['displayName']}" }
logger.debug { "jobTitle set to #{ENV['jobTitle']}" }
logger.debug { "cellNumber set to #{ENV['cellNumber']}" }
logger.debug { "workNumber set to #{ENV['workNumber']}" }


logger.info { 'Initalizing Mail Delivery...' }

Mail.defaults do
  delivery_method :smtp, {:address => Mailserver,
                          :port => 587,
                          #:domain               =>  ENV['domain'],
                          :user_name => ENV['email_name'],
                          :password => ENV['email_password'],
                          :authentication => authenticationType,
                          :enable_starttls_auto => true}
end

# last Sunday
lastsunday = (Date.today - ((Date.today.wday - 0) % 7)).strftime('%A, %b %d %Y')
# email address
emailAddress = ENV['email_address']
# display Name
displayName = ENV['displayName']
# job Title
jobTitle = ENV['jobTitle']
# cell Number
cellNumber = ENV['cellNumber']
# Work Number
workNumber = ENV['workNumber']
#extra Line
if ENV['extraLine'].to_s == ''
  extraLine="<a href=\"\">none</a>"
else
  extraLine = ENV['extraLine']
end


logger.info { 'Initilize statuscolumn...' }


def statuscolumn(status)
  case
    when To_Do.include?(status)
      columnname = 'To Do'
    when In_Progress.include?(status)
      columnname = 'In Progress'
    when Complete.include?(status)
      columnname = 'Completed'
    else
      columnname = status
  end
  columnname
end

logger.info { 'encode URL dashboard...' }
logger.debug { "Attmepting https://#{ENV['jira_name']}:REMOVE_PASSWORD@#{ENV['jira_site']}/#{ENV['systemdashboardURL']}"}
encoded_url_dashboard = URI.encode("https://#{ENV['jira_name']}:#{ENV['jira_password']}@#{ENV['jira_site']}/#{ENV['systemdashboardURL']}")
logger.info { 'parse RestClient via json...' }
# noinspection RubyInterpreterInspection
systemdashboard = JSON.parse(RestClient.get encoded_url_dashboard, {:accept => :json})

logger.info {' Collecting SwimlanesData'}
swimlaneitems = systemdashboard['swimlanesData']['customSwimlanesData']['swimlanes'][0]['issueIds']
ids = Set.new(swimlaneitems)
logger.debug {"swimlaneitems list is #{swimlaneitems}"}

logger.info { 'define workitems...' }
workitems = systemdashboard['issuesData']['issues']
filteredworkitems = workitems.select{ |h| ids.include?(h['id']) }

logger.info { 'generate Workitems to include for User...' }

filteredworkitems.each do |item|
  subtasks = []
  logger.info { "Checking http://#{ENV['jira_site']}/rest/api/2/search?jql=issue=#{item['key']}" }
  encoded_url_issue = URI.encode("https://#{ENV['jira_name']}:#{ENV['jira_password']}@#{ENV['jira_site']}/rest/api/2/search?jql=issue=#{item['key']}")
  logger.info { "worklist.push..." }
  worklist.push("<a href=https://#{ENV['jira_site']}/browse/#{item['key']}>#{item['key']}</a>" + '&emsp;' + statuscolumn(item['status']['name'].to_s) + '&emsp;' + item['summary'] + '&emsp;' + item['customfield_10004'].to_s)
  logger.info { "worklist.push flags..." }
  worklist.push("<font color=\"red\">Blocked</font>") if item['flagged']
  logger.info { "parse remotejson..." }
  remotejson = JSON.parse(RestClient.get encoded_url_issue, {:accept => :json})
  logger.info { "review subtasks..." }
  subtasks = remotejson['issues'][0]['fields']['subtasks']
  subtasks.each do |subitem|
    worklist.push('&emsp;' + 'SubTask:' + '  ' + "<a href=https://#{ENV['jira_site']}/browse/#{subitem['key']}>#{subitem['key']}</a>" + '&emsp;'+ subitem['fields']['status']['name'] + '&emsp;' + subitem['fields']['summary']) unless ['Closed', 'Resolved', 'Open', 'Need Info', 'Cancelled'].include?(subitem['fields']['status']['name'])
  end
  end

logger.info { 'initalize Staus_Report_Template.erb...' }
template_file = File.open('Status_Report_Template.erb', 'r').read
erb = ERB.new(template_file)

logger.info { 'initalize emailbody.html...' }
File.open('emailbody.html', 'w+') { |file| file.write(erb.result(binding)) }

logger.info { 'Sending Email...'}
Mail.deliver do
   from 'devops@gmail.com'
   to ENV['manager']
   subject "Status Report #{lastsunday} #{displayName}"
   html_part do
     content_type 'text/html; charset=UTF-8'
     body File.read('emailbody.html')
   end
 end

logger.info { 'Generate_StatusReport Completed Successfully...' }
logger.close
