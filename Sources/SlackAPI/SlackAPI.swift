//
//  SlackAPI.swift
//  recheck
//
//  Created by Diogo on 21/03/25.
//

import Foundation
import NetworkClient

public class SlackAPI {
    private let token: String
    private let client: NetworkClient

    public var verbose: Bool {
        didSet {
            client.verbose = verbose
        }
    }

    public init(token: String, client: NetworkClient = .init(), verbose: Bool = false) {
        client.verbose = verbose
        self.token = token
        self.client = client
        self.verbose = verbose
    }

    public func post(toChannelWithName channelName: String, _ text: String) async throws {
        try await postMessage(toChannelWithId: channel(withName: channelName).id, text)
    }

    public func channel(withName name: String) async throws -> Channel {
        if verbose {
            print("Fetching channel named \(name)...")
        }
        let channels = try await listAllChannels()
        guard let channel = channels.first(where: { $0.name == name }) else {
            throw SlackResponsesError.channelNotFound(name)
        }

        return channel
    }

    public func listAllChannels() async throws -> [Channel] {
        var allChannels: [Channel] = []
        var cursor: String?
        
        repeat {
            let response = try await listChannels(cursor: cursor)
            allChannels.append(contentsOf: response.channels)
            cursor = response.metadata.nextCursor
        } while cursor != nil && cursor != ""

        return allChannels
    }

    public func listChannels(cursor: String? = nil) async throws -> ChannelResponse {
        var parameters = ["exclude_archived": "true"]
        if let cursor {
            parameters["cursor"] = cursor
        }

        return try await client.request(
            baseURL: "https://slack.com/api/conversations.list",
            parameters: parameters,
            headers: headers()
        )
    }

    public func postMessage(toChannelWithId channelId: String, _ text: String) async throws {
        if verbose {
            print("Posting release message to channel \(channelId)...")
        }
        let _: EmptyResponse = try await client.request(
            baseURL: "https://slack.com/api/chat.postMessage",
            method: .post,
            headers: headers(),
            body: MessageData(channel: channelId, text: text)
        )
    }

    public func searchMessage(with text: String, inChannel channelId: String, fromUser userId: String?) async throws -> Message? {
        var message: Message?
        var cursor: String?

        if verbose {
            print("Searching for \"\(text)\" of user \(userId ?? "<any>") in channel \(channelId)...")
        }
        repeat {
            let response = try await conversationsHistory(channelId: channelId, cursor: cursor)
            message = response.messages.first(where: { message in
                if let userId {
                    guard userId == message.user else {
                        return false
                    }
                }

                return message.text.contains(text)
            })
            cursor = response.metadata?.nextCursor
        } while message != nil && cursor != nil && cursor != ""

        return message
    }

    public func searchMessages(with text: String?, inChannel channelId: String, fromUser userId: String?) async throws -> [Message] {
        if verbose {
            print("Searching for messages in channel \(channelId) with text \"\(text ?? "<any>")\" of user \(userId ?? "<any>")...")
        }
        var messages: [Message] = []
        var cursor: String?

        repeat {
            let response = try await conversationsHistory(channelId: channelId, cursor: cursor)
            messages.append(contentsOf: response.messages.filter({ message in
                if let userId {
                    guard userId == message.user else {
                        return false
                    }
                }
                if let text {
                    return message.text.contains(text)
                }
                return true
            }))
            cursor = response.metadata?.nextCursor
        } while cursor != nil && cursor != ""

        return messages
    }

    public func deleteMessage(_ messageId: String, inChannel channelId: String) async throws {
        if verbose {
            print("Deleting message \(messageId) in channel \(channelId)...")
        }
        let _: EmptyResponse = try await client.request(
            baseURL: "https://slack.com/api/chat.delete",
            method: .post,
            headers: headers(),
            body: DeleteData(channel: channelId, ts: messageId)
        )
    }

    public func conversationsHistory(channelId: String, cursor: String? = nil) async throws -> ConversationHistoryResponse {
        var parameters = ["channel": channelId]
        if let cursor {
            parameters["cursor"] = cursor
        }

        return try await client.request(
            baseURL: "https://slack.com/api/conversations.history",
            parameters: parameters,
            headers: headers()
        )
    }

    public func whoAmI() async throws -> User {
        if verbose {
            print("Fetching current user information...")
        }
        return try await client.request(
            baseURL: "https://slack.com/api/auth.test",
            method: .post,
            headers: headers()
        )
    }

    private func headers() -> [String: String] {
        return ["Authorization": "Bearer \(token)"]
    }
}

private struct MessageData: Encodable {
    let channel: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case channel
        case text = "markdown_text"
    }
}

private struct DeleteData: Encodable {
    let channel: String
    let ts: String
}
