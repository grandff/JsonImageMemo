//
//  Memo.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/16.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import CoreData

/*
    coredata 구축 순서
 1. coredata entity 및 attribute 생성
 2. 앱 모델 계층을 공동으로 지원하는 클래스 생성(memodata.swift)
 --> 이때 entity의 이름과 겹치면 안됨
 3. 여러 패턴중 싱글톤 패턴으로 생성
 4. 4가지의 인스턴스가 있는데 여긴 NSPersistentContainer 인스턴스를 만듬. 이건 모델, 컨텍스트 및 스토어 코디네이터를 한번에 설정해주는 특징이 있음.
 5. lazy var 를 통해 container 객체 생성. 이 컨테이너는 managedObjectModel, viewContext 및 persistentStoreCoordinator 속성에 대한 인스턴스 참조를 보관함.
 --> lazy는 처음 사용되기 전까진 로드되지 않다가 사용할때 서버로부터 로드해주는 역할을 함. var 와 꼭 같이 써야함
 6. coredata를 저장해주는 saveContext 객체 생성
 7. context 객체 생성
 8. scenedelegate에서 에러가 발생하면 이미 만들어준 saveContext를 사용해도 됨
 9. 메모를 저장할 배열 생성
 10. 데이터베이스에서 데이터를 읽어들이는 메서드 생성(ios는 보통 fetch라고 함)
 11. 데이터베이스에 메모를 저장해주는 메서드 생성
 12. 데이터베이스에 메모를 수정해주는 메서드 생성
 13. 데이터베이스에 메모를 삭제해주는 메서드 생성
 */

// 2
class MemoData{
    // 싱글톤 패턴 사용(3)
    static let shared = MemoData()  // 공유 인스턴스 저장
    private init(){}
    
    // core data stack(4,5)
    lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JsonImageMemo")
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Error 발생 :: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // core data saving(6)
    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                try context.save()
            } catch{
                let nserror = error as NSError
                fatalError("saving error :: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // context 객체 생성(7)
    var mainContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // coredata를 받을 array 객체 생성(9)
    var memoList = [Memo]()
    
    // fetch 메서드(10)
    func fetchMemo(){
        let request : NSFetchRequest<Memo> = Memo.fetchRequest()        // 데이터베이스에서 읽기 위한 fetchrequest
        let sortByDateDesc = NSSortDescriptor(key: "regDate", ascending: false)     // coredata는 정렬이 안되어있기 때문에 정렬을 해줘야함
        request.sortDescriptors = [sortByDateDesc]  // 등록 날짜 기준으로 내림차순 정렬
        
        do{
            memoList = try mainContext.fetch(request)
        }catch{
            print(error)
        }
    }
    
    // 데이터 저장(11)(12)
    func addNewMemo(_ memo : String?, _ title : String?){
        let newMemo = Memo(context: mainContext)
        newMemo.title = title
        newMemo.content = memo
        newMemo.regDate = Date()
        
        memoList.insert(newMemo, at: 0) // 메모 추가하고 리스트에 넣어야 리스트에 바로 보임
        
        saveContext()
    }
    
    // 데이터 삭제(13)
    func deleteMemo(_ memo : Memo?){
        if let memo = memo{
            mainContext.delete(memo)
            saveContext()
        }
    }
    
}
