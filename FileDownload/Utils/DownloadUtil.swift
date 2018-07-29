//
//  ViewController.swift
//  FileDownload
//
//  Created by Maharani on 18/06/18.
//  Copyright © 2018 Maharani. All rights reserved.
//

import Foundation
import UIKit

class DownloadUtil : NSObject, URLSessionDelegate, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate  {
    static var shared = DownloadUtil()
    typealias Progress = (Float) -> ()
    var progressIndicator :Progress? {
        didSet {
            if progressIndicator != nil {
                let _ = activate()
            }
        }
    }

    override private init() {
        super.init()
    }

   //Creates only one session.
    func activate() -> URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }

    private func calculateProgress(session : URLSession, completionHandler : @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            print("downloads",downloads,uploads,tasks)
            let progress = downloads.map({ (task) -> Float in
                
                if task.countOfBytesExpectedToReceive > 0 {
                    print("progress",Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive))
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            print("progressprogress",progress.reduce(0.0, +))
            completionHandler(progress.reduce(0.0, +))
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            if let progressStatus = progressIndicator {
                calculateProgress(session: session, completionHandler: progressStatus)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/DownloadedFile.pdf"))
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            filePath(path: destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                filePath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file")
            }
        }
       print("Download Completed: \(destinationURLForFile)")
       try? FileManager.default.removeItem(at: location)
    }

    func filePath(path: String){
        let isFile:Bool? = FileManager.default.fileExists(atPath: path)
        if isFile == true{
            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreview(animated: true)
        }
    }
   
    
}

