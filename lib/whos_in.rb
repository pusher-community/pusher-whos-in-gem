require_relative "whos_in/version"

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

		def self.run_script app_name
			`bin/every-5-seconds.sh http://#{app_name}.herokuapp.com/people`
		end


	end


end
