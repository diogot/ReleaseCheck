//
//  ChannelResponse.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public struct ChannelResponse: Decodable {
    public let channels: [Channel]
    public let metadata: ResponseMetadata

    enum CodingKeys: String, CodingKey {
        case channels
        case metadata = "response_metadata"
    }

    public init(from decoder: any Decoder) throws {
        try SlackResponsesError.checkForError(in: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.channels = try container.decode([Channel].self, forKey: .channels)
        self.metadata = try container.decode(ResponseMetadata.self, forKey: .metadata)
    }
}
