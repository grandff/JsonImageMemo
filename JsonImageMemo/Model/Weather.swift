//
//  Weather.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/16.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
/*
 https://app.quicktype.io/ 참조하기 -> json으로 처리할떄 구조체 자동으로 만들어줌
 
 */
// MARK: - Weather
struct Weather: Codable {
    let response: Response
}

// MARK: - Response
struct Response: Codable {
    let header: Header
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let dataType: String
    let items: Items
    let pageNo, numOfRows, totalCount: Int
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]
}

// MARK: - Item
struct Item: Codable {
    let baseDate, baseTime, category, fcstDate: String
    let fcstTime, fcstValue: String
    let nx, ny: Int
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}
