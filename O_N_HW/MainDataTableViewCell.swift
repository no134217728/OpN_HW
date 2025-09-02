//
//  MainCellTableViewCell.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import UIKit

class MainDataTableViewCell: UITableViewCell {
    @IBOutlet weak var matchIDLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var teamANameLabel: UILabel!
    @IBOutlet weak var oddsALabel: UILabel!
    @IBOutlet weak var teamBNameLabel: UILabel!
    @IBOutlet weak var oddsBLabel: UILabel!
    
    func configure(with model: MainDataModel) {
        matchIDLabel.text = "\(model.matchID)"
        startTimeLabel.text = "\(model.startTime)"
        teamANameLabel.text = model.teamA
        oddsALabel.text = "\(model.teamAOdds)"
        teamBNameLabel.text = model.teamB
        oddsBLabel.text = "\(model.teamBOdds)"
    }
    
    deinit {
        print("MainDataTableViewCell deinit")
    }
}

class MainDataModel {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: Date
    var teamAOdds: Decimal
    var teamBOdds: Decimal
    
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
    
    deinit {
        print("MainDataTableViewCellModel deinit")
    }
}
