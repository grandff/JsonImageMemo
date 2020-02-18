//
//  MemoFormController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/18.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class MemoFormController: UIViewController {
    
    /*
       메모 폼 구현 순서
    1. outlet, action, 기타 스타일 코딩
    2. list에 전달할 notificationcenter extension 처리
    3. action 메서드 구현
    ----- 경고창 메서드 구현을 위해 새로운 컨트롤러 생성(AlertController)
    --> 등록이 정상적으로 되는지 확인하고 수정 메서드 구현하기
    4. 수정 기능을 구현하기 위해 저장된 메모 객체를 전달받을 수 있는 변수 생성
    ----- 메모 뷰에서 세그웨이 설정
    5. 수정을 알려주는 notification 생성
    6. 뷰에서 세그웨이 전달받는 코딩 후 수정 동작에 따른 제목, 액션 추가 등 기타 자세한 설정
    ----- 메모 뷰에서 notification 설정
    --> 수정이 되는지 확인
    7. 메모 삭제 기능 구현
    8. 편집 중 화면을 닫을때 저장여부를 선택하는 경고창을 표시하기 위해 textviewdelegate 추가
    */
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextView!
        
    var editMemo : Memo?        // 매모 객체 전달받을 변수(4)
    var originalMemoContent : String?       // 메모 내용이 수정됐는지 확인 하기 위해 오리지날 값을 저장하는 변수(5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 메모 입력폼 테두리 설정(1)
        memoTextField.layer.borderWidth = 0.6
        memoTextField.layer.borderColor = UIColor.gray.cgColor
        
        // 최초 화면 로딩 시 제목에 포커싱
        titleTextField.becomeFirstResponder()
        
        // 메모 수정, 등록에 따른 제목 및 내용 설정(5)
        if let memo = editMemo {            // 수정 시
            navigationItem.title = "메모 편집"
            titleTextField.text = memo.title
            memoTextField.text = memo.content
            originalMemoContent = memo.content
        }else{
            navigationItem.title = "새 메모"
        }
    }
    
    // 메모 등록 액션(3)(6)
    @IBAction func saveAction(_ sender: Any) {
        // 제목, 내용을 입력 안한 경우 경고창
        guard let title = titleTextField.text, !title.isEmpty else {
            alert(message: "제목을 입력하세요.")
            return
        }
        
        guard let memo = memoTextField.text, memo.count > 0 else{
            alert(message: "메모를 입력하세요.")
            return
        }
        
        // 메모 등록 처리 -> 메모 수정 구분 추가(6)
        if let target = editMemo {        // 수정 시
            target.title = title
            target.content = memo
            MemoData.shared.saveContext()
            NotificationCenter.default.post(name : MemoFormController.memoDidChange, object : nil)
        }else {                         // 등록 시
            MemoData.shared.addNewMemo(memo, title)
            NotificationCenter.default.post(name: MemoFormController.newMemoDidInsert, object: nil)
        }
        
        // 창 닫기
        dismiss(animated: true, completion: nil)
    }

    // 메모 취소 액션(3)
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

// Notification 추가(2)(5)
extension MemoFormController{
    // 등록과 수정을 알려줄 Notification static으로 생성
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}

// 텍스트가 바뀔때마다 오리지날과 편집본이 다를 경우 true를 return해주는 메서드 생성(8)
extension MemoFormController : UITextViewDelegate{
    func textViewDidChange(_ textView : UITextView){
        // ios 13이후부터 사용 가능함
        if let original = originalMemoContent, let edited = textView.text{
            // 편집한 내용일 경우 true가 리턴되는데 이 때 창이 안닫힘
            isModalInPresentation = original != edited
        }
    }
}

// 오리지날과 편집본이 다를 경우 경고창을 표시해주는 메서드(8)
extension MemoFormController : UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        // 확인을 누를경우 메모 저장
        let okAction = UIAlertAction(title: "확인", style: .default){[weak self] (action) in
            self?.saveAction(action)
        }
        alert.addAction(okAction)
        // 취소를 누를경우 그냥 닫음
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){[weak self] (action) in
            self?.cancelAction(action)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
