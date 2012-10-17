require 'rest_client'
require 'json'
require 'set'

class Github

	@username = 'dotnet@daxko.com'
	@password = '0br1H>C7]p'
	@baseurl = 'https://api.github.com/repos/daxko/operations/'
	@prefixes = ['OPS', 'CCO']

	def self.get(url)

		response = RestClient::Request.new(:method => :get, :url => @baseurl + url, :user => @username, :password => @password, :headers => { :accept => :json, :content_type => :json }).execute
  	return JSON.parse(response.to_str)

	end

	def self.get_pull_requests
		return get('pulls')
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

end

#puts Github.get_pull_requests
#puts Github.get_tickets_from_pull_request(29)