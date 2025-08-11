//
//  ContentView.swift
//  mobileTest
//
//  Created by walllceleung on 9/8/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookingViewModel()
    @State private var isRefreshing = false
    @State private var didLoad = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            List {
                if let booking = viewModel.booking {
                    Section(header: Text("Booking Information")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ship Reference: \(booking.shipReference)")
                                .font(.headline)
                            Text("Duration: \(booking.duration)")
                            Text("Expires: \(formatExpiryTime(booking.expiryTime))")
                            if !booking.isValid {
                                Text("Booking is expired")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("Segments")) {
                        ForEach(booking.segments, id: \.id) { segment in
                            if let originAndDestination = segment.originAndDestinationPair,
                               let origin = originAndDestination.origin,
                               let destination = originAndDestination.destination {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Segment \(segment.id)")
                                        .font(.headline)
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(origin.code)
                                                .font(.title2)
                                                .bold()
                                            Text(origin.displayName)
                                                .font(.subheadline)
                                            Text(originAndDestination.originCity)
                                                .font(.caption)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .imageScale(.large)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text(destination.code)
                                                .font(.title2)
                                                .bold()
                                            Text(destination.displayName)
                                                .font(.subheadline)
                                            Text(originAndDestination.destinationCity)
                                                .font(.caption)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .padding()
                    }
                } else if viewModel.hasError {
                    Section {
                        VStack {
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(viewModel.errorMessage ?? "Unknown error")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            
                            Button("Try Again") {
                                viewModel.loadBookingData()
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
            .navigationTitle("Booking Details")
            .refreshable {
                await refreshData()
            }
            .onAppear {
                
                if !didLoad {
                    Task {
                        await refreshData()
                        didLoad = true
                    }
                }
                else {
                    if !viewModel.isLoading {
                        viewModel.loadBookingData()
                    }
                }
                
            }
            .onChange(of: scenePhase) { oldValue, newValue in
                switch newValue {
                    
                case .active:
                    if didLoad && !viewModel.isLoading {
                        viewModel.loadBookingData()
                    }
                    
                case .inactive:
                    debugLog("App Inactive")
                    
                case .background:
                    debugLog("APP in Background")
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        viewModel.refreshData()
        isRefreshing = false
    }
    
    private func formatExpiryTime(_ expiryTimeString: String) -> String {
        guard let expiryTimeInterval = TimeInterval(expiryTimeString) else {
            return "Unknown"
        }
        let expiryDate = Date(timeIntervalSince1970: expiryTimeInterval)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: expiryDate)
    }
}

#Preview {
    ContentView()
}
