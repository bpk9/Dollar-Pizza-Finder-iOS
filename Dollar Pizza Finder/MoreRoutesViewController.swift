//
//  MoreRoutesViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/30/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit.UITableViewController

class MoreRoutesViewController: UITableViewController {
    
    var routes: [Route]!
    var selectedRoute: Route?
    
    // reset selected route when view appears
    override func viewDidAppear(_ animated: Bool) {
        self.selectedRoute = nil
    }
    
    // number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // create cell for each route
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell") as! RouteCell
        cell.routeLabel.text = GoogleDirections.getRouteText(route: routes[indexPath.row])
        return cell
    }
    
    // cell was tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRoute = self.routes[indexPath.row]
        performSegue(withIdentifier: "unwindToDirections", sender: self)
    }
    
}
