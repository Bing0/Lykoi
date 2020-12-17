//
// Created by Thomas on 2020/12/12.
//

import UIKit

class MagnifyView: UIView {
    var viewToMagnify: UIView!
    var touchPoint:    CGPoint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        // Set border color, border width and corner radius of the magnify view
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 3
        layer.cornerRadius = 50
        layer.masksToBounds = true
    }

    func setTouchPoint(pt: CGPoint) {
        touchPoint = pt
        center = CGPoint(x: pt.x, y: pt.y - 100)
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 1 * (self.frame.size.width * 0.5), y: 1 * (self.frame.size.height * 0.5))
        context!.scaleBy(x: 1.5, y: 1.5) // 1.5 is the zoom scale
        context!.translateBy(x: -1 * (touchPoint.x), y: -1 * (touchPoint.y))
        viewToMagnify.layer.render(in: context!)
    }
}