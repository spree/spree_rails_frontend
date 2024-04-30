# Spree Rails Frontend

This is the Spree Storefront extracted from Spree < 4.3 which was upgraded to Turbo and Hotwire.
It is based on Bootstrap 4. It is battle tested and is used in production by many stores.

This storefront includes also Checkout and Cart functionality providing a complete shopping experience.

## Developed by

<a href="https://getvendo.com?utm_source=spree_auth_github"><img src="https://cdn.getvendo.com/assets/vendo-logo-4bda02af8c99bc2ecc5a400120f0ebe4eafcd385e02e25f198a8c355ab75d1ff.png" height=50 alt="Vendo - Start your own multi-brand marketplace" /></a>

<a href="http://sparksolutions.co?utm_source=github"><img src="https://sparksolutions.co/wp-content/themes/sparksolutions/images/logo.svg" height=50 alt="Spark Solutions - Ruby on Rails and Spree Commerce developers"></a>

## Installation

Run

```bash
bundle add 'spree_frontend'
```

Make sure that the `spree_frontend` gem is before `spree_auth_devise`.

Run:

```bash
bundle install
bin/rails g spree:frontend:install
```

### Development

You can easily import all storefront templates to your application by running:

```bash
bin/rails g spree:frontend:copy_storefront
```

This will allow you to easily customize the look and feel of your storefront.

### Troubleshooting

#### Disabled 'Add to Cart' Button Issue

If you notice that the 'Add to Cart' button is disabled on product pages, try the following:
  
  ```bash
  bin/rails turbo:install
  bin/rails g spree:frontend:install
  bundle exec rake assets:clean assets:precompile
  ```

This issue may come up if you switch the source of your `spree_frontend` in your Gemfile, e.g. from github to a local path, etc.

#### Checkout without logging in results in 500 error

When you navigate to checkout without logging in first, you may get a a 500 error notifying you that "yourdomain.com redirected you too many times."

This error results from the routes defined in `spree_frontend` and `spree_auth_devise` not being built in the correct order. Make sure the `spree_frontend` gem is listed before `spree_auth_devise` in your main project's gemfile, then try again.

## Running Tests

To run tests locally, first run `bundle exec rake test_app`, then `bundle exec rspec`.

### Troubleshooting

If you are running on a Mac with an M1 processor, you may run into the following error when running tests:

```bash
Webdrivers::NetworkError:
Net::HTTPServerException: 404 "Not Found"
```

If so, update your gemfile locally to get version 5.0 or higher for the web drivers gem:

```bash
gem 'webdrivers', '~> 5.0'
```

## Customization

[Developer documentation](https://docs.spreecommerce.org/customization/storefront)
