//
//  FPSLabel.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/26.
//

import UIKit

class FPSLabel: UILabel {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: TimeInterval = 0
    private var frameCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }

    private func setup() {
        font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        textColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        textAlignment = .center
        layer.cornerRadius = 6
        clipsToBounds = true

        displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        if delta >= 1.0 {
            let fps = Double(frameCount) / delta
            text = String(format: "FPS: %.0f", round(fps))
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }

    deinit {
        displayLink?.invalidate()
    }
}
