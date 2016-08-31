//
//  ViewController.swift
//  URLSessionDownloadContinuing
//
//  Created by  椒徒科技 on 16/7/20.
//  Copyright © 2016年 jiaotukeji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //下载进度
    @IBOutlet weak var progressVeiw: UIProgressView!

    // 全局网络会话 - 管理所有的网络请求
    lazy var Session :NSURLSession = {
    
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let sessiontem = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return sessiontem
    }()
    // 下载任务
    var downloadTask  : NSURLSessionDownloadTask!
    //续传数据就
    var reusmeData:NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }
    

    //开始
    @IBAction func startClick(sender: AnyObject) {
        
        
        let url = NSURL(string: "http://localhost:8080/123.mp4")
          downloadTask = Session.downloadTaskWithURL(url!)
          downloadTask.resume()
    }
    //暂停
    @IBAction func pasueClick(sender: AnyObject) {
        
        //防止在此被暂停
        if downloadTask == nil {
            print("不需要暂停下载任务")
            return
       }
        
        downloadTask.cancelByProducingResumeData { (data:NSData?) in
            
            // 保存续传数据
            self.reusmeData = data!
            //释放下载任务 防止在次暂停
            self.downloadTask = nil
            
        }
        
        
    }
    
    //继续下载
    @IBAction func resumeClick(sender: AnyObject) {
        
        //防止下载任务被重复创建
        if reusmeData == nil {
            print("没有续传数据")
            return
        }
         // 使用续传数据创建下载任务 － 一旦使用续传数据新建了下载任务，续传就没用了！
        downloadTask = Session.downloadTaskWithResumeData(reusmeData)
        downloadTask.resume()
        
        //释放续传数据
        reusmeData = nil
    }
    
    deinit{
    
        print("我走啦")
    }
}

extension ViewController:NSURLSessionDownloadDelegate{

    
    // 下载完成 iOS 8.0以后 必须实现
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
        //下载完成 location,文件保存地址
        //在此代理方法完成之后,下载的文件会删除,需要立即保存
        print(location.path!)
        //拷贝文件到cache
        var  filePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as NSString
        filePath = filePath.stringByAppendingPathComponent("hello.mp4")
        
        let fileMan = NSFileManager.defaultManager()
        do{
            try fileMan.copyItemAtPath(location.path!, toPath: filePath as String)
        }catch{}
  
    
        // 取消session 如果不取消session会造成内存泄漏
          self.Session.finishTasksAndInvalidate()
    }
    // 进度的方法，iOS 7.0 必须实现，在 iOS 8.0以后 可选
    /**
     bytesWritten               本次下载字节数
     totalBytesWritten          已经下载字节数
     totalBytesExpectedToWrite  总下载字节数
     */
     internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        
        print(progress)
        dispatch_async(dispatch_get_main_queue()) {
            
            self.progressVeiw.progress = progress
        }
    }
    
    
    // 续传的方法，iOS 7.0 必须实现，在 iOS 8.0 以后可选
     internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        
           print(#function)
    }

}