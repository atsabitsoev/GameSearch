//
//  MapPopup.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 10.06.2025.
//

import SwiftUI

struct MapPopup: View {
    @Environment(\.dismiss) private var dismiss
    @State var dragOffset: CGFloat = 0
    
    
    let data: MapPopupData
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    
    var body: some View {
        content
            .offset(y: max(dragOffset, 0))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation.height
                    }
                    .onEnded { _ in
                        if dragOffset > 100 {
                            onDismiss()
                        }
                        withAnimation {
                            dragOffset = 0 // Если не сильно потянул то возвращаешься в начальную позицию плавно, без прыжка
                        }
                    }
            )
    }
}

private extension MapPopup {
    var content: some View {
        VStack {
            switch data.state {
            case .full:
                fullView
            case .min:
                minView
            }
        }
        .drawingGroup()
        .padding(.horizontal, 16)
        .shadow(color: .background, radius: 4, x: 0, y: 4)
        .overlay(alignment: .bottom) {
            buttonsOverlay
        }
    }
    
    var fullView: some View {
        VStack(spacing: 0) {
            topView
            bottomContent
        }
    }
    
    var minView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(EAColor.info1)
            HStack {
                logoView
                Spacer()
                titleView
                    .padding(.bottom, 4)
                Spacer()
                ratingView
                    .padding(.trailing, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: Constants.popupMinHeight)
    }
    
    var topView: some View {
        ZStack(alignment: .bottom) {
            imageView
                .overlay(alignment: .topLeading) {
                    logoView
                }
            titleView
        }
    }
    
    var bottomContent: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(EAColor.info1)
            VStack(spacing: 12) {
                ratingView
                addressPriceView
            }
        }
        .cornersRadius(bottom: 20)
        .frame(maxHeight: 111)
    }
    
    var titleView: some View {
        Text(data.selectedClub.name)
            .foregroundStyle(EAColor.textPrimary)
            .font(EAFont.title)
    }
    
    var buttonsOverlay: some View {
        HStack {
            toDetailsButton
            phoneButton
        }
        .offset(x: 20, y: 20)
    }
    
    var toDetailsButton: some View {
        Button {
            onTap()
        } label: {
            Text(Constants.detailButtonTitle)
                .foregroundStyle(EAColor.textPrimary)
                .font(EAFont.infoBold)
                .padding(.horizontal, 56)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(EAColor.accent)
                )
        }
    }
    
    var phoneButton: some View {
        Button {
            UIApplication.shared.open(URL(string: "tel://89604012886")!)
        } label: {
            Image(systemName: "phone.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(EAColor.textPrimary)
                )
        }
    }
    
    var addressPriceView: some View {
        VStack {
            Text(data.selectedClub.address ?? "")
                .font(.body)
                .foregroundStyle(EAColor.textPrimary)
            Group {
                Text("от ")
                + Text("120").bold()
                    .fontWidth(.expanded)
                + Text(" ₽/час")
            }
            .font(.body)
            .foregroundStyle(EAColor.textPrimary)
        }
    }
    
    var ratingView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.yellow)
            Text(data.selectedClub.rating ?? "")
                .font(.body)
                .foregroundStyle(.textPrimary)
        }
    }
    
    var logoView: some View {
        AsyncImage(url: data.selectedClub.logo) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(EAColor.info2)
                .frame(width: 44, height: 44)
        }
        .padding(12)
    }
    
    var imageView: some View {
        AsyncImage(url: data.selectedClub.image) { image in
            shadowImage(image)
        } placeholder: {
            shadowPlaceholder
        }
        .cornersRadius(top: 16)
    }
    
    var shadowPlaceholder: some View {
        ZStack {
            VStack(spacing: 0){
                Text(Constants.emptyLabel)
                    .foregroundStyle(.textPrimary)
                Image("ghost")
                    .resizable()
                    .frame(width: 64, height: 64)
            }
            .frame(maxWidth: .infinity, maxHeight: Constants.popupFullHeight)
            .background(EAColor.background)
          
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        EAColor.info1,
                        EAColor.info1.opacity(0.2),
                        EAColor.info1.opacity(0.1)
                    ]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(maxWidth: .infinity, maxHeight: Constants.popupFullHeight)
        }
    }
    
    func shadowImage(_ image: Image) -> some View {
        ZStack(alignment: .bottom) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: Constants.popupFullHeight)
                .clipped()
                .cornerRadius(16)
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        EAColor.info1,
                        EAColor.info1.opacity(0.2),
                        EAColor.info1.opacity(0.1)
                    ]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(maxWidth: .infinity, maxHeight: Constants.popupFullHeight)
        }
    }
    
    enum Constants {
        static let emptyLabel = "Фото нет"
        static let detailButtonTitle = "Подробнее"
        
        
        static let popupFullHeight = 140.0
        static let popupMinHeight = 70.0
    }
}

#Preview {
    MapPopup(data: .init(selectedClub: .init(club: FullClubData.mock[0]), state: .full), onTap: {}, onDismiss: {})
}
