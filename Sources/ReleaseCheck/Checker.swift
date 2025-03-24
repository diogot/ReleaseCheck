//
//  Checker.swift
//  ReleaseCheck
//
//  Created by Diogo on 23/03/25.
//

import Foundation
import SlackAPI
import TunesAPI

class Checker {
    private let tunes: TunesAPI
    private let slack: SlackAPI
    private let userId: String
    private let channelId: String

    var verbose: Bool {
        didSet {
            tunes.verbose = verbose
            slack.verbose = verbose
        }
    }

    init(slackToken: String, channelName: String, verbose: Bool = false) async throws {
        self.tunes = TunesAPI(verbose: verbose)
        let slack = SlackAPI(token:slackToken, verbose: verbose)
        self.slack = slack
        self.userId = try await slack.whoAmI().userId
        self.channelId = try await slack.channel(withName: channelName).id
        self.verbose = verbose
    }

    func publishRelease(of appId: String, on platform: Platform) async throws {
        print("Publishing release for \(appId) on \(platform)...")
        let release = try await tunes.fetchCurrentRelease(appId: appId, platform: platform)
        let existentMessage = try await slack.searchMessage(
            with: release.messageId,
            inChannel: channelId,
            fromUser: userId,
            after: release.date
        )

        guard existentMessage == nil else {
            print("Release already posted for \(appId) on \(platform)")
            return
        }

        try await slack.postMessage(toChannelWithId: channelId, release.slackMessage)
        print("Release published for \(appId) on \(platform)!")
    }

    func deleteAllMessages() async throws {
        print("Deleting all messages...")
        let messages = try await slack.searchMessages(with: nil, inChannel: channelId, fromUser: userId)
        for message in messages {
            try await slack.deleteMessage(message.ts, inChannel: channelId)
        }
        print("All messages deleted!")
    }

    func printRelease(of appId: String, on platform: Platform) async throws {
        let release = try await tunes.fetchCurrentRelease(appId: appId, platform: platform)
        print(release.slackMessage)
    }
}
