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

    public var verbose: Bool {
        didSet {
            client.verbose = verbose
        }
    }

    public init(verbose: Bool = false) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.client = NetworkClient(decoder: decoder, verbose: verbose)
        self.verbose = verbose
    }

    public init(client: NetworkClient, verbose: Bool = false) {
        client.verbose = verbose
        self.client = client
        self.verbose = verbose
    }

    public func fetchCurrentRelease(appId id: String, platform: Platform) async throws -> StoreRelease {
        if verbose {
            print("Fechting current release for appId \(id) in \(platform) platform...")
        }
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
