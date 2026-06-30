import SwiftUI

// Custom aesthetic sticker views — Pinterest-inspired, copyright-free

struct PinkBowSticker: View {
    var body: some View {
        VStack(spacing: -8) {
            // Left loop
            Ellipse()
                .fill(Color(red: 0.9, green: 0.7, blue: 0.8))
                .frame(width: 24, height: 20)
                .offset(x: -10)

            // Right loop
            Ellipse()
                .fill(Color(red: 0.9, green: 0.7, blue: 0.8))
                .frame(width: 24, height: 20)
                .offset(x: 10)

            // Center knot
            Circle()
                .fill(Color(red: 0.85, green: 0.6, blue: 0.75))
                .frame(width: 8, height: 8)
        }
        .frame(width: 48, height: 48)
    }
}

struct CoffeeSticker: View {
    var body: some View {
        VStack(spacing: 4) {
            // Steam
            VStack(spacing: 2) {
                Circle().fill(Color(white: 0.8)).frame(width: 4, height: 4)
                Circle().fill(Color(white: 0.75)).frame(width: 3, height: 3)
            }
            .offset(y: -2)

            // Cup
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.95, green: 0.93, blue: 0.90))
                .frame(width: 20, height: 18)

            // Handle
            Ellipse()
                .stroke(Color(red: 0.95, green: 0.93, blue: 0.90), lineWidth: 2)
                .frame(width: 6, height: 8)
                .offset(x: 12)
        }
        .frame(width: 48, height: 48)
    }
}

struct FlowerSticker: View {
    var body: some View {
        ZStack {
            // Petals
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.95, green: 0.75, blue: 0.85))
                    .frame(width: 10, height: 10)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(i) * 72))
            }

            // Center
            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.6))
                .frame(width: 8, height: 8)
        }
        .frame(width: 48, height: 48)
    }
}

struct CandleSticker: View {
    var body: some View {
        VStack(spacing: 2) {
            // Flame
            VStack {
                Ellipse()
                    .fill(Color(red: 1.0, green: 0.85, blue: 0.6))
                    .frame(width: 6, height: 8)
            }
            .offset(y: -2)

            // Candle body
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.95, green: 0.93, blue: 0.90))
                .frame(width: 12, height: 18)

            // Base
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.90, green: 0.88, blue: 0.85))
                .frame(width: 16, height: 4)
        }
        .frame(width: 48, height: 48)
    }
}

struct HeartSticker: View {
    var body: some View {
        ZStack {
            // Heart shape
            Canvas { context, size in
                var path = Path()
                let width = size.width * 0.8
                let height = size.height * 0.8
                let centerX = size.width / 2
                let centerY = size.height / 2

                path.move(to: CGPoint(x: centerX, y: centerY + height * 0.3))
                path.addCurve(
                    to: CGPoint(x: centerX - width * 0.25, y: centerY - height * 0.1),
                    control1: CGPoint(x: centerX - width * 0.4, y: centerY + height * 0.2),
                    control2: CGPoint(x: centerX - width * 0.35, y: centerY - height * 0.15)
                )
                path.addCurve(
                    to: CGPoint(x: centerX, y: centerY - height * 0.25),
                    control1: CGPoint(x: centerX - width * 0.15, y: centerY - height * 0.25),
                    control2: CGPoint(x: centerX - width * 0.05, y: centerY - height * 0.25)
                )
                path.addCurve(
                    to: CGPoint(x: centerX + width * 0.25, y: centerY - height * 0.1),
                    control1: CGPoint(x: centerX + width * 0.05, y: centerY - height * 0.25),
                    control2: CGPoint(x: centerX + width * 0.15, y: centerY - height * 0.25)
                )
                path.addCurve(
                    to: CGPoint(x: centerX, y: centerY + height * 0.3),
                    control1: CGPoint(x: centerX + width * 0.35, y: centerY - height * 0.15),
                    control2: CGPoint(x: centerX + width * 0.4, y: centerY + height * 0.2)
                )

                context.fill(path, with: .color(Color(red: 0.95, green: 0.75, blue: 0.85)))
            }
            .frame(width: 48, height: 48)
        }
    }
}

struct RibbonSticker: View {
    var body: some View {
        VStack(spacing: 0) {
            // Top bow loops
            HStack(spacing: -4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.9, green: 0.7, blue: 0.8))
                    .frame(width: 12, height: 10)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.9, green: 0.7, blue: 0.8))
                    .frame(width: 12, height: 10)
            }

            // Center
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.85, green: 0.6, blue: 0.75))
                .frame(width: 4, height: 6)

            // Tails
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.9, green: 0.7, blue: 0.8))
                    .frame(width: 3, height: 8)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.9, green: 0.7, blue: 0.8))
                    .frame(width: 3, height: 8)
            }
        }
        .frame(width: 48, height: 48)
    }
}

struct SparkleSticker: View {
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Group {
                    // Main sparkles
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        .frame(width: 2, height: 6)
                        .rotationEffect(.degrees(Double(i) * 90))

                    // Smaller sparkles
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        .frame(width: 1.5, height: 4)
                        .rotationEffect(.degrees(Double(i) * 90 + 45))
                        .offset(x: -6, y: -6)
                }
            }
        }
        .frame(width: 48, height: 48)
    }
}

// Sticker name to custom view mapping
func getCustomStickerView(_ name: String) -> AnyView? {
    switch name {
    case "bow":
        return AnyView(PinkBowSticker())
    case "coffee":
        return AnyView(CoffeeSticker())
    case "flower":
        return AnyView(FlowerSticker())
    case "candle":
        return AnyView(CandleSticker())
    case "pink_heart":
        return AnyView(HeartSticker())
    case "ribbon":
        return AnyView(RibbonSticker())
    case "sparkle":
        return AnyView(SparkleSticker())
    default:
        return nil
    }
}
