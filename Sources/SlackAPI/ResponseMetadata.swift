//
//  ResponseMetadata.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public struct ResponseMetadata: Decodable {
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case nextCursor = "next_cursor"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nextCursor = try container.decodeIfPresent(String.self, forKey: .nextCursor)
    }
}
