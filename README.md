# Who's In?

This gem allows you to deploy to Heroku an application that lets you keep track of people who come and go from the office in realtime.

## Installation

    $ gem install pusher-whos-in

## Usage

###Deployment

To deploy your own Who's In app, type into the command-line:

	$ pusher-whos-in init

This will take you to the [deployment page for Who's In on Heroku](https://heroku.com/deploy?template=https://github.com/pusher/pusher-whos-in). Fill in the title of your app, and submit when ready. Heroku will provision you a Mongo database and a [Pusher add-on](https://addons.heroku.com/pusher).

View your app, and click the grey hexagon to add colleagues. You will need to enter their name, email and MAC address.

###Scanning Who's In

Who's In uses NMap to scan the local network to see who is in the office. If you haven't installed NMap already, you can do so [here](http://nmap.org/download.html).

When that's done, type the command:

	$ pusher-whos-in run *your_app_name*

E.g. `pusher-whos-in run my_office_whos_in_app`. Then type your password. This script will run every two minutes and your Heroku application should show you who is in your office in realtime.

###Usage Without Gem

###Usage Without Heroku

## Contributing

1. Fork it ( https://github.com/pusher/pusher-whos-in-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
