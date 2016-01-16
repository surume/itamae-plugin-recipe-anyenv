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

#### Recipe

```ruby
# your recipe
include_recipe "anyenv::system"
```

#### Node

Use this with `itamae -y node.yml`

```yml
anyenv:
  anyenv_root: "/path/to/anyenv"
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

### Users
#### Recipe
```ruby
# your recipe
include_recipe "anyenv::users"
```

#### Node
Use this with `itamae -y node.yml`

```yml
anyenv:
  users:
    taro:
      install_versions:
        rbenv:
          - 2.2.2
        exenv:
          - 1.0.5
    jiro:
      anyenv_root: /opt/jiro/.anyenv
      install_versions:
        ndenv:
          - v0.12.7
```

You can configure default attributes:

```yml
anyenv:
  # default attributes
  install_versions:
    rbenv:
      - 2.2.2
    exenv:
      - 1.0.5

  # users configurations
  users:
    taro: {}
    jiro:
      install_versions:
        rbenv:
          - 2.2.3
```

In default, use `/home/username/.anyenv` as anyenv root directory.

#### .bashrc

Recommend to append this to .bashrc in your server.

```bash
export ANYENV_ROOT="/home/username/.anyenv"
export PATH="${ANYENV_ROOT}/bin:$PATH"
if which anyenv > /dev/null; then eval "$(anyenv init -)"; fi
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

