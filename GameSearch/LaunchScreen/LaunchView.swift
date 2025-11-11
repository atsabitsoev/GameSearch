//
//  LaunchView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 11.11.2025.
//

import SwiftUI

struct LaunchView: View {
    @Binding var showMainView: Bool
    @State private var phase: LaunchPhaseAnimation = .start
    
    let haptics = HapticManager()
    
    
    var body: some View {
        ZStack {
            EAColor.background
            
            ForEach(0..<5) { index in
                Image("launchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: Constants.launchIconWidht, height: Constants.launchIconHeight)
                    .offset(y: offset(for: index))
            }
        }
        .ignoresSafeArea()
        .task {
            await startAnimation()
        }
    }
}

private extension LaunchView {
    func offset(for index: Int) -> CGFloat {
        let offset = Constants.launchIconHeight + Constants.launchIconPadding
        switch phase {
        case .start, .collapse:
            return 0
        case .firstRows:
            return [ -offset, -offset, 0, offset, offset][index]
        case .secondRows:
            return [ -offset*2, -offset, 0, offset, offset*2 ][index]
        }
    }
    
    @MainActor
    func startAnimation() async {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        
        try? await Task.sleep(nanoseconds: Constants.AnimationTiming.startAnimatingDelay)
        
        await animatePhase(to: .firstRows)
        
        await animatePhase(to: .secondRows)
        
        await animatePhase(to: .collapse, damping: Constants.AnimationTiming.collapseDamping)
        
        withAnimation(.easeOut(duration: 0.5)) {
            showMainView = true
        }
    }
    
    @MainActor
    private func animatePhase(to animationPhase: LaunchPhaseAnimation, damping: Double? = nil) async {
        let animation: Animation = if let damping {
            .spring(response: 1, dampingFraction: damping)
        } else {
            .easeInOut(duration: Constants.AnimationTiming.phaseDuration)
        }
        
        withAnimation(animation) {
            phase = animationPhase
            hapticPhase(to: animationPhase)
        }
        
        try? await Task.sleep(nanoseconds: Constants.AnimationTiming.phaseDelay)
    }
    
    private func hapticPhase(to animationPhase: LaunchPhaseAnimation) {
        switch animationPhase {
        case .firstRows:
            haptics.wavePulse(power: 1)
        case .secondRows:
            haptics.wavePulse(power: 2)
        case .collapse:
            haptics.collapsePulse()
        default: break
        }
    }
}

private enum Constants {
    static let launchIconWidht: CGFloat = 200
    static let launchIconHeight: CGFloat = 60
    static let launchIconPadding: CGFloat = 20
    
    enum AnimationTiming {
        static let startAnimatingDelay: UInt64 = 500_000_000
        static let phaseDelay: UInt64 = 1_200_000_000
        static let phaseDuration: Double = 1.0
        static let collapseDamping: Double = 0.8
    }
}

private enum LaunchPhaseAnimation {
    case start
    case firstRows
    case secondRows
    case collapse
}
