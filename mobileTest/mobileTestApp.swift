//
//  mobileTestApp.swift
//  mobileTest
//
//  Created by walllceleung on 8/8/2025.
//

import SwiftUI
import RealmSwift

@main
struct mobileTestApp: App {
    init() {
        configureRealm()
        
        debugLog("Realm文件位置: \(Realm.Configuration.defaultConfiguration.fileURL?.path ?? "未知")")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // 在这进行数据迁移
                }
            },
            deleteRealmIfMigrationNeeded: false, 
            objectTypes: [Booking.self, Segment.self, Location.self, OriginAndDestinationPair.self]
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        // 确保 BookingDataManager 在主线程上初始化
        _ = BookingDataManager.shared
    }
}
