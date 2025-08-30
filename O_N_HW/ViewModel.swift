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
    var mainDataNotify: AnyPublisher<Void, Never> { get }
    var mainCellModels: [MainDataTableViewCellModel] { get }
}

class ViewModel: ViewModelType, ViewModelInput, ViewModelOutput {
    var input: ViewModelInput { self }
    var output: ViewModelOutput { self }
    
    var matches: AnyPublisher<[Match], Never> { matchesSubject.eraseToAnyPublisher() }
    var odds: AnyPublisher<[Odds], Never> { oddsSubject.eraseToAnyPublisher() }
    var mainDataNotify: AnyPublisher<Void, Never> { mainDataSubject.eraseToAnyPublisher() }
    private(set) var mainCellModels: [MainDataTableViewCellModel] = []
    
    private let repository: Repository
    private let oddsInfo: OddsInfoActor = .init()
    
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
            .map { matches, odds -> [MainDataTableViewCellModel] in
                return matches.compactMap { match in
                    guard let odds = odds.first(where: { $0.matchID == match.matchID }) else {
                        return nil
                    }
                    
                    return MainDataTableViewCellModel(match: match, odds: odds)
                }
            }.sink { [unowned self] mainData in
                Task {
                    await self.oddsInfo.setMainData(data: mainData)
                }
                
                self.mainCellModels = mainData
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
        let mockSocketMin = Misc.shared.mockSocketMin
        let mockSocketMax = Misc.shared.mockSocketMax
        let minV = max(min(mockSocketMin, mockSocketMax), 4)
        let maxV = max(max(mockSocketMin, mockSocketMax), 10)
        
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                guard let self = self else { return }
                
                print("Timer: \(date)")
                
                let number = Int.random(in: minV...maxV)
                let interval = 1.0 / Double(max(1, number))

                for i in 0...number {
                    let odds = mockSocket.generateRandomOdds()
                    DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak self] in
                        guard let self = self else { return }
                        
                        Task {
                            await self.oddsInfo.updateOdds(odds: odds)
                        }
                    }
                }
            }.store(in: &cancellables)
    }
    
    deinit {
        print("ViewModel deinit")
    }
}
