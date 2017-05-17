//
//  ListingDetailViewController.swift
//  findyourhome
//
//  Created by Adam Jacobs
//  This file handles the detail view for a Listing 
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
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var contract: UILabel!
    @IBOutlet weak var sizeIcon: UIImageView!
    @IBOutlet weak var moneyIcon: UIImageView!
    @IBOutlet weak var contractIcon: UIImageView!
    @IBOutlet weak var linkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = listing!.address
        price.text = "\(listing!.price) / month"
        size.text = listing!.size
        area.text = listing!.area
        contract.text = listing!.contract
        let dateString = "\(listing!.publishedDate)"
        let index = dateString.index(dateString.startIndex, offsetBy: 10)
        publishedDate.text = dateString.substring(to: index)
        link.text = listing!.link
        listingImage.image = listing!.listingImage
        moneyIcon.image = UIImage(named: "MoneyIcon")
        sizeIcon.image = UIImage(named: "SizeIcon")
        contractIcon.image = UIImage(named: "ContractIcon")
        
        linkButton.addTarget(self, action: #selector(ListingDetailViewController.didTapLinkButton(sender:)), for: .touchUpInside)
    }
    
    @IBAction func didTapLinkButton(sender: AnyObject) {
        UIApplication.shared.open(URL(string: listing!.link)!)
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
