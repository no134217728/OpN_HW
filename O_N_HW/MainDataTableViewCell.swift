//
//  MainCellTableViewCell.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import UIKit
import Combine

class MainDataTableViewCell: UITableViewCell {
    @IBOutlet weak var matchIDLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var teamANameLabel: UILabel!
    @IBOutlet weak var oddsALabel: UILabel!
    @IBOutlet weak var teamBNameLabel: UILabel!
    @IBOutlet weak var oddsBLabel: UILabel!
    
    private var viewModel: MainDataTableViewCellModel? {
        didSet {
            bindViewModel()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func configure(with model: MainDataTableViewCellModel) {
        self.viewModel = model
        
        matchIDLabel.text = "\(model.matchID)"
        startTimeLabel.text = "\(model.startTime)"
        teamANameLabel.text = model.teamA
        oddsALabel.text = "\(model.teamAOdds)"
        teamBNameLabel.text = model.teamB
        oddsBLabel.text = "\(model.teamBOdds)"
    }
    
    func bindViewModel() {
        cancellables.removeAll()
        
        guard let vm = viewModel else { return }
        
        vm.$teamAOdds
            .map({ "\($0)" })
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: oddsALabel)
            .store(in: &cancellables)
        
        vm.$teamBOdds
            .map({ "\($0)" })
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: oddsBLabel)
            .store(in: &cancellables)
    }
}

class MainDataTableViewCellModel: ObservableObject {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: Date
    
    @Published private(set) var teamAOdds: Decimal
    @Published private(set) var teamBOdds: Decimal
    
    init(match: Match, odds: Odds) {
        matchID = match.matchID
        teamA = match.teamA
        teamB = match.teamB
        startTime = match.startTime
        teamAOdds = odds.teamAOdds
        teamBOdds = odds.teamBOdds
    }
    
    func updateOdds(teamAOdds: Decimal, teamBOdds: Decimal) {
        self.teamAOdds = teamAOdds
        self.teamBOdds = teamBOdds
    }
}
