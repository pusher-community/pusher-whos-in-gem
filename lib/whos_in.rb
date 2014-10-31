require_relative "whos_in/version"
require 'rufus-scheduler'

module WhosIn
  
	class Application

		def launch_heroku_deploy
			puts "Launching deployment setup... \n\n When you're done run 'whos_in run *your_app_name* " 
			sleep 2
			`open https://heroku.com/deploy?template=https://github.com/jpatel531/whos_in`
		end

		def setup
			launch_heroku_deploy
		end

		# MAKE RUN SCRIPT

		def self.tell_user_and_scan_network
			script =  File.expand_path('../../bin/local_scanner', __FILE__)

			puts "Scanning local network and posting to #{@heroku_url}"
			puts "Press Ctrl+C to interrupt"
			`#{script} #{@heroku_url}`
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
