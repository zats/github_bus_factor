require "github_bus_factor/version"
#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'octokit'
require 'security'
require 'terminal-table'
require 'faraday-http-cache'
require 'action_view'
require 'active_support/core_ext/numeric/time'
include ActionView::Helpers::DateHelper



module GitHubScore
	KEYCHAIN_SERVICE = 'github_bus_factor'
	API_CALL_RETRY_COUNT = 3


	program :version, '0.0.1'
	program :description, 'More than just stars'
	default_command :about

	# There must be a better way to deal with GitHub caching… 
	def GitHubScore.helper(count, block)
		return unless count > 0
		return if !block.call(count).nil?
		puts "Waiting for GitHub cache. Will retry in 3 seconds…"
		sleep(3)
		helper(count - 1, block)
	end


	command :about do |c|
		c.syntax = 'github_bus_factor about'
		c.summary = 'Explains every line of the report.'
		c.action do |args, options|
			table = Terminal::Table.new do |t|
				t.style = {:padding_left => 1, :padding_right => 2}
				t.title = 'GitHub Score'
				t.headings = ['', 'Description']
				t << ['🍴', 'Forks. Might mean people planning are fixing bugs or adding features.']
				t << ['🔭', 'Watchers. Shows number of people interested in project changes.']
				t << ['🌟', 'Stars. Might mean it is a good project or that it was featured in a mailing list. Some people use 🌟 as a "Like".']
				t << ['🗓', 'Age. Mature projects might mean battle tested project. Recent pushes might mean project is actively maintained.']
				t << ['🍻', 'Pull Requests. Community contributions to the project. Many closed PRs usually is a good sign, while no PRs usual is bad.']
				t << ['🛠', 'Refactoring. Balance between added and deleted code. Crude value not including semantic understanding of the code.']
				t << ['📦', 'Releases. Might mean disciplined maintainer. Certain dependency managers rely on releases to be present.']
				t << ['🚌', 'Bus factor. Chances of the project to become abandoned once current collaborators stop updating it. The higher - the worse.']
			end
			puts table
		end
	end

	command :logout do |c|
		c.syntax = 'github_bus_factor logout'
		c.summary = 'Remove GitHub token from your keychain.'
		c.action do |args, options|
			Security::GenericPassword.delete(service: KEYCHAIN_SERVICE)
		end
	end

	command :fetch do |c|
		c.syntax = 'github_bus_factor fetch [options]'
		c.summary = 'Fetches GitHub score for a given owner/repository'
		c.option '--verbose', 'Add extra logging'
		c.action do |args, options|
			# owner / repo
			throw "Expect owner/repo as an argument" unless args.count == 1
			matches = args.first.match(/^(.+)\/(.+)$/)
			throw "Expect owner/repo as an argument" unless !matches.nil?
			ownerName, repoName = matches.captures
			throw "Expect owner/repo as an argument" if ownerName.nil? || ownerName.empty? || repoName.nil? || repoName.empty?

			# Token
			tokenPassword = Security::GenericPassword.find(service: KEYCHAIN_SERVICE)
			token = nil
			unless tokenPassword
				puts "Please create a GitHub access token at https://github.com/settings/tokens"
				while token.nil? || token.empty? do
					token = ask("Token: ")
					Security::GenericPassword.add(KEYCHAIN_SERVICE, '', token) unless token.nil? || token.empty?
				end
			else
				token = tokenPassword.password
			end

			# GitHub client
			client = Octokit::Client.new(:access_token => token)
			client.auto_paginate = true
			repository = Octokit::Repository.new(:owner => ownerName, :repo => repoName)

			# Cache
			stack = Faraday::RackBuilder.new do |builder|
				builder.use Faraday::HttpCache
				builder.use Octokit::Response::RaiseError
				builder.adapter Faraday.default_adapter
			end
			client.middleware = stack

			# Output
			output = []

			# Info
			puts("1/6 Fetching repository info…")
			repository_info = client.repository(repository)
			puts(repository_info.inspect) if options.verbose

			# Forks
			FORKS_THRESHOLD = 5
			if repository_info.forks_count > FORKS_THRESHOLD
				forks_value = "#{repository_info.forks_count} forks."
			else 
				forks_value = "Few forks (#{repository_info.forks_count})."
			end
			output << ['🍴', forks_value]

			# Watchers
			WATCHERS_THRESHOLD = 5
			if repository_info.subscribers_count > WATCHERS_THRESHOLD
				watchers_value = "#{repository_info.subscribers_count} watchers."
			else 
				watchers_value = "Few watchers (#{repository_info.subscribers_count})."
			end
			output << ['🔭', watchers_value]

			# Stars
			STARS_THRESHOLD = 10
		    if repository_info.stargazers_count > STARS_THRESHOLD
		        stars_value = "#{repository_info.stargazers_count} stars."
		    else 
		        stars_value = "Few stars (#{repository_info.stargazers_count})."
		    end
		    output << ['🌟', stars_value]

		    # Age
		    created_at = repository_info.created_at
		    last_push = repository_info.pushed_at
		    output << ['🗓',  "Created #{time_ago_in_words(created_at)} ago; last push #{time_ago_in_words(last_push)} ago."]

		    # PRs
			puts("2/6 Fetching open PRs…")
			open_PRs = client.pull_requests(repository, {:per_page => 100})
			puts(open_PRs.inspect) if options.verbose

			puts("3/6 Fetching closed PRs…")
			closed_PRs = client.pull_requests(repository, {:state => 'closed'})
			puts(closed_PRs.inspect) if options.verbose

		    total_PRs_count = open_PRs.count + closed_PRs.count
		    if total_PRs_count > 0
		    	ratio = (Float(closed_PRs.count) / total_PRs_count * 100).round(2)
		    	prs_value = "#{total_PRs_count} PRs: #{closed_PRs.count} closed; #{open_PRs.count} opened; #{ratio}% PRs are closed."
		    else 
		    	prs_value = 'No PRs opened yet for this repository.'
		    end
			output << ['🍻', prs_value]

		    # Refactoring
			code_frequency = nil
			GitHubScore.helper(API_CALL_RETRY_COUNT, lambda { |c|  
				puts("4/6 Fetching code frequency…")
				code_frequency = client.code_frequency_stats(repository)
			})
			puts(code_frequency.inspect) if options.verbose

		    deletions = 0
		    additions = 0
		    refactoring = code_frequency.each { |frequency| 
		    	additions += frequency[1]
		    	deletions += frequency[2]
		    }
		    refactoring = (Float(deletions.abs) / Float(additions) * 100).round(2)
		    REFACTORING_THRESHOLD = 5
		    if refactoring > REFACTORING_THRESHOLD
		    	refactoring_value = "Deletions to additions ratio: #{refactoring}% (#{deletions}/#{additions})."
		    else
				refactoring_value = "Mostly additions, few deletions (#{deletions}/#{additions})."
		    end
			output << ['🛠', refactoring_value]

			# Releases
			puts("5/6 Fetching releases…")
			releases = client.releases(repository)
			puts(releases.inspect) if options.verbose
			if !releases.empty?
				latest_release = releases.first
				release_name = latest_release.name.nil? || latest_release.name.empty? ? latest_release.tag_name : latest_release.name
				releases_value = "#{releases.count} releases; latest release \"#{release_name}\": #{time_ago_in_words(latest_release.published_at)}."
			else
				releases_value = 'No releases.'
			end
			output << ['📦', releases_value]

			# Bus factor
			contributions = nil 
			GitHubScore.helper(API_CALL_RETRY_COUNT, lambda { |c|
				puts("6/6 Fetching contribution statistics…")
				contributions = client.contributors_stats(repository)
			})
			puts(contributions.inspect) if options.verbose
			contributions = contributions.map { |c| c.total }
			min, max = contributions.minmax
			delta = max - min
			CONTRIBUTION_THRESHOLD = 0.7
			meaningful = contributions.select { |c|  (max - c) < delta * CONTRIBUTION_THRESHOLD }
			total_contributions = contributions.reduce(0) { |t, c|  t + c }
			if meaningful.empty? 
				bus_factor = 100
			else 
				average = contributions.reduce(0) { |a, c| a + Float(c) / total_contributions }
				bus_factor = (average / meaningful.count * 100.0).round(2)
			end
			if bus_factor > 90
				bus_factor_value = "Bus factor: #{bus_factor}%. Most likely one core contributor."
			else 
				bus_factor_value = "Bus factor: #{bus_factor}% (#{meaningful.count} impactful contributors out of #{contributions.count})."
			end
			output << ['🚌', bus_factor_value]

			# Output
			puts("Thank you for you patience 💕\n\n")
		    table = Terminal::Table.new do |t|
		    	t.title = "#{ownerName}/#{repoName}"
				t.style = {:padding_left => 1, :padding_right => 2}
		    	t.rows = output.each_with_index
		    end
		    puts table
		end
	end
end
