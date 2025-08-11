//
//  BookingDataManager.swift
//  mobileTest
//
//  Created by walllceleung on 9/8/2025.
//

import Foundation
import RealmSwift
import Combine

enum DataError: Error {
    case realmError(Error)
    case networkError(NetworkError)
    case dataExpired
    case noDataAvailable
    
    var description: String {
        switch self {
        case .realmError(let error):
            return "Realm error: \(error.localizedDescription)"
        case .networkError(let error):
            return error.description
        case .dataExpired:
            return "Data has expired"
        case .noDataAvailable:
            return "No data available"
        }
    }
    
}

class BookingDataManager {
    private let service: BookingServiceProtocol
    private let realm: Realm
    private let cacheExpiryTime: TimeInterval = 300 // 5分钟时效
    
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = BookingDataManager()
    
    init(service: BookingServiceProtocol = BookingService()) {
        self.service = service
        
        // 在主线程初始化Realm
        do {
            let config = Realm.Configuration.defaultConfiguration
            self.realm = try Realm(configuration: config)
            debugLog("Realm初始化完成，路径: \(realm.configuration.fileURL?.path ?? "未知")")
            
            // 初始化时清理过期booking数据
            try clearExpiredCache()
        } catch {
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // 获取预订数据，如果缓存有效则返回，否则从网络获取
    func getBookingData() -> AnyPublisher<Booking, DataError> {
        // 检查有没有效缓存
        if let cachedBooking = getCachedBooking(), isCacheValid(cachedBooking) {
            
            return Just(cachedBooking)
                .setFailureType(to: DataError.self)
                .eraseToAnyPublisher()
        }
        
        // 如果没有有效缓存，则从网络获取
        return fetchAndCacheBooking()
    }
    
    // 强制通过网络刷新，忽略缓存
    func refreshBookingData() -> AnyPublisher<Booking, DataError> {
        return fetchAndCacheBooking()
    }
    
    // 删除数据库中的过期缓存
    func clearExpiredCache() throws {
        let bookings = realm.objects(Booking.self)
        let expiredBookings = bookings.filter { booking in
            // 检查booking是否过期（根据expiryTime）
            if !booking.isValid {
                return true
            }
            
            // 检查本地缓存是否过期（根据fetchTimestamp）
            let cacheAge = Date().timeIntervalSince(booking.fetchTimestamp)
            return cacheAge >= self.cacheExpiryTime
        }
        
        if !expiredBookings.isEmpty {
            try realm.write {
                
                let count = expiredBookings.count
                realm.delete(expiredBookings)
                
                debugLog("清除了 \(count) 个过期的booking")
            }
        } else {
            debugLog("缓存中未找到过期的booking")
        }
    }
    
    // MARK: - 私有方法

    private func fetchAndCacheBooking() -> AnyPublisher<Booking, DataError> {
        return service.fetchBooking()
            .mapError { DataError.networkError($0) }
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] booking -> AnyPublisher<Booking, DataError> in
                guard let self = self else {
                    return Fail(error: DataError.noDataAvailable).eraseToAnyPublisher()
                }
                
                // 写入缓存数据
                do {
                    try self.saveBookingToRealm(booking)
                    
                    return Just(booking)
                        .setFailureType(to: DataError.self)
                        .eraseToAnyPublisher()
                } catch {
                    debugLog("保存booking到缓存时出错: \(error.localizedDescription)")
                    return Fail(error: DataError.realmError(error)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func getCachedBooking() -> Booking? {
        return realm.objects(Booking.self)
                .sorted(byKeyPath: "expiryTime", ascending: true)
                .first
    }
    
    private func isCacheValid(_ booking: Booking) -> Bool {
        
        if !booking.isValid {
            debugLog("booking已过期")
            return false
        }
        
        // 检查是否缓存是否有效
        let cacheAge = Date().timeIntervalSince(booking.fetchTimestamp)
        let isValid = cacheAge < cacheExpiryTime
        
        if !isValid {
            debugLog("缓存过旧: \(cacheAge)秒，最大允许\(cacheExpiryTime)秒")
        } else {
            debugLog("缓存有效: \(cacheAge)秒")
        }
        
        return isValid
    }
    
    private func saveBookingToRealm(_ booking: Booking) throws {
        do {
            try realm.write {
                realm.add(booking, update: .modified)
            }
        } catch {
            throw error
        }
    }
}
