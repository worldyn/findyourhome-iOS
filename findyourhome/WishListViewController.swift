//
//  WishListViewController.swift
//  findyourhome
//
//  Created by Adam Jacobs on 17/05/17.
//  Copyright © 2017 Adam Jacobs. All rights reserved.
//

import UIKit

class WishListViewController: UIViewController {
    
    // Listings shown in table view
    var listings:[Listing] = [Listing]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
