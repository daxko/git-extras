require 'rest_client'
require 'json'

class Jira

	@username = 'devapi'
	@password = 'feHt6azU'
	@baseurl = 'http://jira:8090/rest/api/latest/'

	@states = 
	{
		"in_dev" => 11,
		"back_to_in_dev" => 441,
		"story_code_review" => 501,
		"defect_code_review" => 601,
		"ready_for_build" => 511
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

	def self.get_valid_transitions(ticket)
		return get("issue/#{ticket}/transitions")
	end

	def self.transition_supported(ticket, transition)
		code = "#{@states[transition]}"
		valid_transitions = get_valid_transitions(ticket)
		return valid_transitions.has_key?(code)
	end

	def self.move_to_in_code_review(ticket)
		move_to_state(ticket, "back_to_in_dev") if transition_supported(ticket, "back_to_in_dev")
		move_to_state(ticket, "in_dev") if transition_supported(ticket, "in_dev")
		move_to_state(ticket, "story_code_review") if transition_supported(ticket, "story_code_review")
		move_to_state(ticket, "defect_code_review") if transition_supported(ticket, "defect_code_review")
		#puts "Unable to move" unless transition_supported(ticket, "ready_for_build")
	end

	def self.move_all_to_in_code_review(tickets)
		tickets.each do |ticket|
			print "Moving #{ticket} to in code review... "
			Jira.move_to_in_code_review(ticket)
			print "Status: #{Jira.get_ticket_status(ticket)}"
			print "\n"
		end
	end

	def self.move_to_ready_for_build(ticket)
		move_to_state(ticket, "ready_for_build")
	end

	def self.move_to_state(ticket, state)
		post("issue/#{ticket}/transitions", { transition: @states[state] }.to_json)
	end

end

#puts Jira.get_tickets_needing_code_review
#puts Jira.get_valid_transitions("CCO-1478")
#puts Jira.move_to_in_code_review("CCO-1478")
#puts Jira.move_to_ready_for_build("CCO-1473")
#puts Jira.transition_supported("CCO-1478", "ready_for_build")