[![Gem Version](http://badge.fury.io/rb/itamae-plugin-recipe-anyenv.svg)](http://badge.fury.io/rb/itamae-plugin-recipe-anyenv)
# Itamae::Plugin::Recipe::Anyenv

Itamae plugin to install anyenv

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'itamae-plugin-recipe-anyenv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install itamae-plugin-recipe-anyenv

## Usage
### System wide
System wide anyenv installation

install directory is `ANYENV_ROOT` enviroment

`export ANYENV_ROOT=~/.anyenv`

or prease use the direnv

#### Recipe

```ruby
# your recipe
include_recipe "anyenv::system"
```

#### Node

Use this with `itamae -y node.yml`

```yml
anyenv:
  install_versions:
    rbenv:
      - 2.2.2
    exenv:
      - 1.0.5
```

#### .bashrc

Recommend to append this to .bashrc in your server.

```bash
export ANYENV_ROOT="/usr/local/anyenv"
export PATH="${ANYENV_ROOT}/.anyenv/bin:$PATH"
if which anyenv > /dev/null; then eval "$(anyenv init -)"; fi
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

