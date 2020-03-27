//
//  SecondScreenViewController.swift
//  FindMallsOnMap
//
//  Created by Koketso Motsikwe (ZA) on 2020/03/20.
//  Copyright © 2020 Koketso Motsikwe (ZA). All rights reserved.
//

import UIKit
import MapKit

class SecondScreenViewController: UIViewController {
    
    var matchingItems: MKMapItem!
    
    @IBOutlet var mallName: UILabel!
    @IBOutlet var mallInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mallName.text = matchingItems.name
        mallInfo.text = matchingItems.placemark.title
        print(matchingItems.name ?? "")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
