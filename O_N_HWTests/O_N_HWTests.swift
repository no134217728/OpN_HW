//
//  O_N_HWTests.swift
//  O_N_HWTests
//
//  Created by 黃紋吸蜜 on 2025/8/29.
//

import XCTest
import Combine

final class O_N_HWTests: XCTestCase {
    func testMatchDataSorted() async {
        let repository = Repository(apiService: LocalAPIService())
        let viewModel: ViewModelType = ViewModel(repository: repository)
        
        let expectation = XCTestExpectation(description: "Match publisher emits data")
        
        var receivedMatches: [Match] = []
        let cancellable = viewModel.output.matches
            .sink { matches in
                receivedMatches = matches
                expectation.fulfill()
            }
        
        await viewModel.input.getMatches()
        await fulfillment(of: [expectation], timeout: 1)
        
        for i in 0..<(receivedMatches.count - 1) {
            XCTAssertLessThanOrEqual(receivedMatches[i].startTime, receivedMatches[i + 1].startTime)
        }
        
        cancellable.cancel()
    }
    
    func testOddsDataEmit() async {
        let repository = Repository(apiService: LocalAPIService())
        let viewModel = ViewModel(repository: repository)
        let expectation = XCTestExpectation(description: "Odds publisher emits data")
        var receivedOdds: [Odds]?
        
        let cancellable = viewModel.output.odds
            .sink { odds in
                receivedOdds = odds
                expectation.fulfill()
            }
        
        await viewModel.input.getDefaultOdds()
        await fulfillment(of: [expectation], timeout: 1)
        
        XCTAssertNotNil(receivedOdds)
        
        cancellable.cancel()
    }
    
    func testMainDataComplete() async {
        let repository = Repository(apiService: LocalAPIService())
        let viewModel = ViewModel(repository: repository)
        
        viewModel.input.waitForAllData()
        await viewModel.input.getMatches()
        await viewModel.input.getDefaultOdds()
        
        let expectation = XCTestExpectation(description: "Wait for mainCellModels to be set")
        
        let cancellable = viewModel.output.mainDataNotify
            .sink {
                XCTAssertFalse(viewModel.output.mainCellModels.isEmpty, "mainCellModels is set")
                expectation.fulfill()
            }
        
        cancellable.cancel()
    }
    
    func testMatchFetch() async {
        let repository = Repository(apiService: LocalAPIService())
        
        let matches = await repository.getMatches()
        XCTAssertNotNil(matches)
    }
    
    func testOddsFetch() async {
        let repository = Repository(apiService: LocalAPIService())
        
        let odds = await repository.getDefaultOdds()
        XCTAssertNotNil(odds)
    }
    
    func testAPIService() async {
        let service = LocalAPIService()
        
        let result = await service.fetchData(source: "matches", model: [Odds].self)
    }
}
