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
