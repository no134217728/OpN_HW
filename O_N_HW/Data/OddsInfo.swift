//
//  OddsInfo.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import Foundation

class OddsInfo {
    static let shared = OddsInfo()
    
    private let oddsQueue = DispatchQueue(label: "odds", qos: .background, attributes: .concurrent)
    
    private var _mainData: [MainDataObserve] = []
    
    var mainData: [MainDataObserve] {
        get {
            return oddsQueue.sync { _mainData }
        } set {
            oddsQueue.async(flags: .barrier) { self._mainData = newValue }
        }
    }
    
    func updateOdds(odds: Odds) {
        guard let index = mainData.firstIndex(where: { $0.matchID == odds.matchID }) else { return }
        
        mainData[index].teamAOdds = odds.teamAOdds
        mainData[index].teamBOdds = odds.teamBOdds
    }
}
