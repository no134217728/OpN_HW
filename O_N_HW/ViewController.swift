//
//  ViewController.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private let mockSocket = WebSocketMock()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        let publisher = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .map { _ in
                Date.now
            }
        
        publisher
            .sink { date in
                self.mockSocket.socketPush()
                print("================ \(date)")
            }.store(in: &cancellables)
    }
    
    private func bindViewModel() {
        mockSocket.resultPublisher.sink { odds in
            print("\(odds)")
        }.store(in: &cancellables)
    }
}

