Mogreet API Starter template for MO callback

$> git clone git@github.com:pforsyth/mogreet-api-starter.git
$> cd mogreet-api-starter
$> bundle install

Add your Mogreet credentials to config/mogreet.yml

To use heroku, follow the instructions here to signup: https://devcenter.heroku.com/articles/quickstart

$> heroku create
$> git push heroku master

In the output, it should say where your app has been deployed. Something like:

...
http://blazing-galaxy-997.herokuapp.com deployed to Heroku

Test your app by putting that URL in the browser. It should return a simple Hello World.
If that worked, all you need to do is tell the Mogreet API where to send the callbacks. 
Just add "/callback" to the end of your URL. So if we use the sample URL above, the callback
URL would be:

http://blazing-galaxy-997.herokuapp.com/callback

