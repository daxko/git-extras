require 'rest_client'
require 'json'
require 'set'
require 'github_api'

class GithubHelper

	@username = 'dotnet@daxko.com'
	@password = '0br1H>C7]p'
	@baseurl = 'https://api.github.com/repos/daxko/operations/'
	@prefixes = ['OPS', 'CCO']
	@repo = 'operations'
	@org = 'daxko'

	def self.get(url)
		response = RestClient::Request.new(:method => :get, :url => @baseurl + url, :user => @username, :password => @password, :headers => { :accept => :json, :content_type => :json }).execute
  	return JSON.parse(response.to_str)
	end

	def self.post(url, body, username, password)
		response = RestClient::Request.new(:method => :post, :url => @baseurl + url, :user => username, :password => password, :payload => body, :headers => { :accept => :json, :content_type => :json }).execute
  	return JSON.parse(response.to_str)
	end

	def self.patch(url, body, username, password)
		response = RestClient::Request.new(:method => :patch, :url => @baseurl + url, :user => username, :password => password, :payload => body, :headers => { :accept => :json, :content_type => :json }).execute
  	return JSON.parse(response.to_str)
	end

	def self.get_pull_requests
		return get('pulls')
	end

	def self.get_pull_request(id)
		return get("pulls/#{id}")
	end

	def self.get_tickets_from_pull_request(id)
		tickets = Set.new
		commits = get("pulls/#{id}/commits")
		commits.each do |commit|
			@prefixes.each do |prefix|
				matches = commit["commit"]["message"].scan Regexp.new("#{prefix}-\\d*")
				matches.each { |m| tickets.add(m) }
			end
		end
		return tickets.to_a
	end

	def self.create_pull_request(username, password, title, body, head, base)
		json = { title: title, body: body, head: head, base: base }.to_json
		return self.post("pulls", json, username, password)
	end

	def self.close_pull_request(number, comment, username, password)
		self.post("issues/#{number}/comments", { body: comment}.to_json, username, password)
		
		github = Github.new login:username, password:password
		github.pull_requests.update @org, @repo, number, { state: "closed" }
	end

	def self.assign_pull_request(number, assignee, username, password)

		self.patch("issues/#{number}", { assignee: assignee }.to_json, username, password)

	end

end

#puts Github.get_pull_requests
#puts Github.get_tickets_from_pull_request(29)