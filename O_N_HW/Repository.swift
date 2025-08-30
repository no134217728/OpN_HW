//
//  Repository.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/28.
//

import Foundation

class Repository {
    var apiService: Service
    
    init(apiService: Service) {
        self.apiService = apiService
    }
    
    func getMatches() async -> [Match]? {
        let matches = await apiService.fetchData(source: "matches", model: [Match].self)
        
        return matches
    }
    
    func getDefaultOdds() async -> [Odds]? {
        let odds = await apiService.fetchData(source: "odds", model: [Odds].self)
        
        return odds
    }
    
    deinit {
        print("Repository deinit")
    }
}


