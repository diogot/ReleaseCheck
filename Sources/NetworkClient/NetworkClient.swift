//
//  NetworkClient.swift
//  recheck
//
//  Created by Diogo on 21/03/25.
//

import Foundation

public class NetworkClient {
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    public init(session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    public func request<T: Decodable>(
        baseURL url: String,
        method: Method = .get,
        parameters: [String: String?] = [:],
        headers: [String: String] = [:]
    ) async throws -> T {
        try await request(baseURL: url, parameters: parameters, method: method, headers: headers, body: EmptyData())
    }

    public func request<T: Decodable, S: Encodable>(
        baseURL: String,
        parameters: [String: String?] = [:],
        method: Method = .get,
        headers: [String: String] = [:],
        body: S?
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw NetworkError.invalidBaseURL(baseURL)
        }

        let queryItems = parameters
            .compactMap({ URLQueryItem(name: $0.key, value: $0.value) })
            .sorted(by: { $0.name < $1.name })
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL(urlComponents.description)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        headers.forEach { (key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body, body is EmptyData == false {
            request.httpBody = try encoder.encode(body)
        }

        let (data, result) = try await session.data(for: request)
        if let result = result as? HTTPURLResponse {
            print("\(method) \(url): \(result.statusCode)")
        }

        do {
            let response = try decoder.decode(T.self, from: data)
            return response
        } catch {
            print("")
            print(String(data: data, encoding: .utf8) ?? "No data")
            print("")
            throw error
        }
    }
}
