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
    private let channelName: String
    private var _userId: String?
    private var _channelId: String?

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
        self.verbose = verbose
        self.channelName = channelName
    }

    func publishRelease(of appId: String, on platform: Platform) async throws {
        print("Publishing release for \(appId) on \(platform)...")
        let release = try await tunes.fetchCurrentRelease(appId: appId, platform: platform)
        let existentMessage = try await slack.searchMessage(
            with: release.messageId,
            inChannel: channelId(),
            fromUser: userId(),
            after: release.date
        )

        guard existentMessage == nil else {
            print("Release already posted for \(appId) on \(platform)")
            return
        }

        try await slack.postMessage(toChannelWithId: channelId(), release.slackMessage)
        print("Release published for \(appId) on \(platform)!")
    }

    func deleteAllMessages() async throws {
        print("Deleting all messages...")
        let messages = try await slack.searchMessages(with: nil, inChannel: channelId(), fromUser: userId())
        for message in messages {
            try await slack.deleteMessage(message.ts, inChannel: channelId())
        }
        print("All messages deleted!")
    }

    func printRelease(of appId: String, on platform: Platform) async throws {
        let release = try await tunes.fetchCurrentRelease(appId: appId, platform: platform)
        print(release.slackMessage)
    }

    private func userId() async throws -> String {
        if let userId = _userId {
            return userId
        }
        
        let userInfo = try await slack.whoAmI()
        self._userId = userInfo.user
        return userInfo.user
    }

    private func channelId() async throws -> String {
        if let channelId = _channelId {
            return channelId
        }

        let channelId = try await slack.channel(withName: channelName).id
        self._channelId = channelId
        return channelId
    }
}
