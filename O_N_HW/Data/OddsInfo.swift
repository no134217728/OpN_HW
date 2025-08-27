//
//  OddsInfo.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import Foundation

class OddsInfo {
    static let shared = OddsInfo()
    
    var mockSocketMin: Int = 4
    var mockSocketMax: Int = 10
    
    private let oddsQueue = DispatchQueue(label: "odds", qos: .background, attributes: .concurrent)
    
    private var _mainData: [MainData] = []
    private var _cellIndexAndMainData: [Int: MainData] = [:]
    private var _matchIDAndCellIndex: [Int: Int] = [:]
    
    var mainData: [MainData] {
        get {
            return oddsQueue.sync { _mainData }
        } set {
            oddsQueue.async(flags: .barrier) { self._mainData = newValue }
        }
    }
    
    var cellIndexAndMainData: [Int: MainData] {
        get {
            return oddsQueue.sync { _cellIndexAndMainData }
        }
        set {
            oddsQueue.async(flags: .barrier) { self._cellIndexAndMainData = newValue }
        }
    }
    
    var matchIDAndCellIndex: [Int: Int] {
        get {
            return oddsQueue.sync { _matchIDAndCellIndex }
        }
        set {
            oddsQueue.async(flags: .barrier) { self._matchIDAndCellIndex = newValue }
        }
    }
    
    func updateOdds(odds: Odds) {
        guard let index = mainData.firstIndex(where: { $0.matchID == odds.matchID }) else { return }
        
        mainData[index].teamAOdds = odds.teamAOdds
        mainData[index].teamBOdds = odds.teamBOdds
    }
}
