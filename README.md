[![Build Status](https://travis-ci.org/somebody32/task-watchr.svg?branch=master)](https://travis-ci.org/somebody32/task-watchr)


# Task Watchr

## What is this?
This is a simple way to create tasks in your favourite task management systems
via twitter mentions.

## Current Architecture And Features
The project splits into the two parts: the core and the frontend.

The core lives inside `lib`-directory. It designed to be fully independent from
any frontend, so it is possible to call it from terminal or web-interface.
It requires right social credentials passed as arguments and right settings for
task-managment adapters to be stored inside Redis.

The frontend is a rails app, that gives a user an opportunity to easily connect
twitter and task mgmt accounts, configure adapters and kick-off the fetchr.

### Features

* Twitter's rate-limits handling
* Full importing of your mentions timeline
* Watching for a new mentions
* Possibility to work in sync/async mode
* Redbooth integration & Token updates

## Current limitations

### Core limitations

* No way to stop the fetchr

### Frontend Limitations

* Adapters settings page is too coupled with the main site, better to be
an engine
* Redbooth settings page makes a sync-network call to get a list of tasklists
* Adding new adapters should be simplified

## How to add a new adapter?

### Core support

* Add new adapter to `lib/social_posts/adapters`. It should respond to
`post_task` method.
* Add TokenUpdater class if needed
* Extend `SocialPostr::ADAPTERS_LIST` with your adapter's name

### Frontend

* Create settings page for the adapter
* Extend `FetchrStatusDecorator` to support statuses for it

## How to run locally?

* clone it
* `bundle install`
* take a look into `.env.sample` and create your own `.env` with right values
* run tests `bundle exec rspec`. Note that twitter fetch specs will fail even
with right ENV-vars, because its bundled to a specific account

