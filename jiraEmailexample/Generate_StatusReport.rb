require 'erb'
require 'json'
require 'Date'
require 'rest-client'
require 'mail'

# source in secrets
File.readlines("#{ENV["HOME"]}/.password/statusfile").each do |line|
  key, value  = line.split('=',2)
  ENV[key] = value.strip
end

# ENV['email_name']
# ENV['email_password']
# ENV['domain']
# ENV['jira_name']
# ENV['jira_password']
# ENV['manager']
# ENV['jira_site']
# ENV['systemdashboardURL']
# ENV['extraLine']
# every 5 min cron job
# LANG="en_GB.UTF-8"
# 0 15 * * 4 /usr/bin/ruby /Users/jaminshanti/RubymineProjects/statusReport/Generate_StatusReport.rb

Mail.defaults do
  delivery_method :smtp, { :address              => 'smtp.office365.com',
                           :port                 =>  587,
                           :domain               =>  ENV['domain'],
                           :user_name            =>  ENV['email_name'],
                           :password             =>  ENV['email_password'],
                           :authentication       => 'login',
                           :enable_starttls_auto => true  }
end

# last Sunday
lastsunday = (Date.today - ((Date.today.wday - 0) % 7)).strftime("%A, %b %d %Y")
# email address
emailAddress = ENV['email_name']
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


To_Do = ['Open','ReOpened','Approved','Defined','Design Complete']
In_Progress = ['In_Progress','Dev Active','Dev Complete']
Complete = ['Resolved','Rejected','Cancelled','Closed']

def statuscolumn(status)
  case
    when To_Do.include?(status)
      columnname = "To Do"
    when In_Progress.include?(status)
      columnname = "In Progress"
    when Complete.include?(status)
      columnname = "Completed"
    else columnname = status
  end
  return columnname
end

encoded_url_dashboard = URI.encode("https://#{ENV['jira_name']}:#{ENV['jira_password']}@#{ENV['jira_site']}/#{ENV['systemdashboardURL']}")

systemdashboard = JSON.parse(RestClient.get encoded_url_dashboard ,{:accept => :json})

workitems = systemdashboard['issuesData']['issues']

worklist = []

workitems.each do |item|
   subtasks = []
   encoded_url_issue = URI.encode("https://#{ENV['jira_name']}:#{ENV['jira_password']}@#{ENV['jira_site']}/rest/api/2/search?jql=issue=#{item['key']}")
   worklist.push("<a href=https://#{ENV['jira_site']}/browse/#{item['key']}>#{item['key']}</a>" + '&emsp;' + statuscolumn(item['status']['name'].to_s)  + '&emsp;' + item['summary'] + '&emsp;' + item['extraFields'][1]['html'])
   worklist.push( "<font color=\"red\">Blocked</font>") if item["flagged"]
   remotejson = JSON.parse(RestClient.get encoded_url_issue , {:accept => :json})
   subtasks = remotejson['issues'][0]['fields']['subtasks']
   subtasks.each do |subitem|
   worklist.push('&emsp;' + 'SubTask:' + '  ' + "<a href=https://#{ENV['jira_site']}/browse/#{subitem['key']}>#{subitem['key']}</a>" + '&emsp;'+ subitem['fields']['status']['name'] + '&emsp;' + subitem['fields']['summary'] ) if not ['Closed','Resolved',"Open"].include?(subitem['fields']['status']['name'])
   end
end

template_file = File.open('Status_Report_Template.erb', 'r').read
erb = ERB.new(template_file)

File.open("emailbody.html", 'w+') { |file| file.write(erb.result(binding)) }

Mail.deliver do
  from      ENV['email_name']
  to        ENV['manager']
  subject  "Status Report #{lastsunday}"
  html_part do
    content_type 'text/html; charset=UTF-8'
    body     File.read('emailbody.html')
  end
end
