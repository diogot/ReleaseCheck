//
//  recheck.swift
//  recheck
//
//  Created by Diogo on 19/03/25.
//

import ArgumentParser
import TunesAPI
import SlackAPI

@main
struct recheck: AsyncParsableCommand {

    @Option(name: [.customShort("a"), .customLong("apple-id")], help: "Apple App Id")
    var appId: String

    @Option(name: .shortAndLong, help: "Platform (iOS or tvOS)")
    var platform: Platform

    @Option(name: [.customShort("c"), .customLong("channel")], help: "Slack Channel Name")
    var slackChannelName: String

    @Option(name: [.customShort("t"), .customLong("token")], help: "Slack token")
    var slackToken: String

    mutating func run() async throws {

        let tunes = TunesAPI()
        let release = try await tunes.fetchCurrentRelease(appId: appId, platform: platform)

        let slack = SlackAPI(token: slackToken)
        let userId = try await slack.whoAmI().userId
        let channelId = try await slack.channel(withName: slackChannelName).id
        let existentMessage = try await slack.searchMessage(with: release.messageId, inChannel: channelId, fromUser: userId)

        guard existentMessage == nil else {
            print("Release already posted")
            return
        }

        try await slack.postMessage(toChannelWithId: channelId, release.slackMessage)
    }
}
