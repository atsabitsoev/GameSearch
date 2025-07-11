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
            topView
            headerView
            segmentedView
            Spacer()
        }
    }

    var topView: some View {
        ZStack(alignment: .bottomLeading) {
            imageCarousel
            logoView
        }
    }

    var imageCarousel: some View {
        ImageCarouselView(images: viewModel.output?.images ?? [])
            .frame(height: 220)
            .dontBlockBackSwipe()
    }

    var headerView: some View {
        HStack {
            phoneButton
                .frame(maxWidth: 60, alignment: .leading)
            Spacer()
            Text(viewModel.output?.name ?? "")
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            ratingView
                .frame(maxWidth: 60, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 0)
                .fill(EAColor.background)
                .shadow(color: EAColor.background, radius: 10, x: 0, y: -16)
                .padding(.horizontal, -16)
        }
    }

    var phoneButton: some View {
        Group {
            if let phoneNumber = viewModel.output?.phone,
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
        }
    }

    var ratingView: some View {
        Label(viewModel.output?.rating ?? "0", systemImage: "star.fill")
            .foregroundStyle(EAColor.yellow)
            .fontWeight(.bold)
    }

    var logoView: some View {
        AsyncImage(url: URL(string: viewModel.output?.logo ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } placeholder: {
            RoundedRectangle(cornerRadius: 10)
                .fill(EAColor.background)
                .frame(width: 60, height: 60)
        }
        .padding()
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
                    specsSection
                }
            }
        )
        .dontBlockBackSwipe()
    }

    var infoSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let info = viewModel.output?.info {
                    InfoView(info)
                }
                if let locationInfo = viewModel.output?.locationInfo {
                    LocationInfoView(data: locationInfo)
                }
                if let priceInfo = viewModel.output?.priceInfo {
                    PriceInfoView(priceInfo)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 24)
        }
        .scrollIndicators(.hidden)
        .background(EAColor.background)
    }

    var specsSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let specs = viewModel.output?.specsData {
                    ForEach(specs) { spec in
                        RoomSpecsView(
                            isSelected: specsSectionBinding(for: spec.id),
                            data: spec)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 24)
        }
        .scrollIndicators(.hidden)
        .background(EAColor.background)
    }

    func specsSectionBinding(for id: UUID) -> Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.selectedSpecId == id },
            set: { newValue in
                if newValue {
                    viewModel.selectedSpecId = id
                } else {
                    viewModel.selectedSpecId = nil
                }
            }
        )
    }
}


#Preview {
    ClubDetailsView(viewModel: ClubDetailsViewModel(data: FullClubData.mock[0].getDetailsData(), interactor: ClubDetailsInteractor()))
}
