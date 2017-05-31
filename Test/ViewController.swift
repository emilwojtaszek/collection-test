//
//  ViewController.swift
//  Test
//
//  Created by Emil Wojtaszek on 31/05/2017.
//  Copyright © 2017 AppUnite.com. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    let datasource = DataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(TextCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.dataSource = datasource
    }

    @IBAction func addAction(_ sender: Any) {
        datasource.add(at: 2)
        collectionView?.performBatchUpdates({ [weak self] in
            self?.collectionView?.insertSections(IndexSet(integer: 2))
        })
    }
}

