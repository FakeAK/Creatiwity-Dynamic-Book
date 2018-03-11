//
//  Page.swift
//  Creatiwity
//
//  Created by Arthur Kleiber on 09/03/2018.
//  Copyright © 2018 Arthur Kleiber. All rights reserved.
//

import Foundation

class Page : NSObject, NSCoding {
    let text: String?

    init(string: String?) {
        self.text = string
    }

    required convenience init(coder aDecoder: NSCoder) {
        let text = aDecoder.decodeObject(forKey: "text") as! String
        self.init(string: text)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "text")
    }
}
