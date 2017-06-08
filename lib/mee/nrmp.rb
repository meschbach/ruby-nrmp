require_relative "nrmp/version"

module MEE
module NRMP

class Candidate
	attr_accessor :name

	def initialize( name )
		self.name = name
		@ranks = {}
	end

	def rank( org, rank )
		@ranks[ rank ] = org
	end
end

class Organization
	attr_accessor :name, :slots

	def initialize( name, slots )
		self.name = name
		self.slots = slots
		@ranks = {}
	end

	def rank( candidate, rank )
		@ranks[ rank ] = candidate
	end

	def stack_rank_candidates
		@ranks.values.sort do |lhs, rhs|
			@ranks.key( lhs ) <=> @ranks.key( rhs )
		end
	end
end

class Matcher
	def initialize()
		@orgs = []
		@candidates = []
	end

	def add_org( org )
		@orgs.push( org )
	end

	def add_candidate( candidate )
		@candidates.push( candidate )
	end

	def resolve()
		result = {}
		@orgs.each do |org|
			matches = org.stack_rank_candidates
			result[org] = matches
		end

		result
	end
end

end
end
