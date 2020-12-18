//
// Created by Thomas on 2020/12/13.
//

import UIKit

private class PDFPageTileLayer: CATiledLayer {
    override init() {
        super.init()
        levelsOfDetail = 2
        levelsOfDetailBias = 4
        tileSize = CGSize(width: 1024, height: 1024)
    }

    override class func fadeDuration() -> CFTimeInterval {
        0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class LayerDelegate: NSObject, CALayerDelegate {
    var pdfPage: PDFPage?

    func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.saveGState()
        pdfPage?.drawPage(inContext: ctx, fillColor: UIColor.white.cgColor)
        ctx.restoreGState()
    }
}

class PDFPageView: UICollectionViewCell {
    private var pdfPage: PDFPage?
    private let backgroundLayer        = CALayer()
    private let pdfPageLayer           = PDFPageTileLayer()
    private let annotationLayer        = CALayer()
    private var currentAnnotationLayer = CAShapeLayer()
    private var currentHighlightLayer  = CAShapeLayer()
    private var pdfPageLayerDelegate   = LayerDelegate()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(pdfPageLayer)
        layer.addSublayer(annotationLayer)
        pdfPageLayer.delegate = pdfPageLayerDelegate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func set(page: PDFPage?) {
        pdfPage = page
        backgroundLayer.frame = bounds
        annotationLayer.frame = bounds
        pdfPageLayer.frame = bounds
        pdfPageLayerDelegate.pdfPage = pdfPage

        backgroundLayer.contents = imageOfPage()?.cgImage
        pdfPageLayer.setNeedsDisplay()
        annotationLayer.sublayers?.removeAll()
    }

    func drawAnnotation(_ stroke: Stroke) {
        if stroke.state == .began {
            currentAnnotationLayer = CAShapeLayer()
            annotationLayer.addSublayer(currentAnnotationLayer)
        }
        let path = generatePathFromPoints(points: stroke.points)

        currentAnnotationLayer.path = path.cgPath
        currentAnnotationLayer.fillColor = nil
        currentAnnotationLayer.opacity = 1.0;
        currentAnnotationLayer.strokeColor = UIColor.red.cgColor

        stroke.updateTo(index: stroke.points.count)
    }

    func drawHighlight(_ stroke: Stroke) {
        if stroke.state == .began {
            let location = stroke.points[0].location
            if let rect = pdfPage!.charBox(at: location) {
                currentHighlightLayer = CAShapeLayer()
                currentHighlightLayer.frame = rect
                currentHighlightLayer.backgroundColor = UIColor.yellow.withAlphaComponent(0.5).cgColor
                annotationLayer.addSublayer(currentHighlightLayer)
            }
        } else if stroke.state == .changed {
            if currentHighlightLayer.superlayer == annotationLayer {
                guard let index1 = pdfPage!.charIndex(at: stroke.points.first!.location) else { return }
                guard let index2 = pdfPage!.charIndex(at: stroke.points.last!.location) else { return }
                let rects = pdfPage!.getRects(withinCharIndex: index1, andCharIndex: index2)
                currentHighlightLayer.removeFromSuperlayer()
                currentHighlightLayer = CAShapeLayer()
                annotationLayer.addSublayer(currentHighlightLayer)

                for rect in rects {
                    let layer = CAShapeLayer()
                    layer.frame = rect
                    layer.backgroundColor = UIColor.yellow.withAlphaComponent(0.5).cgColor
                    currentHighlightLayer.addSublayer(layer)
                }
            }
        }
    }

    private func generatePathFromPoints(points: [StrokePoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 1

        if points.count > 1 {
            for i in 0..<points.count - 1 {
                let current = points[i].location
                let next    = points[i + 1].location
                path.move(to: current)
                path.addLine(to: next)
            }
        }
        return path
    }

    private func imageOfPage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(pdfPage!.pageSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.saveGState()

        pdfPage!.drawPage(inContext: context, fillColor: UIColor.white.cgColor)

        context.restoreGState()

        defer { UIGraphicsEndImageContext() }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return image
    }
}
