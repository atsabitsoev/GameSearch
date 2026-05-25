//
//  TournamentsEmptyStateView.swift
//  GameSearch
//
//  Universal empty / error placeholder used by every list and details
//  screen inside the Tournaments module. Replaces the original
//  `TournamentsPlaceholderView` for in-list scenarios while the legacy
//  placeholder is still available for the wishlist CTA flow until the
//  Phase 1 DoD removes it entirely.
//

import SwiftUI

struct TournamentsEmptyStateView: View {

    // MARK: - Kind

    enum Kind: Hashable {
        case emptyRunning
        case emptyUpcoming
        case emptyPast
        case errorNoInternet
        case errorTemporary

        var emoji: String {
            switch self {
            case .emptyRunning, .emptyUpcoming, .emptyPast: "🏆"
            case .errorNoInternet: "📡"
            case .errorTemporary: "⚠️"
            }
        }

        var title: String {
            switch self {
            case .emptyRunning: TournamentsStrings.emptyRunningTitle
            case .emptyUpcoming: TournamentsStrings.emptyUpcomingTitle
            case .emptyPast: TournamentsStrings.emptyPastTitle
            case .errorNoInternet: TournamentsStrings.errorNoInternetTitle
            case .errorTemporary: TournamentsStrings.errorTemporaryTitle
            }
        }

        var subtitle: String {
            switch self {
            case .emptyRunning: TournamentsStrings.emptyRunningSubtitle
            case .emptyUpcoming: TournamentsStrings.emptyUpcomingSubtitle
            case .emptyPast: TournamentsStrings.emptyPastSubtitle
            case .errorNoInternet: TournamentsStrings.errorNoInternetSubtitle
            case .errorTemporary: TournamentsStrings.errorTemporarySubtitle
            }
        }

        var showsRetry: Bool {
            switch self {
            case .errorNoInternet, .errorTemporary: true
            case .emptyRunning, .emptyUpcoming, .emptyPast: false
            }
        }
    }

    // MARK: - Props

    let kind: Kind
    let onRetry: (() -> Void)?

    init(kind: Kind, onRetry: (() -> Void)? = nil) {
        self.kind = kind
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(EAColor.secondaryBackground)
                .frame(width: 64, height: 64)
                .overlay(
                    Text(kind.emoji)
                        .font(.system(size: 30))
                )

            Text(kind.title)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(kind.subtitle)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if kind.showsRetry {
                retryButton
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

private extension TournamentsEmptyStateView {
    var retryButton: some View {
        Button {
            onRetry?()
        } label: {
            Text(TournamentsStrings.errorRetryButton)
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textPrimary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    EAColor.purpleAccent.opacity(0.95),
                                    EAColor.purpleAccent.opacity(0.45)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(TournamentsStrings.errorRetryButton))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            TournamentsEmptyStateView(kind: .emptyRunning)
            TournamentsEmptyStateView(kind: .errorNoInternet, onRetry: {})
            TournamentsEmptyStateView(kind: .errorTemporary, onRetry: {})
        }
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
