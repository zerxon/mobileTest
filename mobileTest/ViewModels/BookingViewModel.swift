//
//  BookingViewModel.swift
//  mobileTest
//
//  Created by walllceleung on 9/8/2025.
//

import Foundation
import Combine
import SwiftUI

class BookingViewModel: ObservableObject {
    
    @Published var booking: Booking?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    private let dataManager: BookingDataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: BookingDataManager = BookingDataManager.shared) {
        self.dataManager = dataManager
    }
    
    func loadBookingData() {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        dataManager.getBookingData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.description
                    self.hasError = true
                    debugLog("加载booking数据时出错: \(error.description)")
                }
            } receiveValue: { [weak self] booking in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.booking = booking
                    
                    // 调用dataprovider接口，在console中打印出对应data数据。
                    debugLog(booking)
                }
            }
            .store(in: &cancellables)
    }
   
    func refreshData() {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        dataManager.refreshBookingData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.description
                    self.hasError = true
                    debugLog("刷新booking数据时出错: \(error.description)")
                }
            } receiveValue: { [weak self] booking in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.booking = booking
                    
                    // 调用dataprovider接口，在console中打印出对应data数据。
                    debugLog(booking)
                }
            }
            .store(in: &cancellables)

    }
}
