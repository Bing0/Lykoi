//
// Created by Thomas on 2020/12/12.
//

import SwiftUI
import UIKit


class DocViewController: UIViewController {
    private var pdfDoc:                      PDFDoc?
    private var scale:                       CGFloat      = 1.0
    private var scaleStart:                  CGFloat      = 1.0
    private var zoomCenterInRealContent:     CGPoint      = .zero
    private var zoomCenterXToMidRealContent: CGFloat      = 0
    private var testPoint                                 = UIView(frame: .init())
    private let miniScale:                   CGFloat      = 0.25
    private let maxScale:                    CGFloat      = 8
    private var magnifierView:               MagnifyView? = nil
    private var isPencilDetected                          = false
    private var pageIndexOfCurrentDrawing                 = 0

    var lastEditingMode: EditingMode {
        willSet {
            switch newValue {
                case .hand:
                    pdfDocView.panGestureRecognizer.minimumNumberOfTouches = 1
                    if !pdfDocView.panGestureRecognizer.allowedTouchTypes.contains(UITouch.TouchType.pencil.rawValue as NSNumber) {
                        pdfDocView.panGestureRecognizer.allowedTouchTypes.append(UITouch.TouchType.pencil.rawValue as NSNumber)
                    }
                    if pdfDocView.gestureRecognizers!.contains(drawAnnotationGesture) {
                        pdfDocView.removeGestureRecognizer(drawAnnotationGesture)
                    }
                case .highlight:
                    pdfDocView.panGestureRecognizer.minimumNumberOfTouches = 1
                    if !pdfDocView.panGestureRecognizer.allowedTouchTypes.contains(UITouch.TouchType.pencil.rawValue as NSNumber) {
                        pdfDocView.panGestureRecognizer.allowedTouchTypes.append(UITouch.TouchType.pencil.rawValue as NSNumber)
                    }
                    if pdfDocView.gestureRecognizers!.contains(drawAnnotationGesture) {
                        pdfDocView.removeGestureRecognizer(drawAnnotationGesture)
                    }
                case .draw:
                    drawAnnotationGesture = DrawAnnotationGestureRecognizer(target: self, action: #selector(DocViewController.drawAnnotation(_:)))
                    drawAnnotationGesture.updateCoordinateSpaceView = { location in
                        if let indexPath = self.pdfDocView.indexPathForItem(at: location) {
                            let pageView = self.pdfDocView.cellForItem(at: indexPath) as! PDFPageView
                            return pageView
                        }
                        return self.pdfDocView
                    }

                    if isPencilDetected {
                        switchToPencil()
                        pdfDocView.addGestureRecognizer(drawAnnotationGesture)
                    } else {
                        switchToHand()
                        pdfDocView.addGestureRecognizer(drawAnnotationGesture)
                    }
            }
        }
    }

    lazy var pdfDocView: UICollectionView = {
        let layout = UICollectionViewScaleLayout()
        let cv     = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    var drawAnnotationGesture = DrawAnnotationGestureRecognizer()

    init(url: URL, editingMode: EditingMode) {
        lastEditingMode = editingMode

        super.init(nibName: nil, bundle: nil)
        pdfDoc = PDFDoc(withURL: url)

        testPoint.backgroundColor = .red
        testPoint.frame.size = CGSize(width: 3, height: 3)
        pdfDocView.addSubview(testPoint)
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(DocViewController.zoomPdfView(_:)))
        view.addGestureRecognizer(zoomGesture)
    }

    required init?(coder: NSCoder) {
        lastEditingMode = .hand
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pdfDocView)
        pdfDocView.register(PDFPageView.self, forCellWithReuseIdentifier: "pdfPage")
        pdfDocView.dataSource = self
        pdfDocView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        pdfDocView.frame = view.bounds
    }

    @objc func zoomPdfView(_ sender: UIPinchGestureRecognizer) {
        let layout = pdfDocView.collectionViewLayout as! UICollectionViewScaleLayout

        func fixContentOffset() {
            guard sender.numberOfTouches == 2 else {
                return
            }
            var scaledZoomCenter = zoomCenterInRealContent

            if layout.collectionViewContentSize.width < view.frame.width {
                scaledZoomCenter.x = layout.contentMidX - zoomCenterXToMidRealContent * sender.scale
                scaledZoomCenter.y = scaledZoomCenter.y * sender.scale
            } else {
                scaledZoomCenter = scaledZoomCenter.applying(CGAffineTransform(scaleX: sender.scale, y: sender.scale))
            }

            testPoint.center = scaledZoomCenter

            let currentCenter = sender.location(in: pdfDocView)

            var offsetX = scaledZoomCenter.x - currentCenter.x + pdfDocView.contentOffset.x
            var offsetY = scaledZoomCenter.y - currentCenter.y + pdfDocView.contentOffset.y

            if offsetX + view.frame.width >= pdfDocView.contentSize.width {
                offsetX = pdfDocView.contentSize.width - view.frame.width
            }
            if offsetX <= 0 {
                offsetX = 0
            }

            if offsetY + view.frame.height >= pdfDocView.contentSize.height {
                offsetY = pdfDocView.contentSize.height - view.frame.height
            }
            if offsetY <= 0 {
                offsetY = 0
            }

            pdfDocView.contentOffset = CGPoint(x: offsetX, y: offsetY)
        }

        if sender.state == .began {
            scaleStart = scale
            zoomCenterInRealContent = sender.location(in: pdfDocView)
            testPoint.center = zoomCenterInRealContent
            zoomCenterXToMidRealContent = layout.contentMidX - zoomCenterInRealContent.x

            if layout.collectionViewContentSize.width < view.frame.width {
                zoomCenterInRealContent.x = zoomCenterInRealContent.x - (view.frame.width - layout.collectionViewContentSize.width)
            }
        } else if sender.state == .changed {
            scale = scaleStart * sender.scale
            if scale > maxScale {
                scale = maxScale
                return
            } else if scale < miniScale {
                scale = miniScale
                return
            }

            layout.scale = scale
            layout.invalidateLayout()

            fixContentOffset()
        }
    }

    @objc func drawAnnotation(_ sender: DrawAnnotationGestureRecognizer) {
        if !isPencilDetected {
            if sender.isPencilDetected {
                switchToPencil()
                isPencilDetected = true
            }
        }

        guard let pageView = sender.coordinateSpaceView as? PDFPageView else {
            return
        }

        pageView.drawAnnotation(sender)
    }

    func switchToPencil() {
        drawAnnotationGesture.allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
        pdfDocView.panGestureRecognizer.allowedTouchTypes = pdfDocView.panGestureRecognizer.allowedTouchTypes.filter { type in
            type != UITouch.TouchType.pencil.rawValue as NSNumber
        }
        pdfDocView.panGestureRecognizer.minimumNumberOfTouches = 1
    }

    func switchToHand() {
        drawAnnotationGesture.allowedTouchTypes = UIPanGestureRecognizer().allowedTouchTypes
        if !pdfDocView.panGestureRecognizer.allowedTouchTypes.contains(UITouch.TouchType.pencil.rawValue as NSNumber) {
            pdfDocView.panGestureRecognizer.allowedTouchTypes.append(UITouch.TouchType.pencil.rawValue as NSNumber)
        }
        pdfDocView.panGestureRecognizer.minimumNumberOfTouches = 2
    }

    func setEditingMode(editingMode: EditingMode) {
        if lastEditingMode != editingMode {
            lastEditingMode = editingMode
        }
    }
}


extension DocViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pdfDoc = pdfDoc else {
            return 0
        }

        return pdfDoc.numberOfPages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pageView
            = collectionView.dequeueReusableCell(withReuseIdentifier: "pdfPage", for: indexPath) as! PDFPageView
        if let pdfDoc = pdfDoc, let pdfPage = pdfDoc.page(atIndex: indexPath.row) {
            pageView.set(page: pdfPage)
        } else {
            pageView.set(page: nil)
        }

        return pageView
    }
}

extension DocViewController: UICollectionViewDelegate {

}


extension DocViewController: UICollectionViewDelegateScaleLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let pdfDoc = pdfDoc else {
            return CGSize.zero
        }

        return pdfDoc.pageSize(atIndex: indexPath.row)
    }
}


struct PDFDocViewController: UIViewControllerRepresentable {
    var          url:             URL
    var          annotationInDoc: AnnotationInDoc?
    @Binding var editingMode:     EditingMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> DocViewController {
        let viewController = DocViewController(url: url, editingMode: editingMode)
        return viewController
    }

    func updateUIViewController(_ uiViewController: DocViewController, context: Context) {
        uiViewController.setEditingMode(editingMode: editingMode)
    }

    class Coordinator: NSObject {
        var parent: PDFDocViewController

        init(_ viewController: PDFDocViewController) {
            parent = viewController
        }
    }
}
