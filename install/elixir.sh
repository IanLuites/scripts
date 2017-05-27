#/bin/sh

set -e

erl -version
if [ $? -ne 0 ]; then
  ./install/erlang.sh
fi

iex -v
if [ $? -ne 0 ]; then
  export ELIXIR_VERSION=1.4.4

  wget --no-check-certificate https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip
  mkdir -p /opt/elixir-${ELIXIR_VERSION}/
  unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/
  rm Precompiled.zip

  ln -s /opt/elixir-${ELIXIR_VERSION}/bin/iex /bin/iex
  ln -s /opt/elixir-${ELIXIR_VERSION}/bin/elixir /bin/elixir
  ln -s /opt/elixir-${ELIXIR_VERSION}/bin/mix /bin/mix
fi

mix local.hex --force
mix local.rebar --force
mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez
