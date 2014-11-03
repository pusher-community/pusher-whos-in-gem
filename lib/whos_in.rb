require_relative "whos_in/version"
require 'rufus-scheduler'

module WhosIn
  
	class Application

		def launch_heroku_deploy
			puts "Launching deployment setup on Heroku... \n\n Input a name for your app (e.g. office_whos_in) then click the 'Deploy For Free' button. \n\nWhen you're done run 'pusher-whos-in run *your_app_name* " 
			sleep 2
			`open https://heroku.com/deploy?template=https://github.com/pusher/pusher-whos-in`
		end

		def setup
			launch_heroku_deploy
		end

		def self.tell_user_and_scan_network
			script =  File.expand_path('../../bin/local_scanner', __FILE__)
			pusher_url = `heroku config:get PUSHER_URL -a #{@heroku_app}`

			puts "Scanning local network every 2 minutes and posting to #{@heroku_url}"
			puts "Press Ctrl+C to interrupt"
			`#{script} #{@heroku_url} #{pusher_url}`
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
			@heroku_app = app_name
			@heroku_url = "http://#{app_name}.herokuapp.com/people"
			self.run_script
		end

	end

end
