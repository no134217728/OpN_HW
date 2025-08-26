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
    
    func configureCell(data: MainData) {
        matchIDLabel.text = "\(data.matchID)"
        startTimeLabel.text = "\(data.startTime)"
        teamANameLabel.text = data.teamA
        oddsALabel.text = "\(data.teamAOdds)"
        teamBNameLabel.text = data.teamB
        oddsBLabel.text = "\(data.teamBOdds)"
    }
}
