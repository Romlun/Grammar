import UIKit

class KeyboardViewController: UIInputViewController {

    // MARK: - State
    enum ShiftState { case off, on, locked }
    private var shiftState: ShiftState = .on
    private var lastShiftTap = Date.distantPast
    private var deleteTimer: Timer?

    // MARK: - Colors
    private let kKeyBg    = UIColor.white
    private let kActionBg = UIColor(red: 172/255, green: 178/255, blue: 190/255, alpha: 1)
    private let kBoardBg  = UIColor(red: 209/255, green: 212/255, blue: 219/255, alpha: 1)
    private let kPurple   = UIColor(red: 124/255, green: 58/255, blue: 237/255, alpha: 1)

    // MARK: - Refs
    private var shiftKey: UIButton!
    private var lettersPane: UIView!
    private var numbersPane: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kBoardBg

        let h = view.heightAnchor.constraint(equalToConstant: 298)
        h.priority = .defaultHigh
        h.isActive = true

        let outer = vstk(0)
        outer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: view.topAnchor),
            outer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            outer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        outer.addArrangedSubview(buildBar())

        let container = UIView()
        container.backgroundColor = .clear

        let lp = buildLettersPane()
        let np = buildNumbersPane()
        np.isHidden = true
        lettersPane = lp
        numbersPane = np

        [lp, np].forEach { pane in
            pane.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(pane)
            NSLayoutConstraint.activate([
                pane.topAnchor.constraint(equalTo: container.topAnchor),
                pane.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                pane.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                pane.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
        }
        outer.addArrangedSubview(container)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshShift()
    }

    // MARK: - Bar

    private func buildBar() -> UIView {
        let v = UIView()
        v.backgroundColor = kBoardBg
        v.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let sep = UIView()
        sep.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        sep.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(sep)

        let label = UILabel()
        label.text = "WritePro"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = kPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)

        let improveBtn = UIButton(type: .system)
        improveBtn.setTitle("Improve", for: .normal)
        improveBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        improveBtn.setTitleColor(.white, for: .normal)
        improveBtn.backgroundColor = kPurple
        improveBtn.layer.cornerRadius = 7
        improveBtn.translatesAutoresizingMaskIntoConstraints = false
        improveBtn.addTarget(self, action: #selector(improveTapped), for: .touchUpInside)
        v.addSubview(improveBtn)

        NSLayoutConstraint.activate([
            sep.topAnchor.constraint(equalTo: v.topAnchor),
            sep.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            improveBtn.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -10),
            improveBtn.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            improveBtn.heightAnchor.constraint(equalToConstant: 30),
            improveBtn.widthAnchor.constraint(equalToConstant: 84),
        ])
        return v
    }

    // MARK: - Letters Pane

    private func buildLettersPane() -> UIView {
        let v = UIView(); v.backgroundColor = .clear
        let s = vstk(8)
        s.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(s)

        s.addArrangedSubview(eqRow(["q","w","e","r","t","y","u","i","o","p"], letter: true))

        let r2w = UIView(); r2w.backgroundColor = .clear
        let r2  = eqRow(["a","s","d","f","g","h","j","k","l"], letter: true)
        r2.translatesAutoresizingMaskIntoConstraints = false
        r2w.addSubview(r2)
        NSLayoutConstraint.activate([
            r2.topAnchor.constraint(equalTo: r2w.topAnchor),
            r2.bottomAnchor.constraint(equalTo: r2w.bottomAnchor),
            r2.centerXAnchor.constraint(equalTo: r2w.centerXAnchor),
            r2.widthAnchor.constraint(equalTo: r2w.widthAnchor, multiplier: 0.9),
        ])
        s.addArrangedSubview(r2w)

        let r3 = hstk(6, dist: .fill)
        let shft = btn("⇧", bg: kActionBg, fs: 16)
        shft.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
        shft.widthAnchor.constraint(equalToConstant: 42).isActive = true
        shiftKey = shft

        let del = btn("⌫", bg: kActionBg, fs: 16)
        del.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        del.widthAnchor.constraint(equalToConstant: 42).isActive = true
        attachLongPress(del)

        r3.addArrangedSubview(shft)
        r3.addArrangedSubview(eqRow(["z","x","c","v","b","n","m"], letter: true))
        r3.addArrangedSubview(del)
        s.addArrangedSubview(r3)
        s.addArrangedSubview(buildBottomRow(mode: "123", toNums: true))

        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: v.topAnchor, constant: 8),
            s.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 3),
            s.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -3),
            s.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -4),
        ])
        return v
    }

    // MARK: - Numbers Pane

    private func buildNumbersPane() -> UIView {
        let v = UIView(); v.backgroundColor = .clear
        let s = vstk(8)
        s.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(s)

        s.addArrangedSubview(eqRow(["1","2","3","4","5","6","7","8","9","0"], letter: false))
        s.addArrangedSubview(eqRow(["-","/",":",";","(",")",  "$","&","@","\""], letter: false))

        let r3 = hstk(6, dist: .fill)
        let sym = btn("#+=", bg: kActionBg, fs: 13)
        sym.widthAnchor.constraint(equalToConstant: 42).isActive = true

        let del = btn("⌫", bg: kActionBg, fs: 16)
        del.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        del.widthAnchor.constraint(equalToConstant: 42).isActive = true
        attachLongPress(del)

        r3.addArrangedSubview(sym)
        r3.addArrangedSubview(eqRow([".",",","?","!","'"], letter: false))
        r3.addArrangedSubview(del)
        s.addArrangedSubview(r3)
        s.addArrangedSubview(buildBottomRow(mode: "ABC", toNums: false))

        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: v.topAnchor, constant: 8),
            s.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 3),
            s.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -3),
            s.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -4),
        ])
        return v
    }

    // MARK: - Bottom Row

    private func buildBottomRow(mode: String, toNums: Bool) -> UIStackView {
        let r = hstk(6, dist: .fill)
        r.heightAnchor.constraint(equalToConstant: 46).isActive = true

        let modeBtn = btn(mode, bg: kActionBg, fs: 15)
        modeBtn.widthAnchor.constraint(equalToConstant: 42).isActive = true
        modeBtn.addTarget(self, action: toNums ? #selector(goNumbers) : #selector(goLetters), for: .touchUpInside)

        let globeBtn = btn("🌐", bg: kActionBg, fs: 18)
        globeBtn.widthAnchor.constraint(equalToConstant: 42).isActive = true
        globeBtn.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        let spaceBtn = btn("space", bg: kKeyBg, fs: 15)
        spaceBtn.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)

        let retBtn = btn("return", bg: kActionBg, fs: 15)
        retBtn.widthAnchor.constraint(equalToConstant: 96).isActive = true
        retBtn.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)

        [modeBtn, globeBtn, spaceBtn, retBtn].forEach { r.addArrangedSubview($0) }
        return r
    }

    // MARK: - Factory

    private func eqRow(_ titles: [String], letter: Bool) -> UIStackView {
        let r = hstk(6, dist: .fillEqually)
        for t in titles {
            let b = btn(t, bg: kKeyBg, fs: 17)
            b.addTarget(self, action: letter ? #selector(letterTapped(_:)) : #selector(charTapped(_:)), for: .touchUpInside)
            r.addArrangedSubview(b)
        }
        return r
    }

    private func btn(_ title: String, bg: UIColor, fs: CGFloat) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: fs)
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = bg
        b.layer.cornerRadius = 5
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 1)
        b.layer.shadowOpacity = 0.3
        b.layer.masksToBounds = false
        return b
    }

    private func vstk(_ sp: CGFloat) -> UIStackView {
        let s = UIStackView(); s.axis = .vertical; s.spacing = sp; return s
    }

    private func hstk(_ sp: CGFloat, dist: UIStackView.Distribution = .fill) -> UIStackView {
        let s = UIStackView(); s.axis = .horizontal; s.spacing = sp; s.distribution = dist; return s
    }

    private func attachLongPress(_ button: UIButton) {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(deleteHeld(_:)))
        lp.minimumPressDuration = 0.4
        button.addGestureRecognizer(lp)
    }

    // MARK: - Actions

    @objc private func letterTapped(_ sender: UIButton) {
        guard let t = sender.title(for: .normal) else { return }
        textDocumentProxy.insertText(shiftState != .off ? t.uppercased() : t)
        if shiftState == .on { shiftState = .off; refreshShift() }
    }

    @objc private func charTapped(_ sender: UIButton) {
        guard let t = sender.title(for: .normal) else { return }
        textDocumentProxy.insertText(t)
    }

    @objc private func spaceTapped()  { textDocumentProxy.insertText(" ") }
    @objc private func returnTapped() { textDocumentProxy.insertText("\n") }
    @objc private func deleteTapped() { textDocumentProxy.deleteBackward() }

    @objc private func deleteHeld(_ g: UILongPressGestureRecognizer) {
        switch g.state {
        case .began:
            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }
        case .ended, .cancelled:
            deleteTimer?.invalidate(); deleteTimer = nil
        default: break
        }
    }

    @objc private func shiftTapped() {
        let now = Date()
        let fast = now.timeIntervalSince(lastShiftTap) < 0.4
        lastShiftTap = now
        switch shiftState {
        case .off:    shiftState = fast ? .locked : .on
        case .on:     shiftState = fast ? .locked : .off
        case .locked: shiftState = .off
        }
        refreshShift()
    }

    private func refreshShift() {
        switch shiftState {
        case .off:
            shiftKey.setTitle("⇧", for: .normal)
            shiftKey.backgroundColor = kActionBg
            shiftKey.setTitleColor(.black, for: .normal)
        case .on:
            shiftKey.setTitle("⇧", for: .normal)
            shiftKey.backgroundColor = kKeyBg
            shiftKey.setTitleColor(.black, for: .normal)
        case .locked:
            shiftKey.setTitle("⇪", for: .normal)
            shiftKey.backgroundColor = kPurple
            shiftKey.setTitleColor(.white, for: .normal)
        }
    }

    @objc private func goNumbers() { lettersPane.isHidden = true;  numbersPane.isHidden = false }
    @objc private func goLetters() { lettersPane.isHidden = false; numbersPane.isHidden = true  }
    @objc private func improveTapped() { /* Phase 3: grab surrounding text, send to API */ }
}
