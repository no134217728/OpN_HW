//
//  ConfigViewController.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import Foundation
import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet weak var minText: UITextField!
    @IBOutlet weak var maxText: UITextField!
    
    @IBAction func lowConfig() {
        minText.text = "\(4)"
        maxText.text = "\(10)"
    }
    
    @IBAction func HighConfig() {
        minText.text = "\(90)"
        maxText.text = "\(100)"
    }
    
    @IBAction func go() {
        let minV = Int(minText.text ?? "4") ?? 4
        let maxV = Int(maxText.text ?? "10") ?? 10
        
        Misc.shared.mockSocketMin = minV
        Misc.shared.mockSocketMax = maxV
        
        guard let navC = self.navigationController else {
            print("Missing navigationController.")
            return
        }
        
        let coordinator = OddsCoordinator(service: LocalAPIService(),
                                          navigationController: navC)
        coordinator.startTheOddsPage()
    }
}
