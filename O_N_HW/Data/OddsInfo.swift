//
//  OddsInfo.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import Foundation

actor OddsInfoActor {
    var mainData: [MainDataModel] = []

    func setMainData(data: [MainDataModel]) {
        mainData = data
    }
    
    func updateOdds(odds: Odds) {
        guard let index = mainData.firstIndex(where: { $0.matchID == odds.matchID }) else { return }
        
        mainData[index].updateOdds(teamAOdds: odds.teamAOdds, teamBOdds: odds.teamBOdds)
    }
}

class OddsInfo {
    static let shared = OddsInfo()
    
    private let oddsQueue = DispatchQueue(label: "odds", qos: .background, attributes: .concurrent)
    
    private var _oddsLists: [MainDataModel] = []
    private var _matchIDandCellPosition: [Int: Int] = [:]
    
    var oddsLists: [MainDataModel] {
        get {
            return oddsQueue.sync { _oddsLists }
        }
        set {
            oddsQueue.async(flags: .barrier) { self._oddsLists = newValue }
        }
    }
    
    var matchIDandCellPosition: [Int: Int] {
        get {
            return oddsQueue.sync { _matchIDandCellPosition }
        }
        set {
            oddsQueue.async(flags: .barrier) { self._matchIDandCellPosition = newValue }
        }
    }
    
    func updateOdds(odds: Odds) {
        guard let index = oddsLists.firstIndex(where: { $0.matchID == odds.matchID }) else { return }
        
        oddsLists[index].teamAOdds = odds.teamAOdds
        oddsLists[index].teamBOdds = odds.teamBOdds
    }
}
