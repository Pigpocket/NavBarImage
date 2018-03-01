//
//  Common.swift
//  MartiniFinder
//
//  Created by Mehul Mistri on 3/1/18.
//  Copyright © 2018 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setNavigationItem() {
        print("setNavigationItem called")
        let imageView = UIImageView(image: UIImage(named: "yelp"))
        let item = UIBarButtonItem(customView: imageView)
        self.navigationItem.rightBarButtonItem = item
    }
}
