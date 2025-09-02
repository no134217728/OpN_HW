//
//  ViewController.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var mainDataTableView: UITableView!
    
    var viewModel: ViewModelType!
    
    private let queue = DispatchQueue.init(label: "UpdateCell", qos: .background, attributes: .concurrent)
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainDataTableView.delegate = self
        mainDataTableView.dataSource = self
        mainDataTableView.estimatedRowHeight = 90
        mainDataTableView.rowHeight = UITableView.automaticDimension
        
        bindViewModel()
        viewModel.input.waitForAllData()
        
        Task {
            async let _ = viewModel.input.getMatches()
            async let _ = viewModel.input.getDefaultOdds()
        }
        
        viewModel.input.initMocketSocket()
    }
    
    private func bindViewModel() {
        viewModel.output.mainDataNotify
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                self.mainDataTableView.reloadData()
            }.store(in: &cancellables)
        
        viewModel.output.socketPushNotify
            .sink { [weak self] odds in
                self?.updateCell(odds: odds)
            }.store(in: &cancellables)
    }
    
    private func updateCell(odds: Odds) {
        queue.async {
            guard let cellIndex = OddsInfo.shared.matchIDandCellPosition[odds.matchID] else { return }
            let cellIndexPath = IndexPath(row: cellIndex, section: 0)
            
            DispatchQueue.main.async {
                guard let cell = self.mainDataTableView.cellForRow(at: cellIndexPath) as? MainDataTableViewCell else { return }
                
                cell.oddsALabel.text = "\(odds.teamAOdds)"
                cell.oddsBLabel.text = "\(odds.teamBOdds)"
            }
        }
    }
    
    deinit {
        print("ViewController deinit")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { OddsInfo.shared.oddsLists.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainDataTableViewCell
        
        let data = OddsInfo.shared.oddsLists[indexPath.row]
        cell.configure(with: data)
        OddsInfo.shared.matchIDandCellPosition[data.matchID] = indexPath.row
        
        return cell
    }
}
