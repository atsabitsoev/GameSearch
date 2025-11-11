//
//  HapticManager.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 11.11.2025.
//

import CoreHaptics

class HapticManager {
    private var engine: CHHapticEngine?
    
    init() {
        engine = try? CHHapticEngine()
        try? engine?.start()
    }
    
    
    func wavePulse(power: Float) {
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [],
            relativeTime: 0,
            duration: 1.0
        )
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 0.1 * power),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.3 * power)
            ],
            relativeTime: 0
        )
        
        let pattern = try? CHHapticPattern(events: [event],
                                           parameterCurves: [intensityCurve])
        let player = try? engine?.makePlayer(with: pattern!)
        try? player?.start(atTime: 0)
    }
    
    func collapsePulse() {
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [],
            relativeTime: 0,
            duration: 1.0
        )
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 1.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.5)
            ],
            relativeTime: 0
        )
        
        let pattern = try? CHHapticPattern(events: [event],
                                           parameterCurves: [intensityCurve])
        let player = try? engine?.makePlayer(with: pattern!)
        try? player?.start(atTime: 0)
    }
}
