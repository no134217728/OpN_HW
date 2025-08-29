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
    func getMatches() async
    func getDefaultOdds() async
    func initMocketSocket()
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
    
    private let repository: Repository
    
    private let matchesSubject = PassthroughSubject<[Match], Never>()
    private let oddsSubject = PassthroughSubject<[Odds], Never>()
    private let mainDataSubject = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func waitForAllData() {
        matchesSubject
            .combineLatest(oddsSubject)
            .map { matches, odds -> [MainDataObserve] in
                return matches.compactMap { match in
                    guard let odds = odds.first(where: { $0.matchID == match.matchID }) else {
                        return nil
                    }
                    
                    return MainDataObserve(match: match, odds: odds)
                }
            }.sink { [unowned self] mainData in
                OddsInfo.shared.mainData = mainData
                
                self.mainDataSubject.send(())
            }.store(in: &cancellables)
    }
    
    func getMatches() async {
        guard let matches = await repository.getMatches() else {
            print("Matches is empty.")
            return
        }
        
        let sortedMatches = matches.sorted { $0.startTime < $1.startTime }
        matchesSubject.send(sortedMatches)
    }
    
    func getDefaultOdds() async {
        guard let odds = await repository.getDefaultOdds() else {
            print("Odds is empty.")
            return
        }
        
        oddsSubject.send(odds)
    }
    
    func initMocketSocket() {
        let mockSocket = WebSocketMock()
        
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                print("Timer: \(date)")
                mockSocket.socketPush()
            }.store(in: &cancellables)
    }
}
