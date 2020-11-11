# React-time-tracker

 React/Redux project for Flatiron.
 Project implements a subset of employee time tracking system.

 ## Version

  - Ruby 2.7.0p0
  - Rail 6.0.3.4

## Environment variable

  - RAILS_JWT_ALG - Algorithm used for JWT, it defaults to HS256.
  - RAILS_JWT_SECRET_KEY - Secret key/ String for JWT Tokens.


## Installation

The package manager is [gems](https://rubygems.org/) managed by [bundler](https://bundler.io/).

1. Clone this project
2. Fill in `.env.example` and rename to `.env`
3. Run bash below

```bash
bundler install
bundler exec rails db:migrate
bundler exec rails db:seed # if you want test users
```

## Usage (with React project)

```bash
bundler exec rails s -p 3001
```
## Cors considerations

The Cors for the server is set to near `Allow All`.  If project is use for anything beyond example, it is best to tighten rules.

## License
[MIT](https://choosealicense.com/licenses/mit/)
