//
//  UICollectionViewScaleLayout.swift
//  Lykoi
//
//  Created by Thomas on 2020/12/17.
//

import UIKit


protocol UICollectionViewDelegateScaleLayout {
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
