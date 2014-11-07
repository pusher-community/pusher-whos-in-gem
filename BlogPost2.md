Let's say you're working remote, but - alas - alone and out of the loop, you want to see who's in the office right now. Maybe a storm has hit your project, or maybe you just want to see the kind faces of friends who now seem very, very far away. "Who's in the office?", you say to yourself, pacing your living room. Who indeed?

Well thanks to this new application, you can now find out in realtime!

## What Is It?

'Who's In?' is a very simple app that tracks live who comes and goes from work. It's built from a local script that runs from the office and a free Heroku application. The script and the Heroku app chat to each other every couple of minutes to keep track of who's in the office.

And the best part about it? It takes less than five minutes to set up.
<br/>
<div style="text-align:center">
<img src="https://raw.githubusercontent.com/pusher/pusher-whos-in-gem/master/screenshots/whosingif2.gif" alt="Sped Up Comings And Goings" />
</div>   
<br/><br/>

## Wow! How Do I Set It Up?

For ease of use, we've created a very easy command-line interface that helps your office set up its own 'Who's In?'. Type this into your terminal:

  $ gem install pusher-whos-in
  $ pusher-whos-in init
    
The first command installs a gem that both initializes deployment and sets up a binary executable that scans your local network. The second command, when entered, should take you to the deployment page on Heroku. 

<div style="text-align:center">
<img src="https://raw.githubusercontent.com/pusher/pusher-whos-in-gem/master/screenshots/heroku.jpg" width="600px" height="auto" alt="Heroku deployment page" />
</div>
<br/>

All you have to do is: name your app, choose the 'United States' region option, then click the shiny 'Deploy For Free' button.

This will set up your very own Heroku application, provisioned with a free Mongo database and a free Pusher add-on.

Now view your app and add some users. Simply enter their name and MAC and email addresses. ‘Who’s In’ will use the MAC addresses to identify whether your colleague is knocking about on your local network, and use their email address to fetch their gravatar.
<br/>
<div style="text-align:center">
<img src="https://raw.githubusercontent.com/pusher/pusher-whos-in-gem/master/screenshots/add_colleague.gif" alt="Adding Users" width="500px" height="auto"/>
</div>
<br/>
And here's the final step:

  $ pusher-whos-in run _your_app_name_
  
If your Heroku URL is `mcdiddys-peeps.herokuapp.com`, then type `pusher-whos-in run mcdiddys-peeps`. As this script requires root privileges, enter your password. (This will be explained further below).

The moment of truth! Go back to your app and you should see the page populated with some much-missed faces - opaque if they're in, transparent if not.

So that Pusher's Sandbox limits are not encroached upon, this page updates only every two minutes.

Furthermore, if you don't wish to use the gem, or if you only want to run the app locally, you use the simple steps [documented here](https://github.com/pusher/pusher-whos-in-gem).

<br/>
## How Does It Work, Then?


<!-- The command `pusher-whos-in run` scans the local network every two minutes and posts to a Sinatra server. Using [NMap](http://nmap.org), which normally is used as a security scanner to discover hosts on a local network (thus requiring root privileges), we can create an array of MAC addresses. -->

The `pusher-whos-in run` command runs a script every two minutes. This script uses [NMap](http://nmap.org), which normally is used as a security scanner to discover hosts on a local network (thus requiring root privileges), to scan for MAC addresses.

<br/>
```language-bash
  macs=( $(sudo nmap -sn 192.168.1.0/24 | grep -Eio "([0-9A-F]{2}:){5}[0-9A-F]{2}") )
```
<br/>

The script then process the `$macs` array into JSON, and posts it to the Sinatra server running on Heroku. To do so, it uses your Heroku Pusher keys for Basic Authentication, having got them from your Heroku instance with the Pusher add-on.
<br/>
```language-bash
  curl -X POST -d "$json" $WHOSIN_URL -u admin:$AUTH_KEY >/dev/null 2>&1
  # N.B. Outside the purposes of this demo, one should never post from a privileged script(!)
```
<br/>

The server then goes through the users in MongoDB, and sets `present` to `true` or `false` depending on whether their known MAC address was present in the posted list. 

Then it triggers a simple Pusher event to the client, carrying all the `people` JSON objects stored in the database:
<br/>
```language-ruby
  Pusher['people_channel'].trigger('people_event', people)
```
<br/>
On the front-end, as it's my framework of choice, I used AngularJS with the [new Pusher-Angular library](https://github.com/pusher/pusher-angular) to take the people and assign them to scope:
<br/>
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
<br/>
Then using HTML, CSS and Angular `{{expressions}}` we can render everyone on the page, along with their gravatars and when they were last seen.

<br/>
## Can I Make It Better?

Absolutely, and we encourage you to! 

We acknowledge that this is merely one of many ways you can show who's in the office. If you can think of a better way, feel more than free to [fork our Github repo](https://github.com/pusher/pusher-whos-in) and send us a pull request.

Here are some other ways you might improve on our app:

* Integrate it with HipChat and Slack. Perhaps you could create a bot to reply with the list of people present in the office?
* Tighten security. You could perhaps do this by easily introducing [private channels](http://pusher.com/docs/client_api_guide/client_private_channels) to your Pusher connections, or by creating a workaround that skips the need to HTTP post from a privileged script.
* Play with the UI.
* Create logs and visualisations of who comes and goes.

No doubt you have plenty ideas of your own - so, now we'll leave it to you!