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

class MainDataObserve {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: Date
    
    var teamAOdds: Decimal {
        didSet {
            notifyObservers()
        }
    }
    
    var teamBOdds: Decimal {
        didSet {
            notifyObservers()
        }
    }
    
    private var observers: [(Decimal, Decimal) -> Void] = []
    
    init(match: Match, odds: Odds) {
        matchID = match.matchID
        teamA = match.teamA
        teamB = match.teamB
        startTime = match.startTime
        teamAOdds = odds.teamAOdds
        teamBOdds = odds.teamBOdds
    }
    
    func addObserver(_ observer: @escaping (Decimal, Decimal) -> Void) {
        observers.append(observer)
    }
    
    func clearObservers() {
        observers = []
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer(teamAOdds, teamBOdds)
        }
    }
}
