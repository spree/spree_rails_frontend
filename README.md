# Spree (Legacy) Frontend

This is the old Spree Storefront extracted from Spree < 4.3 which was upgraded to Turbo/Hotwire.

## Developed by

[![Vendo](https://assets-global.website-files.com/6230c485f2c32ea1b0daa438/623372f40a8c54ca9aea34e8_vendo%202.svg)](https://getvendo.com?utm_source=spree_frontend_github)

> All-in-one platform for all your Marketplace and B2B eCommerce needs. [Start your 30-day free trial](https://e98esoirr8c.typeform.com/contactvendo?typeform-source=spree_sdk_github)

## Installation

Add

```ruby
gem 'spree_frontend'
```

to your `Gemfile`, making sure that the `spree_frontend` gem is before `spree_auth_devise`.

Make sure both `gem 'jsbundling-rails'` and `gem 'turbo-rails'` are added as well.

Run:

```bash
bundle install
bin/rails javascript:install:esbuild
bin/rails turbo:install
bin/rails g spree:frontend:install
yarn build
```

### Troubleshooting

#### Disabled 'Add to Cart' Button Issue

If you notice that the 'Add to Cart' button is disabled on product pages, try the following:
* run `yarn build` again in your main repo
* if that doesn't fix the issue, try running the following setup commands again:
  ```
  bin/rails javascript:install:esbuild
  bin/rails turbo:install
  bin/rails g spree:frontend:install
  yarn build
  rake assets:clean assets:precompile
  ```

This issue may come up if you switch the source of your `spree_frontend` in your Gemfile, e.g. from github to a local path, etc.

#### Checkout without logging in results in 500 error

When you navigate to checkout without logging in first, you may get a a 500 error notifying you that "yourdomain.com redirected you too many times."

This error results from the routes defined in `spree_frontend` and `spree_auth_devise` not being built in the correct order. Make sure the `spree_frontend` gem is listed before `spree_auth_devise` in your main project's gemfile, then try again.

## Running Tests

In order to generate the dummy app required for running tests, you’ll need to have the following installed on your machine:
* node v16.13.1 (npm v8.1.2)
* yarn ≥ v1.22.15
* ruby v3.0.3

To run tests locally, first run `bundle exec rake test_app`, then `bundle exec rspec`.

### Troubleshooting
If you are running on a Mac with an M1 processor, you may run into the following error when running tests:
```          
Webdrivers::NetworkError:
Net::HTTPServerException: 404 "Not Found"
```
If so, update your gemfile locally to get version 5.0 or higher for the web drivers gem:
```
gem 'webdrivers', '~> 5.0'
```

## Customization

[Developer documentation](https://dev-docs.spreecommerce.org/customization/storefront)
