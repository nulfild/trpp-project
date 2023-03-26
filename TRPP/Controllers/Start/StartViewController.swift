import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.shared.score = 5
        print(UserManager.shared.score)
    }

    @IBAction func resultsTapped(_ sender: UIButton) {
        let controller = LeaderBoardViewController(nibName: "LeaderBoardViewController", bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    @IBAction func rulesButtomTapped(_ sender: UIButton) {
        let controller = RulesViewController(nibName: "RulesViewController", bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let controller = GuestViewController(nibName: "GuestViewController", bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        controller.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
}


