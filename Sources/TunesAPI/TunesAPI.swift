//
//  TunesAPI.swift
//  recheck
//
//  Created by Diogo on 20/03/25.
//

import Foundation
import NetworkClient

public class TunesAPI {
    private let client: NetworkClient

    public init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.client = NetworkClient(decoder: decoder)
    }

    public init(client: NetworkClient) {
        self.client = client
    }

    public func fetchCurrentRelease(appId id: String, platform: Platform) async throws -> StoreRelease {
        let response: LookupResponse = try await client.request(
            baseURL: "https://itunes.apple.com/lookup",
            parameters: [
                "id": id,
                "entity": platform.entity
            ]
        )

        guard let release = response.results.first else {
            throw TunesAPIError.notFound
        }

        return release
    }
}

extension Platform {
    fileprivate var entity: String {
        switch self {
        case .iOS:
            return "software"
        case .tvOS:
            return "tvSoftware"
        }
    }
}
