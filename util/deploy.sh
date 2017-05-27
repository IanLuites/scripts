#/bin/sh

set -e

export SOME_APP_SSL_CERT_PATH="/etc/letsencrypt/live/phoenix.droplet.thecrypts.nl/fullchain.pem"
export SOME_APP_SSL_KEY_PATH="/etc/letsencrypt/live/phoenix.droplet.thecrypts.nl/privkey.pem"
export DATABASE_URL="mysql://phoenix:elixir@localhost/test"
export PHOENIX_HOST="phoenix.droplet.thecrypts.nl"

cd ~/app/phoenix/

set +e
kill $(cat pid)
set -e

git pull

MIX_ENV=prod mix deps.get
MIX_ENV=prod mix deps.compile

cd assets
npm install
node node_modules/brunch/bin/brunch build --production
cd ..

MIX_ENV=prod mix phoenix.digest

mkdir -p priv/repo/migrations
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate

PORT=80 MIX_ENV=prod elixir --detached -e "File.write! 'pid', :os.getpid" -S mix phx.server
