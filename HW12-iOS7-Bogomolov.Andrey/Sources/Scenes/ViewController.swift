//
//  ViewController.swift
//  HW12-iOS7-Bogomolov.Andrey
//
//  Created by Andrey Bogomolov on 25.08.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Elements

    private var timer = Timer()
    private let workTime = 5.0
    private let restTime = 3.0
    private lazy var counter = workTime
    private var shapeLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var isWorkTime = true
    private var isStarted = true
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "myView")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var labelTimer: UILabel = {
        let label = UILabel()
        label.text = "\(timeString(time: TimeInterval(counter)))"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var startStopLabel: UILabel = {
        let label = UILabel()
        label.text = "Click to start WORKTIME"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        var playPauseButton = UIButton()
        var image = UIImage(named: "play")
        playPauseButton.tintColor = .systemRed
        playPauseButton.setImage(image, for: .normal)
        playPauseButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        return playPauseButton
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.addArrangedSubview(labelTimer)
        stack.addArrangedSubview(playPauseButton)
        return stack
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - Private functions
   
    private func createShapeLayer() {
        let viewCircle = UIView()
        viewCircle.backgroundColor = .clear
        view.addSubview(viewCircle)
        viewCircle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view).offset(-205)
        }
        
        let circularPath = UIBezierPath(arcCenter: viewCircle.center,
                                        radius: 120,
                                        startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2,
                                        clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemRed.cgColor
        trackLayer.strokeEnd = 1
        viewCircle.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.lineWidth = 12
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.systemGray5.cgColor
        shapeLayer.strokeEnd = 0
        viewCircle.layer.addSublayer(shapeLayer)
    }
    
    private func basicAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.speed = 1
        basicAnimation.duration = CFTimeInterval(counter)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
    
    private func pauseAnimation(_ layer: CAShapeLayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
    }
    
    private func resumeAnimation(_ layer: CAShapeLayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
   
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
        
    private func setupHierarchy() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(stack)
        view.addSubview(startStopLabel)
        createShapeLayer()
    }

    private func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view).offset(50)
            make.height.equalTo(350)
            make.right.equalTo(view).offset(30)
        }
        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view).offset(-150)
            }
        startStopLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view).offset(-360)
        }
    }
    
    private func changeState() {
            if isWorkTime {
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                playPauseButton.tintColor = .systemGreen
                labelTimer.textColor = .systemGreen
                trackLayer.strokeColor = UIColor.systemGreen.cgColor
                startStopLabel.text = "Click to start RESTTIME"
                startStopLabel.textColor = .systemGreen
                return
            }
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            playPauseButton.tintColor = .systemRed
            trackLayer.strokeColor = UIColor.systemRed.cgColor
            labelTimer.textColor = .systemRed
            startStopLabel.text = "Click to start WORKTIME"
            startStopLabel.textColor = .systemRed
        }
    
    // MARK: - Actions
    
    @objc private func playButtonPressed() {
        guard isStarted else {
            timer.invalidate()
            if isWorkTime {
                startStopLabel.text = "Click to start WORKTIME"
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                playPauseButton.tintColor = .systemRed
                pauseAnimation(shapeLayer)
                isWorkTime = true
            } else {
                startStopLabel.text = "Click to start RESTTIME"
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                playPauseButton.tintColor = .systemGreen
                pauseAnimation(shapeLayer)
                isWorkTime = false
            }
            isStarted = true
            return
        }
        if isWorkTime {
            startStopLabel.text = "Click to stop WORKTIME"
            startStopLabel.textColor = .systemRed
            timer = Timer.scheduledTimer(timeInterval: 0.001,
                                         target: self,
                                         selector: #selector(timerAction),
                                         userInfo: nil,
                                         repeats: true)
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            counter == workTime ? basicAnimation() : resumeAnimation(shapeLayer)
            playPauseButton.tintColor = .systemRed
            isWorkTime = true
        } else {
            startStopLabel.text = "Click to stop RESTTIME"
            startStopLabel.textColor = .systemGreen
            timer = Timer.scheduledTimer(timeInterval: 0.001,
                                         target: self,
                                         selector: #selector(timerAction),
                                         userInfo: nil,
                                         repeats: true)
            counter == restTime ? basicAnimation() : resumeAnimation(shapeLayer)
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            playPauseButton.tintColor = .systemGreen
            isWorkTime = false
        }
        isStarted = false
    }
    
    @objc private func timerAction() {
        counter -= 0.001
        labelTimer.text = "\(timeString(time: TimeInterval(counter)))"
        
        guard counter <= 0 else { return }
        
        counter = isWorkTime ? restTime : workTime
        changeState()
        isWorkTime.toggle()
        basicAnimation()
    }
}
