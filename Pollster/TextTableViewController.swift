//
//  TextTableViewController.swift
//  Pollster
//
//  Created by Owner on 1/12/17.
//  Copyright © 2017 Owner. All rights reserved.
//

import UIKit

class TextTableViewController: UITableViewController, UITextViewDelegate
{
    // MARK: Public API
    
    // outer Array is the sections
    // inner Array is the data in each row
    var data: [Array<String>]? {
        didSet {
            if oldValue == nil || data == nil {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: Text View Handling
    
    // this can be overridden to customize the look of the UITextViews
    func createTextViewForIndexPath(indexPath: IndexPath?) -> UITextView {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.isScrollEnabled = true
        textView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        textView.isOpaque = false
        textView.backgroundColor = UIColor.clear
        return textView
    }
    
    private func cellForTextView(textView: UITextView) -> UITableViewCell? {
        var view = textView.superview
        while (view != nil) && !(view! is UITableViewCell) { view = view!.superview }
        return view as? UITableViewCell
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?[section].count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let textView = createTextViewForIndexPath(indexPath: indexPath)
        textView.frame = cell.contentView.bounds
        textViewWidth = textView.frame.size.width
        textView.text = data?[indexPath.section][indexPath.row]
        textView.delegate = self
        cell.contentView.addSubview(textView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if data != nil {
            data![destinationIndexPath.section].insert(data![sourceIndexPath.section][sourceIndexPath.row], at: destinationIndexPath.row)
            let fromRow = sourceIndexPath.row + ((destinationIndexPath.row < sourceIndexPath.row) ? 1 : 0)
            data![sourceIndexPath.section].remove(at: fromRow)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            data?[indexPath.section].remove(at: indexPath.row)
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAtIndexPath(indexPath: indexPath)
    }
    
    private var textViewWidth: CGFloat?
    private lazy var sizingTextView: UITextView = self.createTextViewForIndexPath(indexPath: nil)
    
    private func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat {
        if indexPath.section < (data?.count)! && indexPath.row < (data?[indexPath.section].count)! {
            if let contents = data?[indexPath.section][indexPath.row] {
                if let textView = visibleTextViewWithContents(contents: contents) {
                    return textView.sizeThatFits(CGSize(width: textView.bounds.size.width, height: tableView.bounds.size.height)).height + 1.0
                } else {
                    let width = textViewWidth ?? tableView.bounds.size.width
                    sizingTextView.text = contents
                    return sizingTextView.sizeThatFits(CGSize(width: width, height: tableView.bounds.size.height)).height + 1.0
                }
            }
        }
        return UITableViewAutomaticDimension
    }
    
    private func visibleTextViewWithContents(contents: String) -> UITextView? {
        for cell in tableView.visibleCells {
            for subview in cell.contentView.subviews {
                if let textView = subview as? UITextView, textView.text == contents {
                    return textView
                }
            }
        }
        return nil
    }
    
    // MARK: UITextViewDelegate
    

    func textViewDidChange(_ textView: UITextView) {
        if let cell = cellForTextView(textView: textView), let indexPath = tableView.indexPath(for: cell) {
            data?[indexPath.section][indexPath.row] = textView.text
        }
        updateRowHeights()
        let editingRect = textView.convert(textView.bounds, to: tableView)
        if !tableView.bounds.contains(editingRect) {
            // should actually scroll to be clear of keyboard too
            // but for now at least scroll to visible ...
            tableView.scrollRectToVisible(editingRect, animated: true)
        }
        textView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet.newlines) != nil {
            returnKeyPressed(inTextView: textView)
            return false
        } else {
            return true
        }
    }
    
    func returnKeyPressed(inTextView textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @objc private func updateRowHeights() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: Content Size Category Change Notifications
    
    private var contentSizeObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIContentSizeCategoryDidChange,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            // give all the UITextViews a chance to react, then resize our row heights
//            Timer.scheduledTimerWithTimeInterval(timeInterval: 0.1, target: self, selector: #selector(self.updateRowHeights), userInfo: nil, repeats: false)
        }
    }
    
    deinit {
        if contentSizeObserver != nil {
            NotificationCenter.default.removeObserver(observer: contentSizeObserver!)
            contentSizeObserver = nil
        }
    }
}
