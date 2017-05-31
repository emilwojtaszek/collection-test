//
//  MyLayout.swift
//  Test
//
//  Created by Emil Wojtaszek on 07/06/2017.
//  Copyright © 2017 AppUnite.com. All rights reserved.
//

import UIKit

final class MyLayout: UICollectionViewLayout {
    // cache cell sizes where index is section index
    private var cachedSizes: [CGSize] = []
    
    // cache collection view width
    private var width: CGFloat = 0

    // cached list of available index paths
    private var itemsIndexPaths: [IndexPath] = []

    // constants of estimated item height & spacing height
    private let estimatedHeight: CGFloat = 50.0
    private let spacingHeight: CGFloat = 5.0

    override public class var layoutAttributesClass: AnyClass {
        return MyLayoutAttributes.self
    }
    
    override open func prepare() {
        super.prepare()
        
        // cache collection width
        self.width = self.collectionView?.bounds.width ?? 0
        
        // cache list of existing index paths
        self.itemsIndexPaths = self.indexPaths()
    }
    
    override open var collectionViewContentSize: CGSize {
        return self.itemsIndexPaths
            /// get last cell
            .max { $0 < $1 }
            /// get frame of last cell
            .flatMap { self.itemFrame(for: $0).maxY }
            /// convert to `CGSize`
            .flatMap { CGSize(width: self.width, height: $0) } ?? .zero
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// get all cells in bounds
        return self.itemsIndexPaths
            .filter { rect.intersects(self.itemFrame(for: $0)) }
            .flatMap { self.layoutAttributesForItem(at: $0) }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // create new layout attributes for cell
        let attributes = MyLayoutAttributes(forCellWith: indexPath)
        attributes.preferredWidth = self.width

        // set proper frame
        attributes.frame = self.itemFrame(for: indexPath)
        return attributes
    }

    /// MARK: Invalidation
    
    override public func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        
        // check if cell dimesions changed
        if cachedSizes.count > originalAttributes.indexPath.section {
            return self.cachedSizes[originalAttributes.indexPath.section] != preferredAttributes.size
        }

        return true
    }

    override public func invalidationContext(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {

        // create invalidation context
        let invalidationContext = super.invalidationContext(
            forPreferredLayoutAttributes: preferredAttributes,
            withOriginalAttributes: originalAttributes)
        
        // cache new cell size
        let oldContentSize = self.collectionViewContentSize
        self.cachedSizes.insert(preferredAttributes.size, at: originalAttributes.indexPath.section)
        
        // cell dimesions changed so we can adjust content size
        let newContentSize = self.collectionViewContentSize
        invalidationContext.contentSizeAdjustment = CGSize(width: 0, height: newContentSize.height - oldContentSize.height)
        
        // cells' index paths to reload (invalidated cell indexPath + all cells below that index path)
        let cellsIndexPaths = self
            .itemsIndexPathsGreaterOrEqual(than: preferredAttributes.indexPath)
        
        // invalidate cells
        invalidationContext
            .invalidateItems(at: cellsIndexPaths)

        return invalidationContext
    }

    /// MARK: Cell insertions
    
    private var insertedIndexPaths: [IndexPath] = []

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        //
        self.insertedIndexPaths = updateItems
            .filter { $0.updateAction == .insert && $0.indexPathAfterUpdate?.item != NSNotFound }
            .flatMap { $0.indexPathAfterUpdate }
            .sorted { $0 > $1 }

        // make slot in cache array
        for indexPath in self.insertedIndexPaths {
            self.cachedSizes.insert(
                CGSize(width: self.width, height: self.estimatedHeight),
                at: indexPath.section)
        }
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // not sure what should do here
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // not sure what should do here
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    /// MARK: Private
    
    /// Calculate frame of cell at provided index path
    ///
    /// - Parameter indexPath: Describes cell
    /// - Returns: Frame of cell at provided index path
    private func itemFrame(for indexPath: IndexPath) -> CGRect {
        // get list of index paths above provided `indexPath`
        let indexPaths = self.itemsIndexPaths.filter { $0 < indexPath}
        
        // calculate total height of cell above provided `indexPath`
        let rowsHeight = indexPaths.reduce(0) {
            return $0 + (self.cachedHeight(at: $1))
        }
        
        // calculate total height of separators above provided `indexPath`
        let separatorsHeight = CGFloat(indexPath.section) * spacingHeight
        
        // calculate new frame for item at provided `indexPath`
        let origin = CGPoint(x: 0.0, y: rowsHeight + separatorsHeight)
        let height = self.cachedHeight(at: indexPath)
        let size = CGSize(width: width, height: height)
        return CGRect(origin: origin, size: size)
    }

    /// Returs list of available index paths based on collection view data source
    ///
    /// - Returns: Array of `IndexPath`
    private func indexPaths() -> [IndexPath] {
        guard let collectionView = collectionView else { return [] }
        var indexPaths: [IndexPath] = []
        
        // Assuming that tableView is your self.tableView defined somewhere
        for i in 0..<collectionView.numberOfSections {
            for j in 0..<collectionView.numberOfItems(inSection: i) {
                indexPaths.append(IndexPath(row: j, section: i))
            }
        }
        
        return indexPaths
    }
    
    /// Get cached cell height of return estimated item height
    ///
    /// - Parameter indexPath: Index path representing cell
    /// - Returns: `CGFloat` representing cell height
    private func cachedHeight(at indexPath: IndexPath) -> CGFloat {
        if cachedSizes.count > indexPath.section {
            return cachedSizes[indexPath.section].height
        }

        return estimatedHeight
    }
    
    /// Get list of `IndexPaths` representing cells below provided value
    ///
    /// - Parameter indexPath: Index path representing start index
    /// - Returns: Array of `IndexPath`
    private func itemsIndexPathsGreaterOrEqual(than indexPath: IndexPath) -> [IndexPath] {
        return self.itemsIndexPaths
            .filter { $0 >= indexPath }
    }
}
