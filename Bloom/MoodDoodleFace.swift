import SwiftUI

struct MoodDoodleFace: View {
    let mood: String
    let size: CGFloat

    private var faceColor: Color {
        Color(red: 0.55, green: 0.35, blue: 0.32)  // Deep muted brown matching DriedRose typography
    }

    var body: some View {
        Canvas { context, canvasSize in
            let lineWidth = canvasSize.width * 0.08

            switch mood {
            case "Harika":
                drawHarikaFace(in: &context, size: canvasSize.width, lineWidth: lineWidth)
            case "İyi":
                drawIyiFace(in: &context, size: canvasSize.width, lineWidth: lineWidth)
            case "Orta":
                drawOrtaFace(in: &context, size: canvasSize.width, lineWidth: lineWidth)
            case "Kötü":
                drawKotuFace(in: &context, size: canvasSize.width, lineWidth: lineWidth)
            case "Berbat":
                drawBerbatFace(in: &context, size: canvasSize.width, lineWidth: lineWidth)
            default:
                drawHarikaFace(in: &context, size: canvasSize.width, lineWidth: lineWidth)
            }
        }
        .frame(width: size, height: size)
    }

    private func drawHarikaFace(in context: inout GraphicsContext, size: CGFloat, lineWidth: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let eyeRadius = size * 0.05
        let eyeSpacing = size * 0.12

        var path = Path()

        // Left open radiant eye - open circle with happy arc
        let leftEyeCenter = CGPoint(x: center.x - eyeSpacing, y: center.y - size * 0.08)
        path.addEllipse(in: CGRect(x: leftEyeCenter.x - eyeRadius, y: leftEyeCenter.y - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        // Right open radiant eye - open circle with happy arc
        let rightEyeCenter = CGPoint(x: center.x + eyeSpacing, y: center.y - size * 0.08)
        path.addEllipse(in: CGRect(x: rightEyeCenter.x - eyeRadius, y: rightEyeCenter.y - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        context.stroke(path, with: .color(faceColor), lineWidth: lineWidth)

        // Big happy curved smile
        var smilePath = Path()
        let smileStart = CGPoint(x: center.x - eyeSpacing * 0.8, y: center.y + size * 0.04)
        let smileEnd = CGPoint(x: center.x + eyeSpacing * 0.8, y: center.y + size * 0.04)
        let smileControl = CGPoint(x: center.x, y: center.y + size * 0.18)

        smilePath.move(to: smileStart)
        smilePath.addQuadCurve(to: smileEnd, control: smileControl)

        context.stroke(smilePath, with: .color(faceColor), lineWidth: lineWidth)
    }

    private func drawIyiFace(in context: inout GraphicsContext, size: CGFloat, lineWidth: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let eyeRadius = size * 0.04
        let eyeSpacing = size * 0.12

        var path = Path()

        // Left dot eye
        path.addEllipse(in: CGRect(x: center.x - eyeSpacing - eyeRadius, y: center.y - size * 0.08 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        // Right dot eye
        path.addEllipse(in: CGRect(x: center.x + eyeSpacing - eyeRadius, y: center.y - size * 0.08 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        context.fill(path, with: .color(faceColor))

        // Gentle curved smile
        var smilePath = Path()
        let smileStart = CGPoint(x: center.x - eyeSpacing * 0.7, y: center.y + size * 0.04)
        let smileEnd = CGPoint(x: center.x + eyeSpacing * 0.7, y: center.y + size * 0.04)
        let smileControl = CGPoint(x: center.x, y: center.y + size * 0.10)

        smilePath.move(to: smileStart)
        smilePath.addQuadCurve(to: smileEnd, control: smileControl)

        context.stroke(smilePath, with: .color(faceColor), lineWidth: lineWidth)
    }

    private func drawOrtaFace(in context: inout GraphicsContext, size: CGFloat, lineWidth: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let eyeRadius = size * 0.04
        let eyeSpacing = size * 0.12

        var path = Path()

        // Left dot eye
        path.addEllipse(in: CGRect(x: center.x - eyeSpacing - eyeRadius, y: center.y - size * 0.08 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        // Right dot eye
        path.addEllipse(in: CGRect(x: center.x + eyeSpacing - eyeRadius, y: center.y - size * 0.08 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        context.fill(path, with: .color(faceColor))

        // Perfectly straight neutral mouth
        var mouthPath = Path()
        let mouthStart = CGPoint(x: center.x - eyeSpacing * 0.6, y: center.y + size * 0.08)
        let mouthEnd = CGPoint(x: center.x + eyeSpacing * 0.6, y: center.y + size * 0.08)

        mouthPath.move(to: mouthStart)
        mouthPath.addLine(to: mouthEnd)

        context.stroke(mouthPath, with: .color(faceColor), lineWidth: lineWidth)
    }

    private func drawKotuFace(in context: inout GraphicsContext, size: CGFloat, lineWidth: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let eyeRadius = size * 0.04
        let eyeSpacing = size * 0.12

        var path = Path()

        // Left downcast dot eye (slightly lower)
        path.addEllipse(in: CGRect(x: center.x - eyeSpacing - eyeRadius, y: center.y - size * 0.06 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        // Right downcast dot eye (slightly lower)
        path.addEllipse(in: CGRect(x: center.x + eyeSpacing - eyeRadius, y: center.y - size * 0.06 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2))

        context.fill(path, with: .color(faceColor))

        // Slight downturned sad curved mouth
        var mouthPath = Path()
        let mouthStart = CGPoint(x: center.x - eyeSpacing * 0.7, y: center.y + size * 0.02)
        let mouthEnd = CGPoint(x: center.x + eyeSpacing * 0.7, y: center.y + size * 0.02)
        let mouthControl = CGPoint(x: center.x, y: center.y - size * 0.06)

        mouthPath.move(to: mouthStart)
        mouthPath.addQuadCurve(to: mouthEnd, control: mouthControl)

        context.stroke(mouthPath, with: .color(faceColor), lineWidth: lineWidth)
    }

    private func drawBerbatFace(in context: inout GraphicsContext, size: CGFloat, lineWidth: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let eyeRadius = size * 0.05
        let eyeSpacing = size * 0.12

        var path = Path()

        // Left eye - deeply downset distressed line (top-right to bottom-left)
        let leftEyeX = center.x - eyeSpacing
        path.move(to: CGPoint(x: leftEyeX - eyeRadius * 0.4, y: center.y - size * 0.10))
        path.addLine(to: CGPoint(x: leftEyeX + eyeRadius * 0.4, y: center.y - size * 0.02))

        // Right eye - deeply downset distressed line (top-left to bottom-right)
        let rightEyeX = center.x + eyeSpacing
        path.move(to: CGPoint(x: rightEyeX - eyeRadius * 0.4, y: center.y - size * 0.02))
        path.addLine(to: CGPoint(x: rightEyeX + eyeRadius * 0.4, y: center.y - size * 0.10))

        context.stroke(path, with: .color(faceColor), lineWidth: lineWidth)

        // Fully downturned sad mouth (inverted U)
        var mouthPath = Path()
        let mouthStart = CGPoint(x: center.x - eyeSpacing * 0.7, y: center.y + size * 0.03)
        let mouthEnd = CGPoint(x: center.x + eyeSpacing * 0.7, y: center.y + size * 0.03)
        let mouthControl = CGPoint(x: center.x, y: center.y - size * 0.08)

        mouthPath.move(to: mouthStart)
        mouthPath.addQuadCurve(to: mouthEnd, control: mouthControl)

        context.stroke(mouthPath, with: .color(faceColor), lineWidth: lineWidth)
    }
}

#Preview {
    HStack(spacing: 20) {
        VStack(spacing: 10) {
            MoodDoodleFace(mood: "Harika", size: 60)
            Text("Harika")
        }
        VStack(spacing: 10) {
            MoodDoodleFace(mood: "İyi", size: 60)
            Text("İyi")
        }
        VStack(spacing: 10) {
            MoodDoodleFace(mood: "Orta", size: 60)
            Text("Orta")
        }
        VStack(spacing: 10) {
            MoodDoodleFace(mood: "Kötü", size: 60)
            Text("Kötü")
        }
        VStack(spacing: 10) {
            MoodDoodleFace(mood: "Berbat", size: 60)
            Text("Berbat")
        }
    }
    .padding()
}
