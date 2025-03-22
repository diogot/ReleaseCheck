//
//  EmptyResponse.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

struct EmptyResponse: Codable {
    init(from decoder: any Decoder) throws {
        try SlackResponsesError.checkForError(in: decoder)
    }
}
