Let's say you're working remote, but - alas - alone and out of the loop, you want to see who's in the office right now. Maybe a storm has hit your project, or maybe you just want to see the kind faces of friends who now seem very, very far away. "Who's in the office?", you say to yourself, pacing your living room. Who indeed?

Well thanks to this new application, you can now find out in realtime!

## What Is It?

'Who's In?' is a very simple app that tracks live who comes and goes from work. It's merely a local script, run from the office, and a Heroku application that chat to each other every couple of minutes. 

![WhosInRealtime](https://raw.githubusercontent.com/pusher/pusher-whos-in-gem/master/screenshots/whosingif2.gif)

And the best part about it? It takes less than five minutes to set up.

## Wow! How Do I Set It Up?

For ease of use, we've created a very easy command-line interface that helps your office set up its own 'Who's In?'. Type this into your terminal:

	$ gem install pusher-whos-in
	$ pusher-whos-in init
		
The first command installs a gem that both initializes deployment, and sets up binary executable that scans your local network. The second command, when entered, should take you to the deployment page on Heroku. 

![Heroku page](https://raw.githubusercontent.com/pusher/pusher-whos-in-gem/master/screenshots/heroku.jpg)

All you have to do is: name your app, choose the 'United States' region option, then click the shiny 'Deploy For Free' button.

This will set up your very own Heroku application, provisioned with a Mongo database and Pusher add-on.

Now view your app and add some users. Simply enter their name and MAC and email addresses. ‘Who’s In’ will use the MAC addresses to identify whether your colleague is knocking about on your local network, and use their email address to fetch their gravatar.

And here's the final step:

	$ pusher-whos-in run _your_app_name_
	
If your Heroku URL is `mcdiddys-peeps.herokuapp.com`, then type `pusher-whos-in run mcdiddys-peeps`. As this script requires root privileges, enter your password.

The moment of truth! Go back to your app and you should see the page populated with some much-missed faces - opaque if they're in, transparent if not.

So that Pusher's Sandbox limits are not encroached upon, this page updates only every two minutes.

Furthermore, if you don't wish to use the gem, or if you only want to run the app locally, you use the simple steps [documented here](https://github.com/pusher/pusher-whos-in-gem).

## How Does It Work, Then?


The command `pusher-whos-in run` scans the local network every two minutes and posts to a Sinatra server. Using NMap, which normally is used as a security scanner to discover hosts on a local network, we can create an array of MAC addresses.


```language-bash
  macs=( $(sudo nmap -sn 192.168.1.0/24 | grep -Eio "([0-9A-F]{2}:){5}[0-9A-F]{2}") )
```

The `$macs` array then gets processed into JSON, and is posted to a server using your Heroku Pusher keys for Basic Authentication:

```language-bash
  curl -X POST -d "$json" $WHOSIN_URL -u admin:$AUTH_KEY >/dev/null 2>&1
  # N.B. Outside the purposes of this demo, one should never post from a privileged script(!)
```

The server then matches the list of MAC addresses to users. If they are included, it sets `present` to `true` and `last_seen` to `Time.now` in MongoDB. If not and they have not been on the network for at least 10 minutes, `present` is set to `false`. Then we trigger a simple Pusher event to the client, carrying all the `people` JSON objects stored in the database:

```language-ruby
	Pusher['people_channel'].trigger('people_event', people)
```

On the front-end, as it's my framework of choice, I used AngularJS with the [new Pusher-Angular library](https://github.com/pusher/pusher-angular) to take the people and assign them to scope:

```language-javascript

  angular.module('WhosIn', ['pusher-angular']).controller('AppCtrl', function($scope, $pusher, $http){

    var client = new Pusher(pusherKey);
    var pusher = $pusher(client);
    var peopleChannel = pusher.subscribe('people_channel');

    peopleChannel.bind('people_event', function(data){
      $scope.people = data;
    });

  });
```

Then using HTML, CSS and Angular `{{expressions}}` we can render everyone on the page, along with their gravatars and when they were last seen.


## Can I Make It Better?

Absolutely, and we encourage you to! 

We acknowledge that this is merely one of many ways you can show who's in the office. If you can think of a better way, feel more than [free to fork our Github repo](https://github.com/pusher/pusher-whos-in) and send us a pull request.

Here are some other ways you might improve on our app:

* Integrate it with HipChat and Slack. Perhaps you could create a bot to reply with the list of people present in the office?
* Create logins with your company's email to access the app.
* Play with the UI.
* Create logs and visualisations of who comes and goes.

No doubt you have plenty ideas of your own - so, now we'll leave it to you!