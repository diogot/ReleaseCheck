//
//  TunesAPI+Extensions.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation
import TunesAPI
import ArgumentParser

extension StoreRelease {
    var slackMessage: String {
        """
        **New release available for "\(name)" on \(platform.slackString)**
        
        Version: **\(version)**
        Release date: **\(
        date.formatted(
        .dateTime
        .weekday()
        .month()
        .day()
        .year()
        .hour(.defaultDigits(amPM: .abbreviated))
        .minute()
        .timeZone()
        .locale(.init(identifier: "en_us"))
        ))**
        Store link: "\(storeURL)"
        Release Notes:
        
        \(releaseNotes)
        
        msg-id: \(messageId)
        """
    }

    var messageId: String {
        "\(name)-\(platform.slackString)-\(version)-\(date.timeIntervalSince1970)"
    }
}

extension Platform: ExpressibleByArgument {
    public init?(argument: String) {
        switch argument.lowercased() {
        case "ios":
            self = .iOS
        case "tvos":
            self = .tvOS
        default:
            return nil
        }
    }

    var slackString: String {
        switch self {
        case .iOS:
            return "iOS"
        case .tvOS:
            return "tvOS"
        }
    }
}

