//
//  Cell.swift
//  TODO
//
//  Created by colin.qin on 2025/5/6.
//

import Foundation

class Cell: Codable {
    var icon: String
    var title: String
    var time: String
    var detail: String
    
    init() {
        self.icon = ""
        self.title = ""
        self.time = ""
        self.detail = ""
    }

}
