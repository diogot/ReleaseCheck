//
//  SlackResponsesError.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public enum SlackResponsesError: Error {
    case invalidResponse(String)
    case channelNotFound(String)

    private enum CodingKeys: String, CodingKey  {
        case ok
        case error
    }

    static func checkForError(in decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let success = try container.decode(Bool.self, forKey: .ok)

        guard success else {
            let error = try container.decode(String.self, forKey: .error)
            throw SlackResponsesError.invalidResponse(error)
        }
    }
}

