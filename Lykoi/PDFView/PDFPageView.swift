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


struct SelectionRange: Equatable, CustomStringConvertible {
    var description: String {
        "(start: \(startIndex), end: \(endIndex))"
    }
    var length:      Int {
        endIndex - startIndex
    }

    var startIndex: Int
    var endIndex:   Int

    func expandRange(_ newStartIndex: Int, newEndIndex: Int) -> SelectionRange? {
        if newStartIndex >= endIndex {
            return SelectionRange(startIndex: startIndex, endIndex: newEndIndex)
        }
        if newEndIndex <= startIndex {
            return SelectionRange(startIndex: newStartIndex, endIndex: endIndex)
        }
        return nil
    }

    static func ==(lhs: SelectionRange, rhs: SelectionRange) -> Bool {
        lhs.startIndex == rhs.startIndex && lhs.endIndex == rhs.endIndex
    }
}

class PDFPageView: UICollectionViewCell {
    private var pdfPage: PDFPage?
    private let annotationLayer        = CALayer()
    private var currentAnnotationLayer = CAShapeLayer()
    private var currentHighlightLayer  = CAShapeLayer()

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
        setNeedsDisplay()
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
        }else if stroke.state == .changed {
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


    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.saveGState()
        pdfPage?.drawPage(inContext: ctx, fillColor: UIColor.white.cgColor)
        ctx.restoreGState()
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
}
