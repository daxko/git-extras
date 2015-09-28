require 'rest_client'
require 'json'

class Transition
	def initialize(name)
		@name = name
	end
end

class Jira

	@username = 'devapi'
	@password = 'feHt6azU'
	@baseurl = 'https://jira.daxko.com/rest/api/latest/'

	def self.get(url)

		response = RestClient::Request.new(:method => :get, :url => @baseurl + url, :user => @username, :password => @password, :headers => { :accept => :json, :content_type => :json }).execute
  		return JSON.parse(response.to_str)

	end

	def self.post(url, payload)

		response = RestClient::Request.new(:method => :post, :url => @baseurl + url, :user => @username, :password => @password, :payload => payload, :headers => { :accept => :json, :content_type => :json }).execute
  		return response

	end

	def self.put(url, payload)

		response = RestClient::Request.new(:method => :put, :url => @baseurl + url, :user => @username, :password => @password, :payload => payload, :headers => { :accept => :json, :content_type => :json }).execute
  		return response

	end

	def self.get_ticket(ticket)
		return get("issue/#{ticket}")
	end

	def self.get_ticket_status(ticket)
		return get_ticket(ticket)["fields"]["status"]["name"]
	end

	def self.get_tickets_needing_code_review

		jql = 'project IN("Operations", "Child Care", "Reserve") AND status = "Ready for Peer Review"  ORDER BY createdDate DESC'
		return get(full_url('search?jql=') + URI::encode(jql))["issues"]

	end

	def self.get_valid_transition_code(ticket, transition)
		valid_transitions = get_valid_transitions(ticket)["transitions"]
		valid_transitions.each do |item|
			return item["id"] if item["name"] == transition
		end
		return nil
	end

	def self.get_valid_transitions(ticket)
		return get("issue/#{ticket}/transitions?")
	end

	def self.move_to_in_development(ticket)
		move_to_state(ticket, "Open Issue", { customfield_11790: { value: ENV['JIRA_AGILE_TEAM_NAME'] || "Ops Dev" }})
	end

	def self.assign_to(ticket, username)
		data = {
			fields: {
				assignee: { name: username }
			}
		}
		put("issue/#{ticket}", data.to_json)
	end

	def self.move_to_in_code_review(ticket)
		move_to_in_development(ticket)
		move_to_state(ticket, "Begin Development")
		assign_to(ticket, ENV['USERNAME'])
		move_to_state(ticket, "Development Done")
	end

	def self.move_all_to_in_code_review(tickets)
		tickets.each do |ticket|
			print "Moving #{ticket} to in code review... "
			Jira.move_to_in_code_review(ticket)
			print "Status: #{Jira.get_ticket_status(ticket)}"
			print "\n"
		end
	end

	def self.move_to_state(ticket, state, fields = nil)
		code = get_valid_transition_code(ticket, state)
		return if code.nil?

		data = { transition: { id: code } }
		data[:fields] = fields if !fields.nil?

		post("issue/#{ticket}/transitions", data.to_json)
	end

end

#puts Jira.get_tickets_needing_code_review
#puts Jira.get_valid_transitions("CCO-1478")
#puts Jira.move_to_in_code_review("CCO-1478")
#puts Jira.move_to_ready_for_build("CCO-1473")
#puts Jira.get_valid_transition_code("CCO-2146", "Begin Development")
#puts Jira.move_to_in_code_review("CCO-2146")
#puts Jira.move_to_in_development("CCO-2146")