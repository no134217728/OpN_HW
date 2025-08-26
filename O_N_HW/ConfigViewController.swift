//
//  ConfigViewController.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet weak var minText: UITextField!
    @IBOutlet weak var maxText: UITextField!
    
    @IBAction func go() {
        let minV = Int(minText.text ?? "4") ?? 4
        let maxV = Int(maxText.text ?? "10") ?? 10
        
        OddsInfo.shared.mockSocketMin = minV
        OddsInfo.shared.mockSocketMax = maxV
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainVC")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
