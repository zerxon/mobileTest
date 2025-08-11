//
//  BookingService.swift
//  mobileTest
//
//  Created by walllceleung on 8/8/2025.
//

import Foundation
import Combine
import SwiftyJSON

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError
    case serverError(String)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .decodingError:
            return "Error decoding data"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

protocol BookingServiceProtocol {
    func fetchBooking() -> AnyPublisher<Booking, NetworkError>
}

class BookingService: BookingServiceProtocol {
    
    // 模拟网络请求，延迟1秒
    func fetchBooking() -> AnyPublisher<Booking, NetworkError> {
        return Future<Booking, NetworkError> { promise in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                guard let url = Bundle.main.url(forResource: "booking", withExtension: "json") else {
                    promise(.failure(.invalidURL))
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let json = try JSON(data: data)
                    let booking = Booking(json: json)
                    
                    promise(.success(booking))
                } catch {
                    debugLog("加载booking数据错误: \(error.localizedDescription)")
                    promise(.failure(.decodingError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
