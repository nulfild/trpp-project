import UIKit
import AVFoundation

class QuizViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet var answerButtons: [AnswerButton]!
    @IBOutlet weak var timeIndicaror: UIProgressView!
    
    @IBOutlet weak var halfToHalf: UIButton!
    @IBOutlet weak var viewersHelp: UIButton!
    @IBOutlet weak var callHelp: UIButton!
    @IBOutlet weak var protectionHelp: UIButton!
    
    var player: AVAudioPlayer?
    var quizBrain: MillionareBrain!
    var timer = Timer()
    var totalTime = 30
    var secondsPassed = 0
    var isTimerStoped = false
    var isProtectedFromMistake:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        player?.numberOfLoops = -1
        setSound(soundName: "thinking",startTime: 0)
        startTimer()
        isProtectedFromMistake = false
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        if let player = player, !player.isPlaying {
            setSound(soundName: "thinking",startTime: 0)
            player.currentTime = 0
            player.play()
            startTimer()
        }
        
        isProtectedFromMistake = false
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.stop()
            timer.invalidate()
        }
    }
    

    
    @IBAction func ButtonPresses(_ sender: AnswerButton) {
        answerButtons.forEach({$0.isEnabled = false})
        blockStatusHelpBt(status: false)
        
        let userAnswer = Int(sender.tag)
        let userGotItRight = quizBrain.getQuestionAnswers()[userAnswer]?.isCorrect
        
        isTimerStoped = true
        let continueTime = player?.currentTime
        self.setSound(soundName: "waiting", startTime: 0)
        
        sender.tapEffect()
        sender.yellowLayer.isHidden = false
       
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: { [self] in
            
            self.player?.stop()
            
            if (userGotItRight!) {
                self.openProgressView(soundName: "rightAnswer", isAnswerCorrect: false)
                sender.greenLayer.isHidden = false

            } else {
                
                if(!isProtectedFromMistake){
                    self.openProgressView(soundName:"wrongAnswer", isAnswerCorrect: true)
                    sender.redLayer.isHidden = false
                    
                    let id = quizBrain.getQuestionAnswers().first( where: { $0.value.isCorrect } )?.key
                    answerButtons[id!].greenLayer.isHidden = false
                }else{
                    
                    self.setSound(soundName: "wrongAnswer",startTime: 0 )
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: { [self] in
                        quizBrain.removeAnswer(key: userAnswer)
                        sender.isHidden = true
                        self.isProtectedFromMistake = false
                        updateStatusHelpBt()
                        answerButtons.forEach({$0.isEnabled = true})
                        self.setSound(soundName: "thinking", startTime: continueTime)
                        isTimerStoped = false
                    })
                }
                                                  
            }
        })
        
    }
    
    func openProgressView(soundName:String, isAnswerCorrect: Bool){
        self.setSound(soundName: soundName, startTime: 0 )
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
            
            let controller = ProgressViewController(nibName: "ProgressViewController",bundle: nil)
            controller.quizBrain = self.quizBrain
            controller.isEnd = isAnswerCorrect
            controller.modalPresentationStyle = .fullScreen
            
            controller.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(controller, animated: false)

            self.updateUI()
        })
    }
    
    func updateUI() {
        questionLabel.text = quizBrain.getCurrentQuestion()
        priceLabel.text = getScoreLabel
        questionNumLabel.text = getQuestionLabel
        
        updateStatusHelpBt()
        setButtonsVisable()
        
        answerButtons.forEach({
            $0.labelRight.text = quizBrain.getQuestionAnswers()[Int($0.tag)]?.answer
            $0.isEnabled = true
            $0.backgroundColor = UIColor.clear
            $0.yellowLayer.isHidden = true
            $0.redLayer.isHidden = true
            $0.greenLayer.isHidden = true
            $0.layer.shadowColor = UIColor.gray.cgColor
        })
    }
    
    
    func startTimer(){
        
        timeIndicaror.progress = 0.0
        secondsPassed = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(updateTimer), userInfo:nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if(!self.isTimerStoped){
        
            if secondsPassed < totalTime {
            secondsPassed += 1
            timeIndicaror.progress = Float(secondsPassed) / Float(totalTime)
            print(Float(secondsPassed) / Float(totalTime))
        } else {
            answerButtons.forEach({$0.isEnabled = false})
            openProgressView(soundName: "wrongAnswer", isAnswerCorrect: true)
            timer.invalidate()
        }
        
        }
    }
    
    
    var getScoreLabel: String {
        return String(quizBrain.getPrice())+" руб."
    }
    
    var getQuestionLabel: String {
        return "Вопрос № " + String(quizBrain.getQuestionNumber() + 1)
    }
    
    func setSound(soundName: String, startTime: TimeInterval?) {
        guard let path = Bundle.main.path(forResource: soundName, ofType:"mp3") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.currentTime = startTime!
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func halfToHalpPressed(_ sender: UIButton) {
        let res = quizBrain.fiftyFiftyHelp()
        answerButtons[res.0].isHidden = true;
        answerButtons[res.1].isHidden = true;
        sender.setBackgroundImage(UIImage(named: "usedHelpFifty.png"), for: .normal)
        quizBrain.helps["fifty"] = false
        halfToHalf.isEnabled = false
    }
    
    
    @IBAction func viewersHelpPressed(_ sender: UIButton) {
        let res = quizBrain.viewerskHelp()
        answerButtons[res].layer.shadowColor = UIColor.green.cgColor
        sender.setBackgroundImage(UIImage(named: "usedHelpHall.png"), for: .normal)
        quizBrain.helps["view"] = false
        viewersHelp.isEnabled = false
    }
    
    @IBAction func callHelpPressed(_ sender: UIButton) {
        let res = quizBrain.callFriendHelp()
        answerButtons[res].layer.shadowColor = UIColor.green.cgColor
        sender.setBackgroundImage(UIImage(named: "usedHelpCall.png"), for: .normal)
        quizBrain.helps["call"] = false
        callHelp.isEnabled = false
    }
    
    @IBAction func protectionHelpPressed(_ sender: UIButton) {
        sender.setBackgroundImage(UIImage(named: "usedMistakeHelp.png"), for: .normal)
        protectionHelp.isEnabled = false
        quizBrain.helps["mistake"] = false
        self.isProtectedFromMistake = true
    }
    
    func updateStatusHelpBt() {
        callHelp.isEnabled = quizBrain.helps["call"]!
        viewersHelp.isEnabled = quizBrain.helps["view"]!
        halfToHalf.isEnabled = quizBrain.helps["fifty"]!
        protectionHelp.isEnabled =  quizBrain.helps["mistake"]!
    }
    
    func blockStatusHelpBt(status: Bool) {
        callHelp.isEnabled = status
        viewersHelp.isEnabled = status
        halfToHalf.isEnabled = status
        protectionHelp.isEnabled = status
    }
    
    func setButtonsVisable(){
        answerButtons.forEach({$0.isHidden = false})
    }
}
