# app47gem

## Introduction
This gem was crafted to help folks interact with the App47 (http://www.app47.com) REST APIs. 

## Current Status
Infancy. Focused on my initial needs, which was simply uploading builds. But everything starts somewhere

Added a gem executable 'app47' to wrap the lib code.

>Usage: app47 builds subcmd [options]
>Sub commands: create read
>
>EXAMPLES
>
>Reading the list of builds for an app:
>  app47 builds read -k <apiKey> -a appId
>
>Reading a specific build:
>  app47 builds read -k <apiKey> -a appId -b buildId
>
>Creating a new build (e.g., posting a build):
>  app47 builds create -k <apiKey> -a appId -V vers -f buildFilePath \[-n notes\] \[--makeActive\]
>

Added support for a $HOME/.app47rc file to set global apiKey and appId settings. Command line switches will override.

## Dependencies
This gem uses:

*   [rest-client](http://rubygems.org/gems/rest-client)
*   [json](http://rubygems.org/gems/json)
