#Who's In

Does your company include people who work remotely and need to know who's in the office at a certain time? Say if there's a storm a-brewing, or they just want to feel more in the loop with what's happening. If that's the case, we've built a simple demo that helps you track who comes and goes from your office in realtime.

##How To Run It

We've created a very simple command-line interface that helps you set up your own 'Who's In' application. Type into your terminal:

	$ gem install pusher-whos-in
	
Then to get everything set up:

	$ pusher-whos-in init
	
This will take you to the deployment page on Heroku. Decide on a name for your app, choose the 'United States' region option and then click the shiny 'Deploy For Free' button. Heroku will set this up for you, and provision you a Mongo database with a Pusher add-on.

Visit your app and now you can choose to add users. Simply enter their name and MAC and email addresses. 'Who's In' will use the MAC addresses to identify whether your colleague is present on your local network, and use their email address to fetch their gravatar.

Now run:

	$ pusher-whos-in run _your_app_name_
	
For example, if your Heroku URL is `office-whos-in.herokuapp.com`, then type `pusher-whos-in run office-whos-in`. As the script that scans your local network requires root privileges, enter your password.

Go back to your app and you should see the page populated with your company's pretty faces - opaque if they're in the office at the moment, and transparent if absent. 

So that Pusher Sandbox limits are not encroached upon, this page updates only every two minutes.

##How It Works

The command `pusher-whos-in run` scans the local network every two minutes and posts to a Sinatra server. To do so it uses NMap, the security scanner normally used to discover hosts on a local network, and creates an array of MAC addresses. 

```shell
  macs=( $(sudo nmap -sn 192.168.1.0/24 | grep -Eio "([0-9A-F]{2}:){5}[0-9A-F]{2}") )
```

The `$macs` array then gets processed into JSON, and is posted to a server using your Heroku Pusher keys for Basic Authentication:

```shell
  curl -X POST -d "$json" $WHOSIN_URL -u admin:$AUTH_KEY >/dev/null 2>&1
  # N.B. Outside the purposes of this demo, one should never post from a privileged script(!)
```

The server then matches the list of MAC addresses to users. If they are included, it sets them as present. If not and they have not been on the network for at least 10 minutes, they are set as absent. Then we trigger a simple Pusher event to the client, carrying all the `people` JSON objects stored in Mongo:

```ruby
	Pusher['people_channel'].trigger('people_event', people)
```

On the front-end, as it's my framework of choice, I used AngularJS with the new Pusher-Angular library to take the people and assign them to scope:

```js

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

##Free and Open for Everyone!







