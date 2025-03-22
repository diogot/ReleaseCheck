# ReleaseCheck

A command line tool that fetches released iOS and tvOS apps from the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html) and publishes in a Slack channel (if not published yet).

# Usage

## Requirements

### App Apple ID

Apple id of the released app, it's the number in the App Store url of the app, for example in https://apps.apple.com/us/app/nebula/id1447033725, the Apple Id is `1447033725`.

### Platform

This tool current supports iOS and tvOS releases.

### Slack bot token

You need a [Slack API bot](https://api.slack.com/tutorials/tracks/getting-a-token) that have the Bot Token Scopes:

- [channels:read](https://api.slack.com/scopes/channels:read): to get the channel id from the specified name
- [channels:history](https://api.slack.com/scopes/channels:history): to check if the messages was already posted to the channel
- [chat:write](https://api.slack.com/scopes/chat:write): to post the message

### Slack channel name

A public existent channel where the bot has already joined

## Run

```
swift run recheck -a <app id> -p ios -t <slack bot token> -c <slack channel name>
```
