import UIKit

/// M0 "hello keyboard": gõ được chữ "a", xoá, xuống dòng, chuyển bàn phím,
/// và hiện kết quả kiểm tra App Group (xem Log/AppGroupProbe.swift).
class KeyboardViewController: UIInputViewController {

    private let statusLabel = UILabel()
    private var globeButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        refreshProbe()
    }

    override func viewWillLayoutSubviews() {
        // Chỉ hiện 🌐 khi iOS yêu cầu (máy Face ID đã có nút 🌐 của hệ thống).
        globeButton?.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    // MARK: - UI

    private func setUpViews() {
        statusLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .secondaryLabel

        let keys = UIStackView(arrangedSubviews: [
            makeKey("🌐", action: nil),
            makeKey("a", action: #selector(typeA)),
            makeKey("⌫", action: #selector(deleteBackward)),
            makeKey("⏎", action: #selector(insertNewline)),
            makeKey("Test", action: #selector(refreshProbe)),
        ])
        keys.axis = .horizontal
        keys.spacing = 6
        keys.distribution = .fillEqually

        let root = UIStackView(arrangedSubviews: [statusLabel, keys])
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            keys.heightAnchor.constraint(equalToConstant: 46),
            view.heightAnchor.constraint(equalToConstant: 200),
        ])
    }

    private func makeKey(_ title: String, action: Selector?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 6
        if let action {
            button.addTarget(self, action: action, for: .touchUpInside)
        } else {
            // API chuẩn của Apple để mở danh sách bàn phím.
            button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            globeButton = button
        }
        return button
    }

    // MARK: - Actions

    @objc private func typeA() { textDocumentProxy.insertText("a") }
    @objc private func deleteBackward() { textDocumentProxy.deleteBackward() }
    @objc private func insertNewline() { textDocumentProxy.insertText("\n") }

    @objc private func refreshProbe() {
        let r = AppGroupProbe.run()
        statusLabel.text = """
        Kyx M0 · Full Access: \(hasFullAccess ? "ON" : "OFF")
        container: \(r.containerFound ? "found" : "MISSING")
        host.ping: \(r.hostPing ?? "(none)")
        file write: \(r.fileWrite) · defaults write: \(r.defaultsWrite)
        """
    }
}
