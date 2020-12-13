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

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

//    override class var layerClass: AnyClass {
//        PDFTiledLayer.self
//    }

    func set(page: PDFPage?) {
        pdfPage = page
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.saveGState()
        pdfPage?.drawPage(inContext: ctx, fillColor: UIColor.white.cgColor)
        ctx.restoreGState()
    }
}
