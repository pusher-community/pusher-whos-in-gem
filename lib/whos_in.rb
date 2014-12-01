require_relative "whos_in/version"
require 'rufus-scheduler'
require 'system/getifaddrs'
require 'ipaddr'

module WhosIn
  
	class Application

		def self.launch_heroku_deploy
			puts "Launching deployment setup on Heroku... \n\n Input a name for your app (e.g. office_whos_in) then click the 'Deploy For Free' button. \n\nWhen you're done run 'pusher-whos-in run *your_app_name* " 
			puts "If your browser doesn't open automatically, visit: \n\n https://heroku.com/deploy?template=https://github.com/pusher/pusher-whos-in"
			sleep 2
			`open https://heroku.com/deploy?template=https://github.com/pusher/pusher-whos-in`
		end

		def self.tell_user_and_scan_network
			script =  File.expand_path('../../bin/local_scanner', __FILE__)

			pusher_url = `heroku config:get PUSHER_URL -a #{@heroku_app}`.strip
			if pusher_url.empty? then
				puts "Unable to retrieve Pusher URL for #{@heroku_app}"
				return
			end

			puts "Scanning #{@local_interface} network interface every 2 minutes and posting to #{@heroku_url}"
			puts "Press Ctrl+C to interrupt"

			`#{script} #{@heroku_url} #{pusher_url} #{@local_network}`
		end

		def self.run_script
			# Get available network interfaces
			interfaces = System.get_ifaddrs

			# Verify that provided interface is in the interface list
			interface = @local_interface.to_sym
			unless interfaces.has_key?(interface) then
				puts "Unable to determine the network interface: #{@local_interface}"
				return
			end

			# Get the network interface's IP and netmask
			address = interfaces[interface][:inet_addr]
			netmask = interfaces[interface][:netmask]

			# Convert to nmap's preferred format
			network = IPAddr.new(address).mask(netmask).to_s
			cidr = IPAddr.new(netmask).to_i.to_s(2).count("1").to_s

			@local_network = network + "/" + cidr

			tell_user_and_scan_network
			scheduler = Rufus::Scheduler.new
			scheduler.every '2m' do
				tell_user_and_scan_network
			end 

			scheduler.join
		end

		def self.run_app(app_name, interface)
			@heroku_app = app_name
			@local_interface = interface
			@heroku_url = "http://#{app_name}.herokuapp.com/people"

			self.run_script
		end
	end

end
