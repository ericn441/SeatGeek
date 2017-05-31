//
//  DataStorage.swift
//  SeatGeek
//
//  Created by Eric on 5/30/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import Foundation

struct DataStorage
{
    static let userDefaults = UserDefaults.standard
    static func saveFavorite(_ dict: [String:Bool])
    {
        userDefaults.set(dict, forKey: "id")
        userDefaults.synchronize()
    }
}
