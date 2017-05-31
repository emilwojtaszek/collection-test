//
//  DataSource.swift
//  Test
//
//  Created by Emil Wojtaszek on 07/06/2017.
//  Copyright © 2017 AppUnite.com. All rights reserved.
//

import UIKit

public class DataSource: NSObject, UICollectionViewDataSource {
    
    var values: [String]
    
    public override init() {
        values = (0...150).map {
            _ in
            switch arc4random_uniform(3) {
            case 0: return "Hello"
            case 1: return "Hello, \nGoodbye"
            default: return "Hello,\nGoodbye,\nHello Again!"
            }
        }

    }
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return values.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TextCell
        let hue = CGFloat(indexPath.section) / 255
        cell.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        cell.label.text = values[indexPath.section]
        
        return cell
    }
    
    public func add(at index: Int) {
        values.insert("New Cell!\nNew Cell!\nNew Cell!\nNew Cell!\n", at: index)
    }
}
