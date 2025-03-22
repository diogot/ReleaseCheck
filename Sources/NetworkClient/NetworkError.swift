//
//  NetworkError.swift
//  recheck
//
//  Created by Diogo on 22/03/25.
//

import Foundation

public enum NetworkError: Error {
    case invalidBaseURL(String)
    case invalidURL(String)
}
