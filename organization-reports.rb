require "csv"
require "octokit"

# default to 90 days
CUTOFF = DateTime.now - 90

# your organization name
ORGANIZATION = "intouchhealth"

User = Struct.new(:type, :username, :full_name, :active, :last_activity, :num_events)
Event = Struct.new(:username, :repository, :date)

def events
  @events ||= []
end

def users
  @users ||= []
end

def find_user_by_username(username)
  users.detect { |user| user[:username] == username }
end

Octokit.auto_paginate = true
members = Octokit.org_members(ORGANIZATION)
collaborators = Octokit.outside_collaborators(ORGANIZATION, { accept: "org_membership" })
repos = Octokit.org_repos(ORGANIZATION)

puts "Building user list..."
members.each do |member|
  user = Octokit.user(member[:login])
  users << User.new(:member, member[:login], user[:name], false, nil)
end

collaborators.each do |collaborator|
  user = Octokit.user(collaborator[:login])
  users << User.new(:collaborator, collaborator[:login], user[:name], false, nil)
end

puts "Building events list..."
repos.each do |repo|
  repo_events = Octokit.repository_events("#{ORGANIZATION}/#{repo[:name]}")
  repo_events.each { |event| events << Event.new(event[:actor][:login], repo[:name], event[:created_at]) }
end

puts "Processing events..."
events.each do |event|
  user = find_user_by_username(event[:username])
  next if user.nil?

  user[:num_events] = 0 if user[:num_events].nil?
  user[:num_events] = user[:num_events] + 1

  if user[:last_activity].nil?
    user[:last_activity] = event[:date]
  else
    user[:last_activity] = event[:date] if event[:date] >= user[:last_activity]
  end
end

puts "Processing user activity..."
users.each do |user|
  next if user[:last_activity].nil?

  user[:active] = true if user[:last_activity].to_datetime >= CUTOFF
end

puts "Generating CSV..."
CSV.open("report.csv", "wb") do |csv|
  csv << ["type", "username", "full name", "active", "last_activity", "num_events"]
  users.each do |user|
    csv << [user[:type], user[:username], user[:full_name], user[:active], user[:last_activity], user[:num_events]]
  end
end

