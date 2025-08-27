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
    
    private let mockSocket = WebSocketMock()
    private let viewModel = ViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    let queue = DispatchQueue.init(label: "UpdateCell", qos: .background, attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainDataTableView.delegate = self
        mainDataTableView.dataSource = self
        mainDataTableView.estimatedRowHeight = 90
        mainDataTableView.rowHeight = UITableView.automaticDimension
        
        bindViewModel()
        viewModel.input.waitForAllData()
        viewModel.input.getMatches()
        viewModel.input.getDefaultOdds()
        
        let publisher = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .map { _ in
                Date.now
            }
        
        publisher
            .sink { [unowned self] date in
                print("Timer: \(date)")
                self.mockSocket.socketPush()
            }.store(in: &cancellables)
    }
    
    private func bindViewModel() {
        viewModel.mainData.sink { [unowned self] in
            self.mainDataTableView.reloadData()
        }.store(in: &cancellables)
        
        mockSocket.resultPublisher.sink { [weak self] odds in
            self?.updateCell(odds: odds)
        }.store(in: &cancellables)
    }
    
    func updateCell(odds: Odds) {
        queue.async {
            guard let cellIndex = OddsInfo.shared.matchIDAndCellIndex[odds.matchID] else { return }
            let cellIndexPath = IndexPath(row: cellIndex, section: 0)
            
            DispatchQueue.main.async {
                guard let cell = self.mainDataTableView.cellForRow(at: cellIndexPath) as? MainDataTableViewCell else { return }
                
                cell.oddsALabel.text = "\(odds.teamAOdds)"
                cell.oddsBLabel.text = "\(odds.teamBOdds)"
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { OddsInfo.shared.mainData.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainDataTableViewCell
        
        let data = OddsInfo.shared.mainData[indexPath.row]
        cell.configureCell(data: data)
        
        OddsInfo.shared.matchIDAndCellIndex[data.matchID] = indexPath.row
        
        return cell
    }
}
