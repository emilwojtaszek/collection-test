//
//  MyLayoutAttributes.swift
//  Test
//
//  Created by Emil Wojtaszek on 07/06/2017.
//  Copyright © 2017 AppUnite.com. All rights reserved.
//

import UIKit

class MyLayoutAttributes: UICollectionViewLayoutAttributes {
    // prefered with of cell (used for autolayout)
    var preferredWidth: CGFloat?
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! MyLayoutAttributes
        copy.preferredWidth = preferredWidth
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? MyLayoutAttributes {
            if attributes.preferredWidth == preferredWidth {
                return super.isEqual(object)
            }
        }
        return false
    }
}
