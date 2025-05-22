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
            .background(Color(white: 0.1))
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
            .customBackButton()
            .toolbarBackgroundVisibility(.hidden, for: .automatic)
    }


}


private extension ClubDetailsView {
    var contentView: some View {
        VStack(spacing: 0) {
            ImageCarouselView(images: [
                "https://static.mk.ru/upload/entities/2024/08/12/15/articles/facebookPicture/f2/bb/9d/af/d6b604fd8193701908ebe1253b033194.jpg",
                "https://avatars.mds.yandex.net/get-altay/5101995/2a00000181ae41cb1d9a224eda8204e57870/XXXL",
                "https://habrastorage.org/getpro/habr/comment_images/cb7/f7a/835/cb7f7a835a96567846ae29f7e759f01d.jpg"
            ])
            .frame(height: 220)
            .dontBlockBackSwipe()
            headerView
            SwipeSegmentedView(
                [.common, .specification],
                initialSegment: $viewModel.sectionPickerState,
                content: { segment in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 300, height: 300)

                }
            )
            .dontBlockBackSwipe()
            Spacer()
        }
    }

    var headerView: some View {
        HStack {
            Spacer()
            Spacer()
            Text(viewModel.clubDetails.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Label("\(viewModel.clubDetails.ratingString)", systemImage: "star.fill")
                .foregroundStyle(Color.yellow)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(white: 0.1))
                .shadow(color: Color(white: 0.1), radius: 10, x: 0, y: -16)
                .padding(.horizontal, -16)
        }
    }
}


#Preview {
    ClubDetailsView(viewModel: ClubDetailsViewModel(data: FullClubData.mock[0].getDetailsData(), interactor: ClubDetailsInteractor()))
}
