//
//  TableViewController.swift
//  MartiniFinder
//
//  Created by Tomas Sidenfaden on 2/3/18.
//  Copyright © 2018 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: Properties

    var locations = [Location]()
    var favoriteLocation: Favorites?
    var locationManager = CLLocationManager()
    
    // MARK: Outlets
    
    @IBOutlet var locationsTableView: UITableView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        self.tabBarController?.tabBar.isTranslucent = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        locationsTableView.reloadData()
    }

}

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! TableViewCell
        let location = Location.sharedInstance[indexPath.row]
                
        performUIUpdatesOnMain {
            
            cell.backgroundColor = UIColor.black
            
            cell.thumbnailImageView.layer.cornerRadius = 10
            cell.thumbnailImageView.clipsToBounds = true
            cell.thumbnailImageView.layer.borderColor = UIColor.white.cgColor
            cell.thumbnailImageView.layer.borderWidth = 1
            cell.thumbnailImageView.image = location.image
            
            cell.nameLabel.text = location.name
            cell.nameLabel.textColor = UIColor.white
            
            cell.priceLabel.text = location.price
            cell.priceLabel.textColor = UIColor.white
            
            cell.displayRating(location: location)
            
            if location.isOpenNow {
                
                    cell.openLabel.text = "Open"
                    cell.openLabel.textColor = UIColor.white
                } else {
                    cell.openLabel.text = "Closed"
                    cell.openLabel.textColor = UIColor(red: 195/255, green: 89/255, blue: 75/255, alpha: 1.0)
                    cell.openLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
                    }
                }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Location.sharedInstance.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Get each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! TableViewCell
        
        let nameText = Location.sharedInstance[indexPath.row].name
        
        var size = CGSize()
        
        if let font = UIFont(name: ".SFUIText", size: 17.0) {
            let fontAttributes = [NSAttributedStringKey.font: font]
            size = (nameText as NSString).size(withAttributes: fontAttributes)
        }
        
        let normalCellHeight = CGFloat(96)
        let extraLargeCellHeight = CGFloat(normalCellHeight + 20.33)
        
        let textWidth = ceil(size.width)
        let cellWidth = ceil(cell.nameLabel.frame.width)
        
        if textWidth > cellWidth {
            return extraLargeCellHeight
        } else {
            return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = Location.sharedInstance[indexPath.row]
        
        // Initialize NSManagedObject 'Location' with properties
        favoriteLocation = Favorites(context: CoreDataStack.sharedInstance().context)
        favoriteLocation?.name = location.name
        favoriteLocation?.isFavorite = true
        favoriteLocation?.id = location.id
        favoriteLocation?.latitude = location.latitude
        favoriteLocation?.longitude = location.longitude
        favoriteLocation?.price = location.price
        favoriteLocation?.rating = location.rating
        favoriteLocation?.imageUrl = location.imageUrl
        favoriteLocation?.isOpenNow = location.isOpenNow
        favoriteLocation?.image = UIImagePNGRepresentation(location.image!)! as NSData
        
        CoreDataStack.sharedInstance().saveContext()
        CoreDataStack.sharedInstance().save()

        
        // Get the Yelp URL of the location and segue to that in browser
        YelpClient.sharedInstance().getUrlFromLocationName(id: location.id) { (url, error) in

            performUIUpdatesOnMain {

                if error != nil {
                    print("There was an error getting the URL")
                }

                if let url = url {
                    let app = UIApplication.shared
                    app.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
