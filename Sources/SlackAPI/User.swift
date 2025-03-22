//
//  User.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public struct User: Decodable {
    public let user: String
    public let userId: String
    public let botId: String?

    enum CodingKeys: String, CodingKey {
        case user
        case userid = "user_id"
        case botId = "bot_id"
    }

    public init(from decoder: any Decoder) throws {
        try SlackResponsesError.checkForError(in: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decode(String.self, forKey: .user)
        self.userId = try container.decode(String.self, forKey: .userid)
        self.botId = try container.decodeIfPresent(String.self, forKey: .botId)
    }
}
