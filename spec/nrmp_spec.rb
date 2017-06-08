require 'spec_helper'

describe MEE::NRMP do
  it 'has a version number' do
    expect(MEE::NRMP::VERSION).not_to be nil
  end

	describe MEE::NRMP::Matcher do
		describe "given a single organization" do
			describe "with a single slot" do
					describe "with a single candidate" do
						it 'selects that candidate for that slot' do
							candidate = MEE::NRMP::Candidate.new( 'only' )
							org = MEE::NRMP::Organization.new( 'org', 1 )
							org.rank( candidate, 1)

							match = MEE::NRMP::Matcher.new
							match.add_org( org )
							match.add_candidate( candidate )
							result = match.resolve

							expect( result[org][0] ).to be( candidate )
						end
					end

					describe "with two candidates" do
						describe "with preference for a candidate" do
							it 'selects the prefered candidate' do
								candidate1 = MEE::NRMP::Candidate.new( 'original' )
								candidate2 = MEE::NRMP::Candidate.new( 'secondary' )
								org = MEE::NRMP::Organization.new( 'org', 1 )
								org.rank( candidate1, 35 )
								org.rank( candidate2, 15 )

								match = MEE::NRMP::Matcher.new
								match.add_org( org )
								match.add_candidate( candidate1 )
								match.add_candidate( candidate2 )
								result = match.resolve

								expect( result[org][0] ).to be( candidate2 )
							end
						end
					end
			end
		end

		describe "given two organizations with single slots" do
			before do
				@mishkas = MEE::NRMP::Organization.new( 'Mishkas', 1 )
				@cg = MEE::NRMP::Organization.new( 'Common Grounds', 1 )
			end

			describe 'with two candidates' do
				describe 'with having different higher preferences' do
					it 'assigns each org one' do
						john = MEE::NRMP::Candidate.new( 'John' )
						sam = MEE::NRMP::Candidate.new( 'Sam' )

						@mishkas.rank( john, 1)
						@cg.rank( sam, 1)

						match = MEE::NRMP::Matcher.new
						match.add_org( @mishkas )
						match.add_org( @cg )
						match.add_candidate( john )
						match.add_candidate( sam )
						result = match.resolve

						expect( result[ @mishkas ] ).to eq( [john] )
						expect( result[ @cg ] ).to eq( [sam] )
					end
				end

				xdescribe 'with having same preference for a candidate' do
					it 'assigns each org one' do
						john = MEE::NRMP::Candidate.new( 'John' )
						jpeg = MEE::NRMP::Candidate.new( 'Tiffany' )
						jpeg.rank( @cg, 1 )
						jpeg.rank( @mishkas, 2 )

						@mishkas.rank( jpeg, 1)
						@cg.rank( jpeg, 1)

						match = MEE::NRMP::Matcher.new
						match.add_org( @mishkas )
						match.add_org( @cg )
						match.add_candidate( john )
						match.add_candidate( jpeg )
						result = match.resolve

						expect( result[ @mishkas ] ).to eq( [john] )
						expect( result[ @cg ] ).to eq( [tiff] )
					end
				end
			end
		end
	end

	describe MEE::NRMP::Organization do
		describe "stack ranking" do
			describe "when given no candidates" do
				it "is an empty list" do
					expect( MEE::NRMP::Organization.new('name', 1 ).stack_rank_candidates ).to be_empty
				end
			end

			describe "when given 1 candidate" do
				it "provides just that candidate" do
					candidate = MEE::NRMP::Candidate.new( 'Sut' )
					org = MEE::NRMP::Organization.new('name', 1 )
					org.rank( candidate, 1 )
					expect( org.stack_rank_candidates ).to eq([candidate])
				end
			end

			describe "when given 2 candidate" do
				before do
					@tea = MEE::NRMP::Candidate.new( 'Tea' )
					@caffine = MEE::NRMP::Candidate.new( 'Caffine' )

					@org = MEE::NRMP::Organization.new('name', 2 )
					@org.rank( @tea, 2 )
					@org.rank( @caffine, 1 )
				end

				it "provides the candidates in ranked order" do
					expect( @org.stack_rank_candidates ).to eq([ @caffine, @tea ])
				end
			end
		end
	end
end

