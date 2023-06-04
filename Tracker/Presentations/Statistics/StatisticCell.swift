import UIKit

final class StatisticCell: UITableViewCell {
    
    //MARK: - Properties
    private let gradientBorderView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.bigRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.bigRadius - 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ypFontBold34
        label.textColor = .ypBlack
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ypFontMedium12
        label.textColor = .ypBlack
        return label
    }()
    
    private var gradientLayer = CAGradientLayer()
    
    //MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.removeFromSuperlayer()

        DispatchQueue.main.async {
            self.gradientLayer = self.createGradientBorder()
            self.gradientBorderView.layer.insertSublayer(self.gradientLayer, at: 0)
        }
    }
    
    //MARK: - Helpers
    func configureCell( _ title: String, _ subtitle: String) {
        backgroundColor = .clear
        selectionStyle = .none
                        
        addElements()
        setupConstraints()
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    private func addElements() {
        contentView.addSubview(gradientBorderView)
        gradientBorderView.addSubview(mainView)
        mainView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            gradientBorderView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            gradientBorderView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            gradientBorderView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            gradientBorderView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -12
            ),
            
            mainView.leadingAnchor.constraint(
                equalTo: gradientBorderView.leadingAnchor, constant: 1
            ),
            mainView.topAnchor.constraint(
                equalTo: gradientBorderView.topAnchor, constant: 1
            ),
            mainView.trailingAnchor.constraint(
                equalTo: gradientBorderView.trailingAnchor, constant: -1
            ),
            mainView.bottomAnchor.constraint(
                equalTo: gradientBorderView.bottomAnchor, constant: -1
            ),
            
            stackView.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: 11
            ),
            stackView.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor, constant: 11
            ),
            stackView.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -11
            ),
            stackView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant: -11
            ),
        ])
    }
    
    private func createGradientBorder() -> CAGradientLayer {
        let red = UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1)
        let green = UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1)
        let blue = UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientBorderView.bounds
        gradientLayer.colors = [blue.cgColor, green.cgColor, red.cgColor]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        return gradientLayer
    }
}
