//
//  ViewController.swift
//  Creatiwity
//
//  Created by Arthur Kleiber on 08/03/2018.
//  Copyright © 2018 Arthur Kleiber. All rights reserved.
//

import UIKit
import WebKit

extension UIViewController {
    func showInputDialog(title: String? = nil, subtitle:String? = nil, actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel", inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        self.present(alert, animated: true, completion: nil)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var webViewPage: WKWebView!
    @IBOutlet weak var labelTextPage: UILabel!
    var book = [Page]() // Array of page
    var index = 0
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTextPage.isHidden = true
        self.webViewPage.isHidden = true
        self.labelTextPage.numberOfLines = 0
        
        if let decoded = userDefaults.object(forKey: "creatiwityDynamicBook") as? Data {
            if let decodedBook = NSKeyedUnarchiver.unarchiveObject(with: decoded) {
                self.book = decodedBook as! [Page]
                if (self.book.count > 0) {
                    showPage(index: 0)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     ** Data persist
     */
    func pushData(book: [Page]) {
        let encodedBook: Data = NSKeyedArchiver.archivedData(withRootObject: book)
        self.userDefaults.set(encodedBook, forKey: "creatiwityDynamicBook")
        self.userDefaults.synchronize()
    }
    
    /*
    ** Add a page
    ** and Show page added
    */
    @IBAction func addPage(_ sender: Any) {
        showInputDialog(title: "Add page", subtitle: "Write text or paste URL", actionTitle: "Add",
                        cancelTitle: "Cancel", inputPlaceholder: "Text or URL", inputKeyboardType: .default) { (input: String?) in
                            guard let text = input, !text.isEmpty else {
                                return
                            }
                            let page = Page(string: text)
                            self.book.append(page)
                            if (self.book.count == 1) {
                                self.showPage(index: self.index)
                            }
                            else {
                                self.index += 1
                                self.showPage(index: self.index)
                            }
                            self.pushData(book: self.book)
        }
    }
    
    /*
    ** To remove a page
    */
    @IBAction func removePage(_ sender: Any) {
        if (self.index >= 0 && self.book.count > 0) {
            self.book.remove(at: self.index)
            self.pushData(book: self.book)
            if (self.index > 0) {
                self.index -= 1;
            }
            
        }
        if (self.book.count > 0) {
            showPage(index: self.index)
        }
        else {
            self.labelTextPage.isHidden = true
            self.webViewPage.isHidden = true
        }
    }
    
    func verifyUrl(urlString: String!) -> Bool {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        return false
    }
    
    func showPage(index: Int) {
        if (verifyUrl(urlString: self.book[index].text)) {
            let url: URL = URL(string: self.book[index].text!)!
            let urlRequest: URLRequest = URLRequest(url: url)
            self.webViewPage.load(urlRequest)
            self.webViewPage.isHidden = false
            self.labelTextPage.isHidden = false
        }
        else {
            self.labelTextPage.isHidden = false
            self.webViewPage.isHidden = true
            self.labelTextPage.text = self.book[index].text
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        if (self.index < self.book.count - 1) {
            self.index += 1;
            showPage(index: self.index);
        }
    }
    
    @IBAction func prevPage(_ sender: Any) {
        if (self.index > 0) {
            self.index -= 1;
            showPage(index: self.index);
        }
    }
}

