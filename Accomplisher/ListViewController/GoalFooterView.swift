import UIKit

class GoalFooterView: UICollectionReusableView {
    static var elementKind: String { UICollectionView.elementKindSectionFooter }
    
    static var addGoalButtonClicked: () -> () = {
       
   }
    
    
    private let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .blue
        return container
    }()
    
    private let noGoalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Goal", for: .normal)
        button.tintColor = .red
        button.addTarget(nil, action: #selector(addGoalClicked), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.1 * containerView.bounds.width
    

        noGoalLabel.layer.masksToBounds = true
        noGoalLabel.text = "You haven't added any goals yet\nUse the '+' button to do so!"

    }
    
    private func prepareSubviews() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        containerView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
        
        
        
        containerView.addSubview(noGoalLabel)
        noGoalLabel.translatesAutoresizingMaskIntoConstraints = false
        noGoalLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        noGoalLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        addButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: noGoalLabel.bottomAnchor, constant: 20).isActive = true

        
    }
    
    @objc func addGoalClicked() {
        Self.addGoalButtonClicked()
    }
    
}
