import SwiftUI
import PencilKit
import Combine

struct PencilKitCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var isDrawingEnabled: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.backgroundColor = UIColor.clear
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isDrawingEnabled
        if !isDrawingEnabled {
            uiView.tool = PKInkingTool(.pen, color: .black, width: 5)
        }
    }
}

class PencilKitCanvasViewModel: NSObject, ObservableObject {
    @Published var canvasView = PKCanvasView()

    override init() {
        super.init()
        canvasView.isOpaque = false
        canvasView.backgroundColor = UIColor.clear
    }

    func getDrawingImage() -> UIImage? {
        let bounds = canvasView.bounds
        guard !bounds.isEmpty else { return nil }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        canvasView.drawHierarchy(in: bounds, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
}
