//
//  ViewController.swift
//  ThreeButtons
//
//  Created by Бучевский Андрей on 06.04.2024.
//

import UIKit

class ViewController: UIViewController {

    let topButton: AnimatableButton = {
        let button = AnimatableButton()
        button.setTitle("Moew", for: .normal)
        return button
    }()

    let middleButton: AnimatableButton = {
        let button = AnimatableButton()
        button.setTitle("Moew Moew Moew Moew", for: .normal)
        return button
    }()

    let bottomButton: AnimatableButton = {
        let button = AnimatableButton()
        button.setTitle("Moew Moew", for: .normal)
        return button
    }()

    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topButton, middleButton, bottomButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.leftAnchor.constraint(lessThanOrEqualTo: view.leftAnchor),
            buttonsStackView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor)
        ])

        bottomButton.touchUpAction = { [weak self] in
            self?.presentNewVC()
        }
    }

    private func presentNewVC() {
        let newVC = SomeViewController()
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: { })
    }
}

final class SomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

final class AnimatableButton: UIButton {

    enum AnimationConstants {
        static let tapAnimationDuration = 0.15
        static let tapScale: CGFloat = 0.95
    }

    var touchUpAction: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimation()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentHorizontalAlignment = .center
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.contentInsets = .init(top: 10, leading: 14, bottom: 10, trailing: 14)
        config.image = UIImage(systemName: "arrowshape.right.circle.fill")
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)

        configuration = config
    }

    private func setupAnimation() {
        addTarget(self,
                  action: #selector(downAnimation),
                  for: [.touchDown])
        addTarget(self,
                  action: #selector(upAnimation),
                  for: [.touchDragExit, .touchUpInside, .touchUpOutside, .touchCancel])
        addTarget(self,
                  action: #selector(touchUp),
                  for: .touchUpInside)
    }

    @objc func downAnimation() {
        UIView.animate(withDuration: AnimationConstants.tapAnimationDuration,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseInOut],
                       animations: {
            self.layer.transform = CATransform3DMakeScale(AnimationConstants.tapScale, AnimationConstants.tapScale, 1)
        }, completion: { _ in
            self.upAnimation()
        })
    }

    @objc func upAnimation() {
        if !isTracking && layer.animation(forKey: "transform") == nil {
            UIView.animate(withDuration: AnimationConstants.tapAnimationDuration,
                           delay: 0.0,
                           options: [.allowUserInteraction, .curveEaseInOut],
                           animations: {
                self.layer.transform = CATransform3DIdentity
            })
        }
    }

    @objc func touchUp() {
        touchUpAction?()
    }

    override func tintColorDidChange() {
        switch tintAdjustmentMode {
        case .dimmed:
            var currentConfig = configuration
            currentConfig?.baseBackgroundColor = .systemGray2
            currentConfig?.baseForegroundColor = .systemGray3
            configuration = currentConfig
        case .normal:
            var currentConfig = configuration
            currentConfig?.baseBackgroundColor = .systemBlue
            currentConfig?.baseForegroundColor = .white
            configuration = currentConfig
        default:
            break
        }
    }
}
