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
    
    private var model: MainDataObserve?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        model?.clearObservers()
        model = nil
    }
    
    func configure(with model: MainDataObserve) {
        self.model = model
        
        matchIDLabel.text = "\(model.matchID)"
        startTimeLabel.text = "\(model.startTime)"
        teamANameLabel.text = model.teamA
        oddsALabel.text = "\(model.teamAOdds)"
        teamBNameLabel.text = model.teamB
        oddsBLabel.text = "\(model.teamBOdds)"
        
        self.model?.addObserver { [weak self] teamAOdds, teamBOdds in
            DispatchQueue.main.async {
                self?.oddsALabel.text = "\(teamAOdds)"
                self?.oddsBLabel.text = "\(teamBOdds)"
            }
        }
    }
    
    deinit {
        print("MainDataTableViewCell deinit")
    }
}
