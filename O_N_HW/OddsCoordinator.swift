//
//  OddsCoordinator.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/28.
//

import Foundation
import UIKit

class OddsCoordinator {
    private let navigationController: UINavigationController
    private let repository: Repository
    
    init(service: Service, navigationController: UINavigationController) {
        self.repository = Repository(apiService: service)
        self.navigationController = navigationController
    }
    
    func startTheOddsPage() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainVC") as? ViewController else { return }
        
        let vm = ViewModel(repository: repository)
        vc.viewModel = vm
        navigationController.pushViewController(vc, animated: true)
    }
}
