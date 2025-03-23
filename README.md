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

# GitHub Action

This repository also provides a [GitHub Action](https://github.com/diogot/ReleaseCheck/blob/main/action.yml). This action requires a macOS host.
Here is a sample workflow that offers a manual trigger and automatically checks hourly:

```YAML
name: 'Publish Released to Slack'

on:
  schedule:
    - cron: '42 * * * *' # every hour at 42 minutes
  workflow_dispatch:

jobs:
  recheck:
    name: 'Release Check'
    runs-on: [macos-latest]

    steps:
      - name: ReleaseCheck
        uses: diogot/ReleaseCheck@1.0 # Check the latest release available
        with:
          apple-id: ${{ vars.APPLE_ID }}
          platforms: 'iOS tvOS'
          slack-channel: ${{ vars.SLACK_CHANNEL }}
          slack-bot-token: ${{ secrets.SLACK_TOKEN }}
          verbose: true
```
