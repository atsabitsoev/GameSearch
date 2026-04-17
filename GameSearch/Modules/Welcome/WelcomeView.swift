import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    let onSelect: (WelcomeDestination) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            background
            VStack(spacing: 20) {
                header
                options
                Spacer(minLength: 16)
                bottomHint
                continueButton
            }
            .padding([.horizontal, .bottom], 16)
            .padding(.top, 32)
        }
    }
}

private extension WelcomeView {
    var background: some View {
        ZStack(alignment: .bottom) {
            EAColor.background
            LinearGradient(
                colors: [EAColor.background, EAColor.secondaryBackground.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            Circle()
                .fill(EAColor.dotaColor.opacity(0.16))
                .frame(width: 290, height: 290)
                .blur(radius: 36)
                .offset(x: -130, y: -250)
            Circle()
                .fill(EAColor.csColor.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 38)
                .offset(x: 130, y: -210)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [EAColor.background.opacity(0), EAColor.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 180)
        }
        .ignoresSafeArea()
    }

    var header: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(EAColor.secondaryBackground)
                .frame(width: 52, height: 52)
                .overlay(
                    Text("👋")
                        .font(.system(size: 26))
                )
            (
                Text("Что тебе ")
                    .foregroundStyle(EAColor.textPrimary)
                +
                Text("интересно?")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [EAColor.purpleAccent, EAColor.info2],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .font(EAFont.title)

            Text("Выбери, что для тебя сейчас важнее — мы покажем лучшее")
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textSecondary)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
        }
    }

    var options: some View {
        VStack(spacing: 12) {
            optionCard(for: .clubs)
            optionCard(for: .news)
            optionCard(for: .tournaments)
        }
    }

    var bottomHint: some View {
        Text("Выбор не навсегда - вкладки можно менять внизу.")
            .font(EAFont.info)
            .foregroundStyle(EAColor.textSecondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    var continueButton: some View {
        Button(action: onContinue) {
            Text("Начать")
                .font(EAFont.infoTitle)
                .foregroundStyle(EAColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [EAColor.purpleAccent.opacity(0.95), EAColor.info2.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func optionCard(for destination: WelcomeDestination) -> some View {
        Button {
            onSelect(destination)
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(destination.badgeColor.opacity(0.34))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: destination.iconName)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.title)
                        .font(EAFont.infoTitle)
                        .foregroundStyle(EAColor.textPrimary)
                    Text(destination.subtitle)
                        .font(EAFont.info)
                        .foregroundStyle(EAColor.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(EAColor.textPrimary.opacity(0.9))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(destination.backgroundGradient)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(destination.borderColor, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

