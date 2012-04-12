# app47gem

## Introduction
This gem was crafted to help folks interact with the [App47](http://www.app47.com) REST APIs. 

## Current Status
Infancy. Focused on my initial needs, which was simply uploading builds, and creating users. But everything starts somewhere.

* Added a gem executable `app47` to wrap the lib code.
* Added support for a `$HOME/.app47rc` file to set global apiKey and appId settings. Command line switches will override.

## Getting started ##
		gem install app47
		app47 -h


## Dependencies ##

This gem uses:

*   [rest-client](http://rubygems.org/gems/rest-client)
*   [json](http://rubygems.org/gems/json)
*   [roo](http://rubygems.org/gems/roo)
