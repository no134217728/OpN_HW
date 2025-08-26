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
    func getMatches()
    func getDefaultOdds()
    func preLoadIfExist()
}

protocol ViewModelOutput {
    var matches: AnyPublisher<[Match], Never> { get }
    var odds: AnyPublisher<[Odds], Never> { get }
    var mainData: AnyPublisher<[MainData], Never> { get }
}

class ViewModel: ViewModelType, ViewModelInput, ViewModelOutput {
    var input: ViewModelInput { self }
    var output: ViewModelOutput { self }
    
    var matches: AnyPublisher<[Match], Never> { matchesSubject.eraseToAnyPublisher() }
    var odds: AnyPublisher<[Odds], Never> { oddsSubject.eraseToAnyPublisher() }
    var mainData: AnyPublisher<[MainData], Never> { mainDataSubject.eraseToAnyPublisher() }
    
    private let matchesSubject = PassthroughSubject<[Match], Never>()
    private let oddsSubject = PassthroughSubject<[Odds], Never>()
    private let mainDataSubject = PassthroughSubject<[MainData], Never>()
    
    func getMatches() {
        if let path = Bundle.main.path(forResource: "matches", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let paramsModel = try JSONDecoder().decode([Match].self, from: data)
                matchesSubject.send(paramsModel)
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
    
    func preLoadIfExist() {
        
        
    }
}
