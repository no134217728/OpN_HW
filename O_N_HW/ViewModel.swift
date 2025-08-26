//
//  ViewModel.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import Foundation
import Combine

protocol ViewModelType {
    var input: ViewModelInput { get }
    var output: ViewModelOutput { get }
}

protocol ViewModelInput {
    func waitForAllData()
    func getMatches()
    func getDefaultOdds()
}

protocol ViewModelOutput {
    var matches: AnyPublisher<[Match], Never> { get }
    var odds: AnyPublisher<[Odds], Never> { get }
    var mainData: AnyPublisher<Void, Never> { get }
}

class ViewModel: ViewModelType, ViewModelInput, ViewModelOutput {
    var input: ViewModelInput { self }
    var output: ViewModelOutput { self }
    
    var matches: AnyPublisher<[Match], Never> { matchesSubject.eraseToAnyPublisher() }
    var odds: AnyPublisher<[Odds], Never> { oddsSubject.eraseToAnyPublisher() }
    var mainData: AnyPublisher<Void, Never> { mainDataSubject.eraseToAnyPublisher() }
    
    private let matchesSubject = PassthroughSubject<[Match], Never>()
    private let oddsSubject = PassthroughSubject<[Odds], Never>()
    private let mainDataSubject = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func waitForAllData() {
        matchesSubject
            .combineLatest(oddsSubject)
            .map { matches, odds -> [MainData] in
                return matches.compactMap { match in
                    guard let odds = odds.first(where: { $0.matchID == match.matchID }) else {
                        return nil
                    }
                    
                    return MainData(match: match, odds: odds)
                }
            }.sink { mainData in
                OddsInfo.shared.oddsLists = mainData
                self.mainDataSubject.send(())
            }.store(in: &cancellables)
    }
    
    func getMatches() {
        if let path = Bundle.main.path(forResource: "matches", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let matches = try decoder.decode([Match].self, from: data)
                let sortedMatches = matches.sorted { $0.startTime < $1.startTime }
                
                matchesSubject.send(sortedMatches)
            } catch {
                print("file error: matches, error: \(error)")
            }
        }
    }
    
    func getDefaultOdds() {
        if let path = Bundle.main.path(forResource: "odds", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let paramsModel = try JSONDecoder().decode([Odds].self, from: data)
                oddsSubject.send(paramsModel)
            } catch {
                print("file error: odds, error: \(error)")
            }
        }
    }
}
