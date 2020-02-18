//
//  WeatherController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/16.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class WeatherController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTableView: UITableView!
    var dataList = [String]()
    var dataList1 = [String]()
    var areaList = ["서울특별시" : "60,127", "부산광역시" : "98,76" , "대구광역시" : "89,90",
                    "인천광역시" : "55,124", "광주광역시" : "60,74" , "대전광역시" : "67,100",
                    "울산광역시" : "102,84", "세종특별시" : "66,103", "경기도"    : "60,120",
                    "충청북도" : "69,107", "충청남도" : "68,100" , "전라북도" : "63,89",
                    "전라남도" : "51,67", "경상북도" : "89,91", "경상남도" : "91,77",
                    "제주도" : "52,38"]
    var xyList = [String]()
    var formatter = DateFormatter()
    var nowDate : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callApi()
    }
    // 날씨 api 호출
    func callApi(){
        // 전송파라미터
        var jsonURL : String = ""
        var param : String = ""
        let serviceKey = "yXugn7gIb5dEF5jMX1UjuV4qiy%2Bczf9hX3GZhu%2Fp3kxVI9JbMCvBGPHpKVp5QkAOllYDPlfSnSw0CDX7ZGGYsg%3D%3D"
        let apiURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService/getVilageFcst"
        formatter.dateFormat = "yyyyMMdd"
        nowDate = formatter.string(from: Date())
        
        
        // 지역반복
        for area in areaList{
            param = "?serviceKey=\(serviceKey)&base_date=\(nowDate)&base_time=0800&dataType=JSON&nx=\(area.value.split(separator: ",")[0])&ny=\(area.value.split(separator: ",")[1])"
            xyList.append("\(area.key)")
            jsonURL = apiURL + param
            guard let callURL = URL(string: jsonURL) else{return}
            
            URLSession.shared.dataTask(with: callURL, completionHandler: {(data, response, error) -> Void in
                guard let data = data else {return}
                
                do{
                    let jsonData = try JSONDecoder().decode(Weather.self, from: data)
                    let t3h = jsonData.response.body.items.item[6].fcstValue   // 3시간 기온값만 가져옴
                    let pty = jsonData.response.body.items.item[1].fcstValue   // 강수형태
                    
                    self.dataList.append("\(t3h)")
                    self.dataList1.append("\((pty))")
                                        
                    DispatchQueue.main.async {
                        self.mainTableView.reloadData()
                    }
                }catch{
                    print("fucking error \(error)")
                }
            }).resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WeatherCell
                
        let areaStr = xyList[indexPath.row]
        let weatherStr = dataList1[indexPath.row]
        let tempraStr = dataList[indexPath.row]
        
        cell.tempratureLabel.text = tempraStr
        cell.weatherLabel.text = weatherStr
        cell.areaLabel.text = areaStr
        
        return cell
    }
}
