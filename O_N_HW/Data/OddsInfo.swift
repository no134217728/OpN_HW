//
//  OddsInfo.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import Foundation

actor OddsInfoActor {
    var mainData: [MainDataTableViewCellModel] = []

    func setMainData(data: [MainDataTableViewCellModel]) {
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
    
    private var _mainData: [MainDataTableViewCellModel] = []
    
    var mainData: [MainDataTableViewCellModel] {
        get {
            return oddsQueue.sync { _mainData }
        } set {
            oddsQueue.async(flags: .barrier) { self._mainData = newValue }
        }
    }
    
    func updateOdds(odds: Odds) {
        guard let index = mainData.firstIndex(where: { $0.matchID == odds.matchID }) else { return }
        
        mainData[index].updateOdds(teamAOdds: odds.teamAOdds, teamBOdds: odds.teamBOdds)
    }
}
