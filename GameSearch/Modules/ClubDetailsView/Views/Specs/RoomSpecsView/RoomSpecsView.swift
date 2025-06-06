//
//  RoomSpecsView.swift
//  GameSearch
//
//  Created by Ацамаз on 06.06.2025.
//

import SwiftUI


struct RoomSpecsView: View {
    @Binding var isSelected: Bool
    let data: RoomSpecsData


    var body: some View {
        VStack {
            headerView
            if isSelected {
                specsView
            }
        }
        .drawingGroup()
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .background(EAColor.info1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            withAnimation(.easeInOut) {
                isSelected.toggle()
            }
        }
    }
}


private extension RoomSpecsView {
    var headerView: some View {
        HStack {
            Text(data.roomName)
                .font(EAFont.infoTitle)
                .foregroundStyle(EAColor.textPrimary)
            stationCountLabel
            Spacer()
            RadioButton(isSelected: $isSelected)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(EAColor.info1)
    }

    var stationCountLabel: some View {
        Text("\(data.stationCount) пк")
            .font(EAFont.info)
            .foregroundStyle(EAColor.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(EAColor.info2.opacity(0.2))
            }
    }

    var specsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                specBlock(.videocard)
                specBlock(.chip)
                specBlock(.ram)
                specBlock(.monitor)
            }
            Spacer()
            Rectangle()
                .frame(width: 1, height: 150)
                .foregroundStyle(Color.white)
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                specBlock(.keyboard)
                specBlock(.mouse)
                specBlock(.headphones)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    func specBlock(_ type: SpecBlockType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(type.title)
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.info2)
            Text(type.textValue(data))
                .font(EAFont.info)
                .foregroundStyle(EAColor.textPrimary)
        }
    }
}


private enum SpecBlockType {
    case videocard
    case chip
    case keyboard
    case mouse
    case ram
    case monitor
    case headphones

    var title: String {
        switch self {
        case .videocard: return "Видеокарта"
        case .chip: return "Процессор"
        case .keyboard: return "Клавиатура"
        case .mouse: return "Мышь"
        case .ram: return "Оперативная память"
        case .monitor: return "Монитор"
        case .headphones: return "Наушники"
        }
    }

    func textValue(_ data: RoomSpecsData) -> String {
        switch self {
        case .videocard: return data.videocard
        case .chip: return data.chip
        case .keyboard: return data.keyboard
        case .mouse: return data.mouse
        case .ram: return "\(data.ram) ГБ"
        case .monitor:
            return data.monitorBrand
            + "\n\(data.monitorDiag)'' "
            + "\(data.hz) Hz"
        case .headphones: return "HyperX Cloud II"
        }
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    RoomSpecsView(
        isSelected: .constant(true),
        data: RoomSpecsData(
            roomName: "Стандарт",
            stationCount: 20,
            videocard: "NVIDIA RTX 4070Ti",
            chip: "Intel Core i7-12700K",
            mouse: "Logitech G502",
            keyboard: "Logitech G Pro",
            headphones: "HyperX Cloud II",
            ram: 32,
            monitorBrand: "AOC 27G2",
            monitorDiag: 27,
            hz: 144
        )
    )
}
