//
//  ViewController.swift
//  FileDownload
//
//  Created by Maharani on 18/06/18.
//  Copyright © 2018 Maharani. All rights reserved.
//

import UIKit

class ViewController: UIViewController{



    @IBOutlet weak var urlTxt: UITextField!
    @IBOutlet weak var downloadFile: UIButton!
        @IBOutlet weak var downloadProgress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = DownloadUtil.shared.activate()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DownloadUtil.shared.progressIndicator = { (progress) in
            OperationQueue.main.addOperation {
                self.downloadProgress.progress = progress
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DownloadUtil.shared.progressIndicator = nil
    }
    
    @IBAction func dowloadAction(_ sender: Any) {
        let url = URL(string: urlTxt.text!)!
        let task = DownloadUtil.shared.activate().downloadTask(with: url)
        task.resume()
       
    }
    
}

