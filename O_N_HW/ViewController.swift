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
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.output.mainCellModels.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainDataTableViewCell
        
        let data = viewModel.output.mainCellModels[indexPath.row]
        cell.configure(with: data)
        
        return cell
    }
}
