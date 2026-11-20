import AudioToolbox
import UIKit

/// Điểm vào của bàn phím Kyx. Phần vẽ và chạm nằm trong KeyboardView,
/// phần sửa văn bản (Telex, trackpad, xoá theo từ) nằm trong Input/TextActions.swift.
final class KeyboardViewController: UIInputViewController {
    let keyboard = KeyboardView()
    var settings = KyxSettings()
    var stats = KeystrokeStats()
    private var heightConstraint: NSLayoutConstraint?
    private lazy var haptic = UIImpactFeedbackGenerator(style: .light)

    private let langKey = "kyx.lastLang"
    private let seenDefaultKey = "kyx.seenDefaultLang"

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboard.delegate = self
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboard)
        let height = view.heightAnchor.constraint(equalToConstant: keyboard.preferredHeight)
        height.priority = UILayoutPriority(999)
        heightConstraint = height
        NSLayoutConstraint.activate([
            keyboard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboard.topAnchor.constraint(equalTo: view.topAnchor),
            keyboard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            height,
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSettings()
        stats = KeystrokeStats()
        keyboardDidFinishEdit()
        KeyboardLog.write(String(format: "open fullAccess=%@ mem=%.1fMB", hasFullAccess ? "on" : "off", KeyboardLog.memoryMB()))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardLog.write(String(format: "close %@ mem=%.1fMB", stats.summary, KeyboardLog.memoryMB()))
    }

    override func viewWillLayoutSubviews() {
        keyboard.showsGlobe = needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        applyTheme()
        keyboardDidFinishEdit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        KeyboardLog.write(String(format: "MEMORY WARNING mem=%.1fMB", KeyboardLog.memoryMB()))
    }

    // MARK: - Cài đặt

    private func reloadSettings() {
        settings = KyxSettings.load()
        keyboard.keyHeight = (46 * settings.height).rounded()
        heightConstraint?.constant = keyboard.preferredHeight

        // Ngôn ngữ: giữ lựa chọn lần trước; nếu người dùng vừa đổi "ngôn ngữ mặc định" thì theo cài đặt.
        let local = UserDefaults.standard
        if local.string(forKey: seenDefaultKey) != settings.defaultLang {
            local.set(settings.defaultLang, forKey: seenDefaultKey)
            local.set(settings.defaultLang, forKey: langKey)
        }
        keyboard.language = local.string(forKey: langKey) ?? settings.defaultLang
        applyTheme()
    }

    private func applyTheme() {
        let dark: Bool
        switch settings.theme {
        case "dark": dark = true
        case "light": dark = false
        default: dark = textDocumentProxy.keyboardAppearance == .dark || traitCollection.userInterfaceStyle == .dark
        }
        keyboard.palette = dark ? .dark : .light
    }
}

// MARK: - KeyboardViewDelegate

extension KeyboardViewController: KeyboardViewDelegate {
    func keyboardFeedback() {
        if settings.click {
            if hasFullAccess { AudioServicesPlaySystemSound(1104) } else { UIDevice.current.playInputClick() }
        }
        if settings.haptic && hasFullAccess { haptic.impactOccurred() }
    }

    func keyboardToggleLanguage() {
        keyboard.language = keyboard.language == "VI" ? "EN" : "VI"
        UserDefaults.standard.set(keyboard.language, forKey: langKey)
    }

    func keyboardGlobe(from view: UIView, with event: UIEvent?) {
        guard let event else { return }
        handleInputModeList(from: view, with: event)
    }

    func keyboardDidFinishEdit() {
        guard settings.autocap, keyboard.page == .letters, keyboard.shift != .lock else { return }
        if textDocumentProxy.autocapitalizationType == UITextAutocapitalizationType.none {
            if keyboard.shift == .once { keyboard.shift = .off }
            return
        }
        keyboard.shift = shouldCapitalize() ? .once : .off
    }
}
