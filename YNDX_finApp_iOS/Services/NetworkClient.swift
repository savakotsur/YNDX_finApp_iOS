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
        let token = "FmamhAubQbdv85BDY2IkOdK5"
        self.token = token
        
        // Настройка для работы с датами
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        // Настройка для работы с Decimal
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
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
        let fullURL = URL(string: endpoint, relativeTo: baseURL)!
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = method
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = requestBody {
            do {
                let encodedData: Data
                do {
                    encodedData = try self.encoder.encode(body)
                } catch {
                    throw NetworkError.encoding(error)
                }
                urlRequest.httpBody = encodedData
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
            print("HTTP Error \(httpResponse.statusCode): \(String(data: data, encoding: .utf8) ?? "No data")")
            throw NetworkError.httpError(code: httpResponse.statusCode, data: data)
        }
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global().async {
                    // Prevent decoding empty data, regardless of Response type
                    guard !data.isEmpty else {
                        continuation.resume(throwing: NetworkError.decoding(
                            DecodingError.dataCorrupted(
                                .init(codingPath: [], debugDescription: "Received empty response data but expected JSON.")
                            )
                        ))
                        return
                    }
                    do {
                        let decoded = try self.decoder.decode(Response.self, from: data)
                        continuation.resume(returning: decoded)
                    } catch {
                        print("Decoding error: \(error)")
                        print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                        continuation.resume(throwing: NetworkError.decoding(error))
                    }
                }
            }
        } catch {
            throw error
        }
    }
}
