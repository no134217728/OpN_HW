//
//  WebSocketMock.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import UIKit
import Combine

class WebSocketMock {
    var resultPublisher: AnyPublisher<Odds, Never> { result.eraseToAnyPublisher() }
    
    private let result = PassthroughSubject<Odds, Never>()
    
    func socketPush() {
        let mockSocketMin = OddsInfo.shared.mockSocketMin
        let mockSocketMax = OddsInfo.shared.mockSocketMax
        let minV = max(min(mockSocketMin, mockSocketMax), 4)
        let maxV = max(max(mockSocketMin, mockSocketMax), 10)
        
        let number = Int.random(in: minV...maxV)
        
        for _ in 0...number {
            let odds = generateRandomOdds()
            OddsInfo.shared.updateOdds(odds: odds)
            result.send(odds)
        }
    }
    
    func generateRandomOdds() -> Odds {
        let matchID = Int.random(in: 1001...1120)
        var oddsA = Decimal(Double.random(in: 1...3))
        var oddsB = Decimal(Double.random(in: 1...3))
        var roundedA = Decimal()
        var roundedB = Decimal()
        NSDecimalRound(&roundedA, &oddsA, 2, .plain)
        NSDecimalRound(&roundedB, &oddsB, 2, .plain)
        
        return Odds(matchID: matchID,
                    teamAOdds: roundedA,
                    teamBOdds: roundedB)
    }
}
