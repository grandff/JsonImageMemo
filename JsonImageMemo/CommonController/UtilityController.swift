//
//  UtilityController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/18.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
        
    func dateFormatter(regDate : Date) -> String{
        let f = DateFormatter()
        let returnVal : String
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "ko_kr")
        returnVal = f.string(from: regDate)
        return returnVal
    }
    
}
