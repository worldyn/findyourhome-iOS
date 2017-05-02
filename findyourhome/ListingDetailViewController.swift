//
//  ListingDetailViewController.swift
//  findyourhome
//
//  Created by Adam Jacobs on 27/04/17.
//  Copyright © 2017 Adam Jacobs. All rights reserved.
//

import UIKit

class ListingDetailViewController: UIViewController {
    // Model:
    var listing: Listing?
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var publishedDate: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var listingImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = listing!.address
        price.text = "\(listing!.price)"
        publishedDate.text = "\(listing!.publishedDate)"
        link.text = listing!.link
        listingImage.image = listing!.listingImage
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
