require_relative "whos_in/version"
require 'rufus-scheduler'

module WhosIn
  
	class Application

		def launch_heroku_deploy
			puts "Launching deployment setup... come back here when you're done" 
			sleep 2
			`open https://heroku.com/deploy?template=https://github.com/jpatel531/whos_in`
		end

		def ask_for_app_name
			puts "What is the name of your Heroku application?"
			@name = STDIN.gets.chomp
		end

		def ask_for_pusher_key
			puts "What is your Pusher app key?"
			@pusher_key = STDIN.gets.chomp
		end

		def ask_for_pusher_secret
			puts "What is your Pusher app secret?"
			@pusher_secret = STDIN.gets.chomp
		end

		def ask_for_app_id
			puts "What is your app id?"
			@app_id = STDIN.gets.chomp
		end

		def ask_for_pusher_details
			ask_for_app_name and ask_for_pusher_key and ask_for_pusher_secret and ask_for_app_id
		end

		def set_config_vars
			vars = "WHOS_IN_KEY=#{@pusher_key} WHOS_IN_SECRET=#{@pusher_secret} WHOS_IN_ID=#{@app_id}"
			puts "Setting #{vars} of #{@name}"
			`heroku config:set #{vars} -a #{@name}`
		end

		def setup
			launch_heroku_deploy
			ask_for_pusher_details
			set_config_vars
		end

		# MAKE RUN SCRIPT

		def self.tell_user_and_scan_network
			puts "Scanning local network and posting to #{@heroku_url}"
			puts "Press Ctrl+C to interrupt"
			# puts `pwd`
			`local_scanner #{@heroku_url}`
		end

		def self.run_script
			tell_user_and_scan_network
			scheduler = Rufus::Scheduler.new
			scheduler.every '2m' do
				tell_user_and_scan_network
			end
			scheduler.join
		end

		def self.open_app
			puts "Opening your application"
			sleep 2
			`open #{@heroku_app}`
			sleep 3
		end

		def self.run_app app_name
			@heroku_app = "http://#{app_name}.herokuapp.com"
			@heroku_url = @heroku_app + "/people"
			self.open_app
			self.run_script
		end

	end

end
