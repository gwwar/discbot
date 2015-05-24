# discbot

An extensible discourse bot, great for rolling dice, and silly games. Be responsible! Before using, 
make sure you own your discourse instance, or have permission to run this bot.

## Seriously, what does discbot do?

Not much but discbot will reply to you if you say the magic words. Think of hubot but async and slower.

![](http://i.imgur.com/PmLyOqa.png)

## Setup

### Install Discourse (skip this step if you have a simple script to add)
Follow instructions here: https://github.com/discourse/discourse/blob/master/docs/DEVELOPER-ADVANCED.md

Make sure you have a book or other fun activities ready while `bundle install` finishes.

### Create a bot user in discourse

Sign up for a user with an email address you own. Consider adding a +bot modifier to the email address.
example+bot@test.com

### Setup local environment variables if you're using this with a local discourse instance
```
export DISCBOT_URL=<your-discourse-base-url>
export DISCBOT_USERNAME=<bot-username>
export DISCBOT_PASSWORD=<bot-password>
```
### Local install of Discbot

```
npm install
```

### To Run Locally:

In your checkout folder:
```
./bin/discbot
```

### Run Tests

```
npm test
```

### Running discbot in Heroku
* Push discbot to your heroku remote repo
* Setup the following environment variables in heroku:
```
heroku config:set DISCBOT_URL=<your-discourse-base-url> DISCBOT_USERNAME=<bot-username>  DISCBOT_PASSWORD=<bot-password>
```
* You're done!

## Gotchas

Discourse has excellent user management controls. As a result your bot won't have full permissions until it is well
loved by your community. Your bot may fall silent when it hits reply limits, or won't be able to post images until it
reaches the correct trust level.

Heroku's free tier no longer runs 24/7. Your discbot may fall asleep.

## Have questions or issues? 

Please file them in github.

## License

MIT
