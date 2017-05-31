//
//  TextCell.swift
//  Test
//
//  Created by Emil Wojtaszek on 07/06/2017.
//  Copyright © 2017 AppUnite.com. All rights reserved.
//

import UIKit

class TextCell: UICollectionViewCell {
    private lazy var widthLayoutConstraint: NSLayoutConstraint? = {
        return self.contentView.widthAnchor.constraint(equalToConstant: 0)
    }()

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        // preferredWidth is width of collection view provided from collection view layout
        // i'm using this value to make each cell width be equal to collection view width
        if let layoutAttributes = layoutAttributes as? MyLayoutAttributes {
            if let preferredWidth = layoutAttributes.preferredWidth {
                self.widthLayoutConstraint?.constant = preferredWidth
                self.widthLayoutConstraint?.isActive = true
            } else {
                self.widthLayoutConstraint?.isActive = false
            }
        }

        print("preferredLayoutAttributesFitting: \(layoutAttributes.indexPath)")

        //
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // add subview and constraints
        contentView.addSubview(label)
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
