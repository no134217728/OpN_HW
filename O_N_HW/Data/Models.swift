//
//  Models.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import Foundation

struct Match: Decodable {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: Date
}

struct Odds: Decodable {
    let matchID: Int
    let teamAOdds: Decimal
    let teamBOdds: Decimal
}

struct MainData {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: Date
    var teamAOdds: Decimal
    var teamBOdds: Decimal
    
    init(match: Match, odds: Odds) {
        matchID = match.matchID
        teamA = match.teamA
        teamB = match.teamB
        startTime = match.startTime
        teamAOdds = odds.teamAOdds
        teamBOdds = odds.teamBOdds
    }
}
