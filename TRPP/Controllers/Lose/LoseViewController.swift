import UIKit

class LoseViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!

    var quizBrain: MillionareBrain!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "Вы заработали \(quizBrain.getFinalScore()) рублей."
    }

    @IBAction func playAgainTapped(_ sender: UIButton) {
    
        self.navigationController?.popToRootViewController(animated: false)
        
    }
}
