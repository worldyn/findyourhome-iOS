//
//  Listing.swift
//  findyourhome
//
//  Created by Adam Jacobs on 25/04/17.
//  Copyright © 2017 Adam Jacobs. All rights reserved.
//

import Foundation
import UIKit

class Listing {
    var link: String
    var address: String
    var price: Int
    var publishedDate: Date
    var listingImage: UIImage?
    var contract: String
    var area: String
    var size: String
    var seqNumber: Int
    
    init(_ link: String, _ address: String, _ price: Int, _ publishedDate: Date, _ listingImage: UIImage?,_ contract: String, _ area:String, _ size: String, _ seqNumber: Int) {
        self.link = link
        self.address = address
        self.price = price
        self.publishedDate = publishedDate
        self.listingImage = listingImage
        self.contract = contract
        self.area = area
        self.size = size
        self.seqNumber = seqNumber
    }
}
