//
//  ConversationHistoryResponse.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public struct ConversationHistoryResponse: Decodable {
    public let messages: [Message]
    public let metadata: ResponseMetadata?

    enum CodingKeys: String, CodingKey {
        case messages
        case metadata = "response_metadata"
    }

    public init(from decoder: any Decoder) throws {
        try SlackResponsesError.checkForError(in: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messages = try container.decode([Message].self, forKey: .messages)
        self.metadata = try container.decodeIfPresent(ResponseMetadata.self, forKey: .metadata)
    }
}
