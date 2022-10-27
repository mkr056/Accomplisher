import UIKit
import RealmSwift

class TextFieldContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {

        var text: String? = ""
        var onChange: (String)->Void = { _ in } // holds the behaviour that you'd like to perform when the user edits the text in the text field
        
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }
    }
    
    var hasEdited = false
    let realm = try! Realm()

    let textField = UITextField()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubview(textField, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Name of your goal"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        if hasEdited { return }
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
    }
    
    @objc private func didChange(_ sender: UITextField) { // this method is triggered when the user changes the text in the field
        do {
            try realm.write {
                hasEdited = true
                guard let configuration = configuration as? TextFieldContentView.Configuration else { return }
                configuration.onChange(textField.text ?? "")            }
            
        } catch {
            print("Error updating title textfield text \(error)")
        }
      
    }
}

extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration()
    }
}
