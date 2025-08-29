//
//  WebSocketMock.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import UIKit

class WebSocketMock {
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
