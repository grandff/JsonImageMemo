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
    9. 화면이 열릴땐 delegate를, 닫힐땐 delegeate가 nil이도록 설정
    10. 키보드가 화면을 가리지 않도록 해주는 notification 설정
    */
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextView!
        
    var editMemo : Memo?        // 매모 객체 전달받을 변수(4)
    var originalMemoContent : String?       // 메모 내용이 수정됐는지 확인 하기 위해 오리지날 값을 저장하는 변수(5)
    
    var willShowToken : NSObjectProtocol?   // 키보드가 올라올 경우 호출(10)
    var willHideToken : NSObjectProtocol?   // 키보드가 사라질 경우 호출(10)
    
    // 키보드 토큰 값이 있을 경우 미리 삭제(10)
    deinit{
        if let token = willShowToken{
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHideToken{
            NotificationCenter.default.removeObserver(token)
        }
    }
    
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
        
        // textview의 delegate 설정
        memoTextField.delegate = self
        
        // 키보드가 보여질 경우 생성되는 옵저버(10)
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: {[weak self] (noti) in
            // 키보드 높이 만큼 여백을 추가해야되는데, 실행환경마다 다르므로 노티피케이션 값에 따라 구현해야함
            guard let strongSelf = self else {return}
            
            // 높이 속성이 height에 저장됨
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
                let height = frame.cgRectValue.height
                
                var inset = strongSelf.memoTextField.contentInset        // 현재 값
                inset.bottom = height       // 키보드 높이값을 하단에 설정해줌
                strongSelf.memoTextField.contentInset = inset        // 설정한 값을 적용
                
                inset = strongSelf.memoTextField.verticalScrollIndicatorInsets // 스크롤바에도 똑같은 여백 추가
                strongSelf.memoTextField.verticalScrollIndicatorInsets = inset
            }
        })
        
        // 키보드가 사라질 경우 생성되는 옵저버(10) 새로운 옵저버를 호출할때는 기존 호출한 옵저버 메서드가 다 끝난후 해야함
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: {[weak self] (noti) in
            // 키보드가 사라질 경우 여백 제거
            guard let strongSelf = self else {return}
            var inset = strongSelf.memoTextField.contentInset
            inset.bottom = 0
            strongSelf.memoTextField.contentInset = inset
            
            inset = strongSelf.memoTextField.verticalScrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextField.verticalScrollIndicatorInsets = inset
        })
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
    
    // 화면이 열릴 경우 delegate 처리(9)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.presentationController?.delegate = self
    }
    
    // 화면이 닫힐 경우 delegate 처리(9)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.presentationController?.delegate = nil
    }
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
