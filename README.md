# Reviewed::Cache::Key

This is a gem for making cache keys, plain and simple.

## Installation

Add this line to your application's Gemfile:

    gem 'reviewed-cache-key', github: 'reviewed/reviewed-cache-key'

And then execute:

    $ bundle

## Usage

Configure via configatron. e.g:

    configatron.reviewed_page_cache.allow_query_params = %w{search_queries price name etc}
    configatron.reviewed_cache_key.ignore_query_params = %w{cache-things utm_source bad-params}
