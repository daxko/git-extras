require 'set'
require_relative 'jira.rb'

class Git

	@prefixes = ['OPS', 'CCO']

	def self.get_tickets_from_current_branch(parent_branch)

		commits = `git branch-commits #{parent_branch}`

		tickets = Set.new
		@prefixes.each do |prefix|
			matches = commits.scan Regexp.new("#{prefix}-\\d*")
			matches.each { |m| tickets.add(m) }
		end
		return tickets.to_a

	end

	def self.ready_for_review(source_branch)

		if source_branch.nil?
			puts "You must supply a source branch"
			return
		end

		tickets = Git.get_tickets_from_current_branch(source_branch)

		puts "\nShould I move these jira ticket(s) to ready for code review? #{tickets.join(', ')}\n\n"
		print "[y/n]?: "
		$stdout.flush

		input = $stdin.gets.chomp
		if input.downcase == "y"
			Jira.move_all_to_in_code_review(tickets)
		end

	end

end