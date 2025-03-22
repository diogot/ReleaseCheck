//
//  StoreRelease.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public struct StoreRelease: Decodable {
    public let name: String
    public let version: String
    public let date: Date
    public let releaseNotes: String
    public let storeURL: URL
    public let platform: Platform

    private enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case version
        case date = "currentVersionReleaseDate"
        case releaseNotes
        case storeURL = "trackViewUrl"
        case supportedDevices
    }

    public init(from decoder: any Decoder) throws {
        let containter = try decoder.container(keyedBy: CodingKeys.self)
        name = try containter.decode(String.self, forKey: .name)
        version = try containter.decode(String.self, forKey: .version)
        date = try containter.decode(Date.self, forKey: .date)
        releaseNotes = try containter.decode(String.self, forKey: .releaseNotes)
        storeURL = try containter.decode(URL.self, forKey: .storeURL)
        let supportedDevices = try containter.decode([String].self, forKey: .supportedDevices)
        if supportedDevices.contains(where: { $0.hasPrefix("AppleTV") }) {
            platform = .tvOS
        } else if supportedDevices.contains(where: { $0.hasPrefix("iPhone") }) {
            platform = .iOS
        } else {
            throw TunesAPIError.unknownPlatform
        }
    }
}
