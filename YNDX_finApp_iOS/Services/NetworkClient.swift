//
//  NetworkClient.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 18.07.2025.
//

import Foundation

final class NetworkClient {
    static let shared = NetworkClient()
    private let baseURL = URL(string: "https://shmr-finance.ru/api/v1/")!
    private let token: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        guard let token = "подставьте токен", !token.isEmpty else {
            fatalError("API_TOKEN is missing")
        }
        self.token = token
    }
    
    enum NetworkError: Error {
        case invalidResponse
        case httpError(code: Int, data: Data)
        case decoding(Error)
        case encoding(Error)
        case unknown(Error)
    }
    
    func request<Request: Encodable, Response: Decodable>(
        endpoint: String,
        method: String = "GET",
        requestBody: Request? = nil
    ) async throws -> Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        urlRequest.httpMethod = method
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = requestBody {
            do {
                urlRequest.httpBody = try await withCheckedThrowingContinuation { continuation in
                    DispatchQueue.global().async {
                        do {
                            let data = try self.encoder.encode(body)
                            continuation.resume(returning: data)
                        } catch {
                            continuation.resume(throwing: NetworkError.encoding(error))
                        }
                    }
                }
            } catch {
                throw error
            }
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw NetworkError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(code: httpResponse.statusCode, data: data)
        }
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global().async {
                    do {
                        let decoded = try self.decoder.decode(Response.self, from: data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: NetworkError.decoding(error))
                    }
                }
            }
        } catch {
            throw error
        }
    }
}
