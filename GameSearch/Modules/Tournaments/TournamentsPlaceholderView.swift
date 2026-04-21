import SwiftUI
import AnalyticsModule

//TODO: - Удалить при переходе на реальные турниры через Liquipedia API
struct TournamentsPlaceholderView: View {
    @State private var cs2Tournament: String?
    @State private var dota2Tournament: String?
    @State private var isLoadingTournaments = false
    @State private var showConfirmationToast = false
    private let tournamentsService: any TournamentsServiceProtocol

    init(tournamentsService: any TournamentsServiceProtocol = PandaScoreTournamentsService()) {
        self.tournamentsService = tournamentsService
    }

    var body: some View {
        ZStack {
            EAColor.background
                .ignoresSafeArea()
            content
        }
        .navigationTitle("Турниры")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(EAColor.background, for: .navigationBar)
        .overlay(alignment: .bottom) {
            if showConfirmationToast {
                confirmationToast
                    .padding([.horizontal, .bottom], 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showConfirmationToast)
        .task {
            await loadTopTournaments()
        }
    }
}

private extension TournamentsPlaceholderView {
    var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                hero
                gameCards
                hintBlock
                wantButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 20)
        }
        .background(backgroundDecor)
    }

    var hero: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(EAColor.secondaryBackground)
                .frame(width: 64, height: 64)
                .overlay(
                    Text("🏆")
                        .font(.system(size: 32))
                )
            Text("Скоро турниры")
                .font(EAFont.header)
                .foregroundStyle(EAColor.textPrimary)
            Text("Здесь будут профессиональные турниры, матчи и стримы, чтобы удобно следить за киберспортом")
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 16)
    }

    var gameCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Первые в списке:")
                .font(EAFont.infoTitleMedium)
                .foregroundStyle(EAColor.textSecondary)
            HStack(spacing: 12) {
                gameCard(title: "CS2", tournamentName: cs2Tournament, color: EAColor.csColor)
                gameCard(title: "Dota 2", tournamentName: dota2Tournament, color: EAColor.dotaColor)
            }
        }
    }

    func gameCard(title: String, tournamentName: String?, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(EAFont.infoTitle)
                .foregroundStyle(EAColor.textPrimary)
            tournamentNameText(tournamentName)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.18))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.55), lineWidth: 1)
        }
    }

    @ViewBuilder
    func tournamentNameText(_ tournamentName: String?) -> some View {
        if let tournamentName, !tournamentName.isEmpty {
            Text(tournamentName)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        } else if isLoadingTournaments {
            Text("Получаем турниры...")
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
        }
    }

    var hintBlock: some View {
        HStack(spacing: 10) {
            Text("👉")
                .font(.system(size: 16))
            Text("Хочешь узнать об обновлении первым?")
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.8))
        )
    }

    var wantButton: some View {
        Button(action: onWantTournamentsTap) {
            Text("Да хочу!")
                .font(EAFont.infoTitle)
                .foregroundStyle(EAColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [EAColor.purpleAccent.opacity(0.95), EAColor.purpleAccent.opacity(0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .buttonStyle(.plain)
    }

    var backgroundDecor: some View {
        ZStack {
            Circle()
                .fill(EAColor.csColor.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: 130, y: -250)
            Circle()
                .fill(EAColor.dotaColor.opacity(0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 34)
                .offset(x: -120, y: -180)
        }
    }

    var confirmationToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(EAColor.textPrimary)
            Text("Окей, уведомим тебя первым")
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [EAColor.purpleAccent.opacity(0.95), EAColor.info2.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(EAColor.textPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}


// MARK: Типо вьюмодель
private extension TournamentsPlaceholderView {
    func onWantTournamentsTap() {
        AppMetricaReporter.reportEvent("tournaments_wishlist_tap")
        showConfirmationToast = true
        AppMetricaReporter.reportEvent("tournaments_wishlist_confirm_shown")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showConfirmationToast = false
        }
    }

    func loadTopTournaments() async {
        guard !isLoadingTournaments else { return }
        isLoadingTournaments = true
        let topTournaments = await tournamentsService.fetchTopTournaments()
        cs2Tournament = topTournaments.first(where: { $0.game == .cs2 })?.title
        dota2Tournament = topTournaments.first(where: { $0.game == .dota2 })?.title
        isLoadingTournaments = false
    }
}
