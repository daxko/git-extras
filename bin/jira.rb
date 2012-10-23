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
	@baseurl = 'http://jira:8090/rest/api/latest/'

	@states = 
	{
		"in_dev" => "Begin Development",
		"back_to_in_dev" => "Back to Development",
		"code_review" => "Ready for Code Review",
		"ready_for_build" => "Ready for Build"
	}

	def self.get(url)

		response = RestClient::Request.new(:method => :get, :url => @baseurl + url, :user => @username, :password => @password, :headers => { :accept => :json, :content_type => :json }).execute
  	return JSON.parse(response.to_str)

	end

	def self.post(url, payload)

		response = RestClient::Request.new(:method => :post, :url => @baseurl + url, :user => @username, :password => @password, :payload => payload, :headers => { :accept => :json, :content_type => :json }).execute
  	return response

	end

	def self.get_ticket(ticket)
		return get("issue/#{ticket}")
	end

	def self.get_ticket_status(ticket)
		return get_ticket(ticket)["fields"]["status"]["value"]["name"]
	end

	def self.get_tickets_needing_code_review

		jql = 'project IN("Operations", "Child Care", "Reserve") AND status = "Ready for Peer Review"  ORDER BY createdDate DESC'
		return get(full_url('search?jql=') + URI::encode(jql))["issues"]

	end

	def self.get_valid_transition_code(ticket, transition)
		valid_transitions = get_valid_transitions(ticket)
		valid_transitions.keys.each do |key|
			return key if valid_transitions[key]["name"] == transition
		end
		return nil
	end

	def self.get_valid_transitions(ticket)
		return get("issue/#{ticket}/transitions")
	end

	def self.move_to_in_code_review(ticket)
		move_to_state(ticket, "Back to Development")
		move_to_state(ticket, "Begin Development")
		move_to_state(ticket, "Ready for Code Review")
	end

	def self.move_all_to_in_code_review(tickets)
		tickets.each do |ticket|
			print "Moving #{ticket} to in code review... "
			Jira.move_to_in_code_review(ticket)
			print "Status: #{Jira.get_ticket_status(ticket)}"
			print "\n"
		end
	end

	def self.move_to_state(ticket, state)
		code = get_valid_transition_code(ticket, state)
		return if code.nil?

		post("issue/#{ticket}/transitions", { transition: code }.to_json)
	end

end

#puts Jira.get_tickets_needing_code_review
#puts Jira.get_valid_transitions("CCO-1478")
#puts Jira.move_to_in_code_review("CCO-1478")
#puts Jira.move_to_ready_for_build("CCO-1473")
#puts Jira.transition_supported("CCO-1478", "ready_for_build")

puts Jira.move_to_in_code_review("CCO-1473")