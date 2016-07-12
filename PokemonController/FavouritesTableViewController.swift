//
//  FavouritesTableViewController.swift
//  PokemonController
//
//  Created by win on 7/13/16.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

protocol FavouritesTableViewControllerDelegate {
    func favouritesTableViewControllerDidSelectLocation(viewController: FavouritesTableViewController, location: Location)
}

class FavouritesTableViewController: UITableViewController {

    var delegate: FavouritesTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didPressDoneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FavouritesTableViewController {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Location.allLocations().count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath)
        
        let location = Location.allLocations()[indexPath.row]
        
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = "\(location.lat),\(location.lng)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        showAlert(Location.allLocations()[indexPath.row])
    }
}

extension FavouritesTableViewController {
    func showAlert(location: Location) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let goAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.Default) { [unowned self] (action) in
            self.delegate?.favouritesTableViewControllerDidSelectLocation(self, location: location)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let removeAction = UIAlertAction(title: "Remove from Favourites", style: UIAlertActionStyle.Destructive) { [weak self] (action) in
            
            location.remove()
            
            self?.tableView.reloadData()
        }
        
        alertController.addAction(goAction)
        alertController.addAction(removeAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
