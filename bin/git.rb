require 'set'

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

end