//
//  mobileTestTests.swift
//  mobileTestTests
//
//  Created by walllceleung on 8/8/2025.
//

import Testing
@testable import mobileTest

struct mobileTestTests {

    @Test func example() async throws {
        let actualValue = 1
        let expectedValue = 3
        #expect(actualValue == expectedValue, "Values should be equal")
    }

}
