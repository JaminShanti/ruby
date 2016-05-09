require 'erb'
require 'json'
require 'Date'
require 'rest-client'
require 'mail'

# source in secrets
File.readlines("/Users/jaminshanti/.password/passwordfile").each do |line|
  key, value  = line.split("=")
  ENV[key] = value.strip
end

# ENV['email_name']
# ENV['email_password']
# ENV['domain']
# ENV['jira_name']
# ENV['jira_password']
# ENV['manager']
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


systemdashboard = JSON.parse(RestClient.get "https://#{ENV['jira_name']}:#{ENV['jira_password']}@belkdev.atlassian.net/rest/greenhopper/1.0/xboard/work/allData.json?rapidViewId=142&selectedProjectKey=TID&activeQuickFilters=637", {:accept => :json})

workitems = systemdashboard['issuesData']['issues']

worklist = []

workitems.each do |item|
   subtasks = []
   worklist.push("<a href=https://belkdev.atlassian.net/browse/#{item['key']}>#{item['key']}</a>" + '&emsp;' + statuscolumn(item['status']['name'].to_s)  + '&emsp;' + item['summary'])
   remotejson = JSON.parse(RestClient.get "https://#{ENV['jira_name']}:#{ENV['jira_password']}@belkdev.atlassian.net/rest/api/2/search?jql=issue=#{item['key']}", {:accept => :json})
   subtasks = remotejson['issues'][0]['fields']['subtasks']
   subtasks.each do |subitem|
   worklist.push('&emsp;' + 'Open SubTask:' + '&emsp;' + "<a href=https://belkdev.atlassian.net/browse/#{subitem['key']}>#{subitem['key']}</a>" + '&emsp;'+ subitem['fields']['summary'] ) if subitem['fields']['status']['name'] != 'Closed'
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
