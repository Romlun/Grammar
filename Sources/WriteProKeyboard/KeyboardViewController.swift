import UIKit

class KeyboardViewController: UIInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 240)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        let label = UILabel()
        label.text = "WritePro keyboard — Phase 1"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let nextButton = UIButton(type: .system)
        nextButton.setTitle("🌐 Switch keyboard", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self,
                             action: #selector(handleInputModeList(from:with:)),
                             for: .allTouchEvents)

        let typeButton = UIButton(type: .system)
        typeButton.setTitle("Type "hi" (test)", for: .normal)
        typeButton.translatesAutoresizingMaskIntoConstraints = false
        typeButton.addTarget(self, action: #selector(insertTest), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(nextButton)
        view.addSubview(typeButton)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            typeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.topAnchor.constraint(equalTo: typeButton.bottomAnchor, constant: 20),
        ])
    }

    @objc private func insertTest() {
        textDocumentProxy.insertText("hi")
    }
}
