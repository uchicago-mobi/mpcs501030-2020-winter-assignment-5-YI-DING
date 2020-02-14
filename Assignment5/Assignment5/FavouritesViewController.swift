//
//  FavouritesViewControllerTableViewController.swift
//  Assignment5
//
//  Created by Yi Ding on 2/10/20.
//  Copyright © 2020 Yi Ding. All rights reserved.
//

import UIKit
//https://stackoverflow.com/questions/30576291/swift-uitableview-inside-uiviewcontroller-uitableview-functions-are-not-calle
//mummy rootview constraints immutable and tableview inside UIViewController is hard to figure out ......
class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var exitButton: UIButton!
    weak var delegate: PlacesFavoritesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.exitButton.addTarget(self, action: #selector(dismissFavouriteViewController), for: .touchDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData() //update everytime in case users added or deleted favourites data
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.sharedInstance.favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouritesCell", for: indexPath)
        let index = DataManager.sharedInstance.favourites[indexPath.row]
        cell.textLabel?.text = DataManager.sharedInstance.placeArray[index].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.favouritePlace(placeIndex: DataManager.sharedInstance.favourites[indexPath.row])
        self.dismiss(animated: true, completion: {})
    }
    
    //dismiss button
    @IBAction func dismissFavouriteViewController() {
        self.dismiss(animated: true, completion: {})
    }
    
}

protocol PlacesFavoritesDelegate : class {
    func favouritePlace(placeIndex : Int) -> Void
}


