//
//  Message.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public struct Message: Decodable {
    let ts: String
    let user: String
    let text: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case ts
        case user
        case text
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ts = try container.decode(String.self, forKey: .ts)
        self.user = try container.decode(String.self, forKey: .user)
        self.text = try container.decode(String.self, forKey: .text)
        self.type = try container.decode(String.self, forKey: .type)
    }
}
