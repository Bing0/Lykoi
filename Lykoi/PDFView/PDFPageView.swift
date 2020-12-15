//
// Created by Thomas on 2020/12/13.
//

import UIKit

private class PDFTiledLayer: CATiledLayer {

    override init() {
        super.init()
        levelsOfDetail = 1
        levelsOfDetailBias = 2
        tileSize = CGSize(width: 256, height: 256)
    }

    override class func fadeDuration() -> CFTimeInterval {
        0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class PDFPageView: UICollectionViewCell {
    private var pdfPage: PDFPage?
    private let annotationLayer = CALayer()
    private var currentAnnotationLayer = CAShapeLayer()
    private var annotationPoints = [CGPoint]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(annotationLayer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override class var layerClass: AnyClass {
        PDFTiledLayer.self
    }

    func set(page: PDFPage?) {
        pdfPage = page
        annotationLayer.sublayers?.removeAll()
        annotationPoints.removeAll()
        setNeedsDisplay()
    }

    func drawAnnotation(_ sender: DrawAnnotationGesture) {
        let point = sender.location(in: self)
        annotationPoints.append(point)

        if sender.state == .began {
            currentAnnotationLayer = CAShapeLayer()
            annotationLayer.addSublayer(currentAnnotationLayer)
        }
        let path = generatePathFromPoints(points: annotationPoints)


        currentAnnotationLayer.path = path.cgPath
        currentAnnotationLayer.fillColor = nil
        currentAnnotationLayer.opacity = 1.0;
        currentAnnotationLayer.strokeColor = UIColor.red.cgColor

        if sender.state == .ended {
            annotationPoints.removeAll()
        }

    }


    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.saveGState()
        pdfPage?.drawPage(inContext: ctx, fillColor: UIColor.white.cgColor)
        ctx.restoreGState()
    }

    private func generatePathFromPoints(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 10

        if points.count > 1 {
            for i in 0..<points.count-1 {
                let current = points[i]
                let next = points[i+1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
        return path
    }
}
