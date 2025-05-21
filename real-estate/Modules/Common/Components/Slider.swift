import SwiftUI

struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    @Binding var currentMin: Double
    @Binding var currentMax: Double

    private let trackHeight: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фоновая дорожка
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackHeight)

                // Закрашенный диапазон
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(Color.blue)
                    .frame(height: trackHeight)
                    .offset(x: normalizedMinPosition(for: geometry.size.width))
                    .frame(
                        width: normalizedRangeWidth(for: geometry.size.width))

                // Минимальный ползунок
                SliderHandle(
                    position: normalizedMinPosition(for: geometry.size.width)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newValue =
                                value.location.x / geometry.size.width
                                * (maxValue - minValue) + minValue
                            currentMin = min(
                                max(newValue, minValue), currentMax)
                        }
                )

                // Максимальный ползунок
                SliderHandle(
                    position: normalizedMaxPosition(for: geometry.size.width)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newValue =
                                value.location.x / geometry.size.width
                                * (maxValue - minValue) + minValue
                            currentMax = max(
                                min(newValue, maxValue), currentMin)
                        }
                )
            }
            .frame(height: 40)
        }
    }

    private func normalizedMinPosition(for width: CGFloat) -> CGFloat {
        (currentMin - minValue) / (maxValue - minValue) * width
    }

    private func normalizedMaxPosition(for width: CGFloat) -> CGFloat {
        (currentMax - minValue) / (maxValue - minValue) * width
    }

    private func normalizedRangeWidth(for width: CGFloat) -> CGFloat {
        normalizedMaxPosition(for: width) - normalizedMinPosition(for: width)
    }
}

struct SliderHandle: View {
    let position: CGFloat

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 24, height: 24)
            .shadow(radius: 2)
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            .offset(x: position - 12)
    }
}
