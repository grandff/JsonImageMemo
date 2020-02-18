//
//  ImageDownloadController.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/16.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class ImageDownloadController: UIViewController,URLSessionDownloadDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var menuBar: UIBarButtonItem!
    
    
    var downloadTask : URLSessionDownloadTask!  // 다운로드 작업객체
    
    // 다운로드 완료시. URLSessionDownloadDelegate를 위한 필수.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let dataTemp : Data =  try! Data(contentsOf: location)  // data 가 받아졌는지 try로 확인
        self.imgView.image = UIImage(data: dataTemp)    // 받아온 파일을 바로 이미지뷰에 보여줌
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        downloadLabel.text = "Download Complete!"
    }
    
    // 다운로드 중 프로그레스바 설정
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress : Float = Float(totalBytesWritten / totalBytesExpectedToWrite)
        progressView.setProgress(progress, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()     
    }
    
    // URL 직접 호출 다운로드 방법
    @IBAction func downloadAction1(_ sender: Any) {
        imgView.image = nil
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        downloadLabel.text = "Downloading.."
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = session.downloadTask(with: URL(string : "https://raw.githubusercontent.com/ChoiJinYoung/iphonewithswift2/master/sample.jpeg")!)
        downloadTask.resume()
    }
    
    // closure block을 사용해서 다운로드 방법
    @IBAction func downloadAction2(_ sender: Any) {
        imgView.image = nil
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        downloadLabel.text = "Downloading.."
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        downloadTask = session.downloadTask(with: URL(string : "https://raw.githubusercontent.com/ChoiJinYoung/iphonewithswift2/master/sample.jpeg")!, completionHandler: {(data, response, error) -> Void in
            let dataTemp:Data = try! Data(contentsOf: data!)
            self.imgView.image = UIImage(data: dataTemp)
            self.indicatorView.isHidden = true
            self.indicatorView.stopAnimating()
            self.downloadLabel.text = "Download Complete!"
        })
        downloadTask.resume()
    }
     
    // 다운로드 일시 중지
    @IBAction func suspendAction(_ sender: Any) {
        downloadTask.suspend()
        downloadLabel.text = "Download Suspend"
    }
    
    // 다운로드 취소
    @IBAction func cancelAction(_ sender: Any) {
        downloadTask.cancel()
        downloadLabel.text = "Download Cancel"
        imgView.image = nil
       progressView.setProgress(0.0, animated: false)
       indicatorView.isHidden = true
       indicatorView.stopAnimating()
    }
    
    // 다운로드 계속
    @IBAction func resumeAction(_ sender: Any) {
        downloadTask.resume()
        downloadLabel.text = "Download Resume"
    }
}
