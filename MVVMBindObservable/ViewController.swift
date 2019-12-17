//
//  ViewController.swift
//  MVVMBindObservable
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: BoundTF!
    @IBOutlet weak var user: BoundTF!
    
    var quote = Quote("He who falls and gets back on his feet will fall more often than he who stays down.")
    var namedUser = User(name: Observable("Smart Guy"))

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.bind(to: quote.quotableText)
        user.bind(to: namedUser.name)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.quote.quotableText.value = "But he who doesn't get back on his feet will never know if he could have stood."
        }
    }


}

struct User {
    var name: Observable<String>
}

struct Quote {
    var quotableText: Observable<String>
    init(_ text: String) {
        quotableText = Observable(text)
    }
}

class Observable<Observed_Type> {
    private var observedValue: Observed_Type?
    
    var value: Observed_Type? {
        get {
            return observedValue
        }
        set {
            observedValue = newValue
            valueChanged?(observedValue)
        }
    }
    
    init(_ value: Observed_Type) {
        observedValue = value
    }
    
    var valueChanged: ((Observed_Type?) -> ())?
    
    func bindingChanged(to newValue: Observed_Type) {
        observedValue = newValue
        print("Update to \(newValue)")
    }
}

class BoundTF: UITextField {
    var changedClosure: (()->())?

    // Needed to tie in with UIKit O-C code
    @objc func valueChanged() {
        changedClosure?()
    }

    func bind(to observable: Observable<String>) {
        addTarget(self, action: #selector(BoundTF.valueChanged), for: .editingChanged)

            changedClosure = { [weak self] in
                observable.bindingChanged(to: self?.text ?? "")
            }

            observable.valueChanged = { [weak self] newValue in
                self?.text = newValue
            }
    }
}
