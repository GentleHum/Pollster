//
//  CloudQandAViewController.swift
//  Pollster
//
//  Created by Owner on 1/12/17.
//  Copyright © 2017 Owner. All rights reserved.
//

import UIKit
import CloudKit

class CloudQandAViewController: QandATableViewController {
    
    var ckQandARecord: CKRecord {
        get {
            if _ckQandARecord == nil {
                _ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
            }
            return _ckQandARecord!
        }
        set {
            _ckQandARecord = newValue
        }

    }
    
    private var _ckQandARecord: CKRecord? {
        didSet {
            let question = ckQandARecord[Cloud.Attribute.Question] as? String ?? ""
            let answers = ckQandARecord[Cloud.Attribute.Answers] as? [String] ?? []
            qanda = QandA(question: question, answers: answers)
            asking = ckQandARecord.wasCreatedByThisUser
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
    }
    
    
}
