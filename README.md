# Cardigan · Play card games online

[![Build Status](https://travis-ci.com/Nagasaki45/cardigan.svg?branch=master)](https://travis-ci.com/Nagasaki45/cardigan)

**:point_right: This project is not yet ready for prime time! There are bugs and a few crucial features are missing. Come back later, it will eventually work :pray:**

An online alternative for board games for the `#covid19` days.

**Features**

- [x] Open sandbox for playing card games.
- [x] User defined games, off the server: Define a game by creating a `json` file and upload to the site to open a table with friends.
- [ ] Games generator.

## Development

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

To a [Dokku](https://dokku.com/) instance running on a [Digital Ocean](https://digitalocean.com) droplet with `git push dokku master`. DNS through [cloudflare](https://cloudflare.com).
