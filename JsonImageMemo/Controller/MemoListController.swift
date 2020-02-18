//
//  MemoListController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/17.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class MemoListController: UITableViewController {
    
    /*
        메모 구현 순서
     1. 스토리보드에서 테이블뷰컨트롤러 생성 후 스타일 지정
     2. table cell의 아이덴티티 지정
     3. coredata를 사용하는 메모 데이터 전달 파일 생성(memodata.swift)
     4. tableview count와 cellforrowat에서 메모 데이터 클래스 관련 코딩
     5. outlet, action 설정 등 코딩
     6. 날짜 설정 등 데이터 보여주는 부분 코딩
     
     ------ 여기까지 하고 메모 뷰 보여주는 화면 생성
     
     ------ 다시 메모 리스트
     7. segue를 통해 데이터 전달할 수 있는 prepare 메서드 생성
     8. fetchmemo를 호출하고 목록을 업데이트 해주는 viewwillapper 메서드 생성(ios 12 이전)
     9. ios 13 이후 부터는 notificationcenter를 통해 호출해줘야함(옵저버 생성 하기전 제거를 꼭 해줘야함)
     
     ----- 메모 등록화면 생성(메모 등록 기능까지 완성)
     
     ----- 다시 메모 리스트
     10. notification으로 메모 등록을 알리고, 리스트를 새로고침함
     
     ----- 메모 상세보기 화면 생성
     
     
     */
    
    // 원하는 날짜 출력(6)
    let formatter : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "ko_kr")
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 메모 등록 시 list에서 바로 보여주기 위한 notificationcenter 객체에 옵저버 추가
        token = NotificationCenter.default.addObserver(forName: MemoFormController.newMemoDidInsert, object: nil, queue: OperationQueue.main){
            [weak self] (noti) in self?.tableView.reloadData()
        }
    }
    
    // table row 설정(4)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemoData.shared.memoList.count
    }
    
    // table 데이터 설정(4)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)    // 아이덴티티 설정(2)
        let target = MemoData.shared.memoList[indexPath.row]
        cell.textLabel?.text = target.title
        cell.detailTextLabel?.text = formatter.string(for: target.regDate)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // 뷰화면 혹은 폼화면으로 이동 시 데이터를 넘겨주기 위한 prepare 메서드 설정(7)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell){
            if let vc = segue.destination as? MemoViewController{
                vc.memo = MemoData.shared.memoList[indexPath.row]
            }
        }
    }
    
    // 데이터 호출 후 목록 새로고침
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemoData.shared.fetchMemo()
        tableView.reloadData()
    }
    
    // 옵저버 생성 시 제거를 위한 변수 생성
    var token : NSObjectProtocol?
    
    // 소멸자에서 observer 제거
    deinit{
        if let token = token{
            NotificationCenter.default.removeObserver(token)
        }
    }
}
