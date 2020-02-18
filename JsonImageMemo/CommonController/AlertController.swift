//
//  AlertController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/18.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import UIKit

// UIViewController에서 모두 사용할 수 있도록 extension 처리
extension UIViewController{
    // 경고창 스타일은 alert view와 action sheet 두개가 있는데, 여기선 alert으로 처리
    func alert(title : String = "알림", message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        // 추가한 액션을 UIAlertAction에 추가해야함
        alert.addAction(okAction)
        // 설정한 커스텀 alert을 보여줌
        present(alert, animated: true, completion: nil)        
    }
}
