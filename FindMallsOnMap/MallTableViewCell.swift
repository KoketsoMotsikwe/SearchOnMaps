//
//  MallTableViewCell.swift
//  FindMallsOnMap
//
//  Created by Koketso Motsikwe (ZA) on 2020/03/20.
//  Copyright © 2020 Koketso Motsikwe (ZA). All rights reserved.
//

import Foundation
import MapKit

class MallTableViewCell: UITableViewCell{
    
    @IBOutlet var mallName: UILabel!
    @IBOutlet var mallDescription: UILabel!
    
    func populate(matchingItem:MKMapItem){
        mallName.text = matchingItem.name ?? ""
        mallDescription.text = matchingItem.placemark.title
}

}
