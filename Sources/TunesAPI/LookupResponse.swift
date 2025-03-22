//
//  LookupResponse.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

struct LookupResponse: Decodable {
    let resultCount: Int
    let results: [StoreRelease]
}
