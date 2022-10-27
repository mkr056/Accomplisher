import UIKit




protocol AddNewQuoteDelegate {
    func addQuote(quote: String)
    func editExistingQuote(old: String, new: String)

}




class NewQuoteViewController: UIViewController, UITextViewDelegate {
    
    var delegate: AddNewQuoteDelegate?
    
    var quoteToEdit: Quote?
    
    static var removeQuote: () -> () = {
       
   }
    
    
    let textView = UITextView()
    var charCounter: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = "0/100"
        return label
    }()
    
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(promptForConfirmation), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    
    @objc func promptForConfirmation() {
        let ac = UIAlertController(title: "Delete note?", message: "Are you sure that you want to delete this note?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteQuote(alert:)))
        present(ac, animated: true)
    }

    
    @objc private func deleteQuote(alert: UIAlertAction) {
        Self.removeQuote()
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveQuote))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        
        textView.center = self.view.center
        textView.textAlignment = NSTextAlignment.justified
        textView.backgroundColor = UIColor.lightGray
        textView.textAlignment = .center

        view.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        self.textView.delegate = self

        view.addSubview(charCounter)
        charCounter.translatesAutoresizingMaskIntoConstraints = false
        charCounter.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -15).isActive = true
        charCounter.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -15).isActive = true
        
        
        
        if let quoteToEdit = quoteToEdit {
            textView.text = quoteToEdit.quoteText
            charCounter.text = "\(textView.text.count)/100"
            deleteButton.isHidden = false
        }
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        view.addSubview(deleteButton)
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20).isActive = true
        checkIfEmpty()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charCounter.text = "\(textView.text.count)/100"
        checkIfEmpty()
        

        
    }
    
    func checkIfEmpty() {

        (textView.text.isEmpty) ? (self.navigationItem.rightBarButtonItem = nil) : (self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveQuote)))
    }
    
   
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 100
    }

    
    @objc func saveQuote() {
        textView.resignFirstResponder()
        let newQuote = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if quoteToEdit != nil {
            delegate?.editExistingQuote(old: quoteToEdit!.quoteText, new: newQuote)
        } else {
            delegate?.addQuote(quote: newQuote)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if textView.text.isEmpty {
            deleteQuote(alert: UIAlertAction())
        }
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
//        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//      let keyboardScreenEndFrame = keyboardValue.cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//        if notification.name == UIResponder.keyboardWillHideNotification {
//            textView.contentInset = .zero
//        } else {
//            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
//        }
//        textView.scrollIndicatorInsets = textView.contentInset
//        let selectedRange = textView.selectedRange
//        textView.scrollRangeToVisible(selectedRange)
    }
    
}


