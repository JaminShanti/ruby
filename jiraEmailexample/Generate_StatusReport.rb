require 'erb'
require 'json'
require 'date'
require 'rest-client'
require 'mail'
require 'logger'
require 'set'
require 'dotenv/load'
require 'uri'

logger = Logger.new(STDOUT)
logger.datetime_format = '%Y-%m-%d %H:%M:%S:%3N'
logger.info('initialize') { "Initializing..." }

ARGV.each do |a|
  puts "Argument: #{a}"
end

statusfile = ARGV[0] || 'statusfile'

# Script Default Values
mailserver = ENV['MAILSERVER'] || 'email-smtp.us-west-2.amazonaws.com'
authentication_type = ENV['AUTHENTICATION_TYPE'] || 'login'

to_do = ['Open', 'ReOpened', 'Approved', 'Defined', 'Design Complete']
in_progress = ['In_Progress', 'Dev Active', 'Dev Complete']
complete = %w(Resolved Rejected Cancelled Closed)
worklist = []

logger.debug { "email_name set to #{ENV['EMAIL_NAME']}" }
logger.debug { "email_address set to #{ENV['EMAIL_ADDRESS']}" }
logger.debug { "domain set to #{ENV['DOMAIN']}" }
logger.debug { "jira_name set to #{ENV['JIRA_NAME']}" }
logger.debug { "manager set to #{ENV['MANAGER']}" }
logger.debug { "jira_site set to #{ENV['JIRA_SITE']}" }
logger.debug { "systemdashboardURL set to #{ENV['SYSTEMDASHBOARD_URL']}" }
logger.debug { "extraLine set to #{ENV['EXTRA_LINE']}" }
logger.debug { "displayName set to #{ENV['DISPLAY_NAME']}" }
logger.debug { "jobTitle set to #{ENV['JOB_TITLE']}" }
logger.debug { "cellNumber set to #{ENV['CELL_NUMBER']}" }
logger.debug { "workNumber set to #{ENV['WORK_NUMBER']}" }

logger.info { 'Initalizing Mail Delivery...' }

Mail.defaults do
  delivery_method :smtp, {
    :address => mailserver,
    :port => 587,
    :user_name => ENV['EMAIL_NAME'],
    :password => ENV['EMAIL_PASSWORD'],
    :authentication => authentication_type,
    :enable_starttls_auto => true
  }
end

# last Sunday
lastsunday = (Date.today - ((Date.today.wday - 0) % 7)).strftime('%A, %b %d %Y')
# email address
email_address = ENV['EMAIL_ADDRESS']
# display Name
display_name = ENV['DISPLAY_NAME']
# job Title
job_title = ENV['JOB_TITLE']
# cell Number
cell_number = ENV['CELL_NUMBER']
# Work Number
work_number = ENV['WORK_NUMBER']
# extra Line
extra_line = ENV['EXTRA_LINE'].to_s.empty? ? "<a href=\"\">none</a>" : ENV['EXTRA_LINE']

logger.info { 'Initilize statuscolumn...' }

def statuscolumn(status, to_do, in_progress, complete)
  case
  when to_do.include?(status)
    'To Do'
  when in_progress.include?(status)
    'In Progress'
  when complete.include?(status)
    'Completed'
  else
    status
  end
end

logger.info { 'encode URL dashboard...' }
logger.debug { "Attmepting https://#{ENV['JIRA_NAME']}:REMOVE_PASSWORD@#{ENV['JIRA_SITE']}/#{ENV['SYSTEMDASHBOARD_URL']}"}
encoded_url_dashboard = URI::DEFAULT_PARSER.escape("https://#{ENV['JIRA_NAME']}:#{ENV['JIRA_PASSWORD']}@#{ENV['JIRA_SITE']}/#{ENV['SYSTEMDASHBOARD_URL']}")
logger.info { 'parse RestClient via json...' }
systemdashboard = JSON.parse(RestClient.get(encoded_url_dashboard, {:accept => :json}))

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
  logger.info { "Checking http://#{ENV['JIRA_SITE']}/rest/api/2/search?jql=issue=#{item['key']}" }
  encoded_url_issue = URI::DEFAULT_PARSER.escape("https://#{ENV['JIRA_NAME']}:#{ENV['JIRA_PASSWORD']}@#{ENV['JIRA_SITE']}/rest/api/2/search?jql=issue=#{item['key']}")
  logger.info { "worklist.push..." }
  worklist.push("<a href=https://#{ENV['JIRA_SITE']}/browse/#{item['key']}>#{item['key']}</a>" + '&emsp;' + statuscolumn(item['status']['name'].to_s, to_do, in_progress, complete) + '&emsp;' + item['summary'] + '&emsp;' + item['customfield_10004'].to_s)
  logger.info { "worklist.push flags..." }
  worklist.push("<font color=\"red\">Blocked</font>") if item['flagged']
  logger.info { "parse remotejson..." }
  remotejson = JSON.parse(RestClient.get(encoded_url_issue, {:accept => :json}))
  logger.info { "review subtasks..." }
  subtasks = remotejson['issues'][0]['fields']['subtasks']
  subtasks.each do |subitem|
    unless ['Closed', 'Resolved', 'Open', 'Need Info', 'Cancelled'].include?(subitem['fields']['status']['name'])
      worklist.push('&emsp;' + 'SubTask:' + '  ' + "<a href=https://#{ENV['JIRA_SITE']}/browse/#{subitem['key']}>#{subitem['key']}</a>" + '&emsp;'+ subitem['fields']['status']['name'] + '&emsp;' + subitem['fields']['summary'])
    end
  end
end

logger.info { 'initalize Staus_Report_Template.erb...' }
template_file = File.read('Status_Report_Template.erb')
erb = ERB.new(template_file)

logger.info { 'initalize emailbody.html...' }
File.open('emailbody.html', 'w+') { |file| file.write(erb.result(binding)) }

logger.info { 'Sending Email...'}
Mail.deliver do
   from 'devops@gmail.com'
   to ENV['MANAGER']
   subject "Status Report #{lastsunday} #{display_name}"
   html_part do
     content_type 'text/html; charset=UTF-8'
     body File.read('emailbody.html')
   end
 end

logger.info { 'Generate_StatusReport Completed Successfully...' }
logger.close
