//
//  recheck.swift
//  recheck
//
//  Created by Diogo on 19/03/25.
//

import ArgumentParser
import TunesAPI

@main
struct recheck: AsyncParsableCommand {

    @Option(name: [.customShort("a"), .customLong("apple-id")], help: "Apple App Id")
    var appId: String

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Platform (iOS and/or tvOS)")
    var platforms: [Platform]

    @Option(name: [.customShort("c"), .customLong("channel")], help: "Slack Channel Name")
    var slackChannelName: String

    @Option(name: [.customShort("t"), .customLong("token")], help: "Slack token")
    var slackToken: String

    @Flag(name: .shortAndLong)
    var verbose: Bool = false

    mutating func run() async throws {
        let checker = try await Checker(slackToken: slackToken, channelName: slackChannelName, verbose: verbose)

        for platform in platforms {
            try await checker.pubishRelease(of: appId, on: platform)
        }
    }
}
