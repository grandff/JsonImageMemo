//
//  MemoViewController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/17.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController {
    
    /*
        메모 상세 구현 순서
     1. 코코아터치 클래스 생성 후 스토리보드에서 연결
     2. 세그웨이를 통해 전달받은 메모 데이터를 저장하기 위한 변수 생성
     3. outlet, action 설정(테이블뷰로 생성해줌)
     --> 이때 테이블셀 아이덴티티 및 밑줄 삭제 등 기본적인 설정은 스토리보드에서 다 해주고 넘어와야함. 미리 툴바도 생성
     4. 상세화면의 셀에 보여줄 내용을 설정하기 위해 extension 추가
     --> 여기까지 기본 detail view 기능
     5. 수정 기능을 추가하기 위해 아까 추가해둔 툴바에다가 버튼 추가
     6. 메모 등록 폼으로 데이터를 전달해줄 세그웨이 설정(스토리보드에서 연결 필수)
     7. 수정 시 form에서 observer를 받아 새로고침 해줌
     --> MemoData에도 해당 메서드 구현
     8. 메모 공유 기능 구현
     */
    
    var memo : Memo?        // 세그웨이 데이터 저장용(2)
    @IBOutlet weak var memoViewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 수정시 뷰에서 데이터 새로 고침(7)
        token = NotificationCenter.default.addObserver(forName : MemoFormController.memoDidChange, object : nil, queue : OperationQueue.main, using : {[weak self] (noti) in
            self?.memoViewTable.reloadData()
        })
    }
    
    // 수정 시 notification을 받을 변수 생성(7)
    var token : NSObjectProtocol?
    deinit {
        if let token = token{
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // 데이터 전달 세그웨이 설정(6)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 이거 코딩 어렵다잉
        if let vc = segue.destination.children.first as? MemoFormController{
            vc.editMemo = memo
        }
    }
    
    // 메모 삭제 기능(7)
    @IBAction func deleteAction(_ sender: Any) {
        let alert = UIAlertController(title : "삭제 확인", message : "메모를 삭제할까요?", preferredStyle : .alert)
        
        // destructive 설정을 통해 텍스트 빨간색으로 설정
        let okAction = UIAlertAction(title : "삭제", style : .destructive){[weak self](action) in
            MemoData.shared.deleteMemo(self?.memo)
            // 메모 삭제 후 목록 호출. popviewcontroller를 호출하면 stack에 쌓여있는 이전 viewcontroller로 이동하게 됨
            // 현재의 viewcontroller는 사라짐
            self?.navigationController?.popViewController(animated : true)
        }
        
        alert.addAction(okAction)
        
        // 어떤 버튼을 눌러도 닫히기 때문에 취소 액션은 구현할 필요가 없음
        let cancelAction = UIAlertAction(title : "취소", style : .cancel, handler : nil)
        alert.addAction(cancelAction)
        
        present(alert, animated : true, completion : nil)
    }
    
    // 메모 공유 기능(8)
    @IBAction func share(_ sender: Any) {
        guard let memo = memo?.content else {return}
        
        let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    
}

// tableview 데이터를 보여주기 위해 extension으로 설정(4)
extension MemoViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // switch 구문을 통해 셀마다 데이터 설정
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = memo?.title
            return cell
        case 1 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "regDateCell", for: indexPath)
            cell.textLabel?.text = dateFormatter(regDate: (memo?.regDate)!)
            return cell
        case 2 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
            cell.textLabel?.text = memo?.content
            return cell
        default:
            fatalError()
        }
    }
}
