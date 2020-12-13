//
// Created by Thomas on 2020/12/12.
//

import SwiftUI
import UIKit


class DocViewController: UIViewController {
    private var pdfDoc: PDFDoc?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewScaleLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        pdfDoc = PDFDoc(withURL: url)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.register(PDFPageView.self, forCellWithReuseIdentifier: "pdfPage")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame = view.bounds
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
        let pageView = collectionView.dequeueReusableCell(withReuseIdentifier: "pdfPage", for: indexPath) as! PDFPageView
        if let pdfDoc = pdfDoc, let pdfPage = pdfDoc.page(atIndex: indexPath.row) {
            pageView.set(page: pdfPage)
        }else {
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


private protocol UICollectionViewDelegateScaleLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}


class UICollectionViewScaleLayout: UICollectionViewLayout {
    private var contentSize: CGSize = .zero
    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var _contentMidX: CGFloat = 0

    var scale: CGFloat = 1.0
    var contentMidX: CGFloat {
        _contentMidX
    }

    override func prepare() {
        super.prepare()
        generateAttributesAndContentSize()
    }

    private func generateAttributesAndContentSize() {
        guard let collectionView = self.collectionView else {
            return
        }

        guard let delegate = self.collectionView?.delegate as? UICollectionViewDelegateScaleLayout else {
            return
        }

        contentSize = .zero
        attributes.removeAll()

        let sections = collectionView.numberOfSections
        let viewWidth = collectionView.frame.size.width

        for section in 0..<sections {
            let rows = collectionView.numberOfItems(inSection: section)
            for row in 0..<rows {
                let indexPath = IndexPath(row: row, section: section)
                let originSize = delegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attribute.size = originSize
                let maxX = viewWidth > originSize.width * scale ? viewWidth : originSize.width * scale
                let center = CGPoint(x: maxX / 2, y: contentSize.height + originSize.height / 2 * scale)
                attribute.center = center

                attribute.transform3D = CATransform3DMakeScale(scale, scale, 1.0)

                attributes.append(attribute)

                let width
                        = attribute.frame.origin.x > 0 ? attribute.frame.width + attribute.frame.origin.x : attribute.frame.width

                if width > contentSize.width {
                    contentSize.width = width
                }
                contentSize.height = contentSize.height + originSize.height * scale
            }
        }

        if contentSize.width > viewWidth {
            _contentMidX = contentSize.width / 2
        } else {
            _contentMidX = viewWidth / 2
        }
    }

    override var collectionViewContentSize: CGSize {
        contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attributes.filter {
            $0.frame.intersects(rect)
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        attributes.first {
            $0.indexPath == indexPath
        }
    }

}


struct PDFDocViewController: UIViewControllerRepresentable {
    var url: URL
    var annotationInDoc: AnnotationInDoc?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> DocViewController {
        let viewController = DocViewController(url: url)
        return viewController
    }

    func updateUIViewController(_ uiViewController: DocViewController, context: Context) {

    }

    class Coordinator: NSObject {
        var parent: PDFDocViewController

        init(_ viewController: PDFDocViewController) {
            parent = viewController
        }
    }
}