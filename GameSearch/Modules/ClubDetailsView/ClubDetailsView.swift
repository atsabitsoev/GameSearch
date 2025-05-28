//
//  ClubDetailsView.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import SwiftUI


struct ClubDetailsView<ViewModel: ClubDetailsViewModelProtocol>: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ViewModel


    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        contentView
            .background(EAColor.background)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
            .customBackButton()
            .toolbarBackgroundVisibility(.hidden, for: .automatic)
    }


}


private extension ClubDetailsView {
    var contentView: some View {
        VStack(spacing: 0) {
            imageCarousel
            headerView
            segmentedView
            Spacer()
        }
    }

    var imageCarousel: some View {
        ImageCarouselView(images: viewModel.clubDetails.images)
            .frame(height: 220)
            .dontBlockBackSwipe()
    }

    var headerView: some View {
        HStack(alignment: .center) {
            if let phoneNumber = viewModel.clubDetails.phoneNumber,
                let phoneUrl = URL(string: "tel://\(phoneNumber)") {
                Button {
                    UIApplication.shared.open(phoneUrl)
                } label: {
                    Image(systemName: "phone.fill")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            } else {
                Spacer()
            }
            Spacer()
            Text(viewModel.clubDetails.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Label("\(viewModel.clubDetails.ratingString)", systemImage: "star.fill")
                .foregroundStyle(EAColor.yellow)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background {
            RoundedRectangle(cornerRadius: 0)
                .fill(EAColor.background)
                .shadow(color: EAColor.background, radius: 10, x: 0, y: -16)
                .padding(.horizontal, -16)
        }
    }

    var segmentedView: some View {
        SwipeSegmentedView(
            [.common, .specification],
            initialSegment: $viewModel.sectionPickerState,
            content: { segment in
                switch segment {
                case .common:
                    infoSection
                case .specification:
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 300, height: 300)
                }
            }
        )
        .dontBlockBackSwipe()
    }

    var infoSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !viewModel.clubDetails.description.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                                .foregroundColor(EAColor.info2)
                            Text(viewModel.clubDetails.description)
                                .font(.body)
                                .foregroundColor(EAColor.textPrimary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(EAColor.info1)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 24)
        }
        .background(EAColor.background)
    }
}


#Preview {
    ClubDetailsView(viewModel: ClubDetailsViewModel(data: FullClubData.mock[0].getDetailsData(), interactor: ClubDetailsInteractor()))
}
