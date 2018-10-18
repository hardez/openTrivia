//
//  FinishViewController.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 18.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    
    var score = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreLabel.text = "Final Score: \(score)"
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Config.Triviaseques.newGame.rawValue {
            let destVC = segue.destination as! QuestionViewController
            destVC.token = UserDefaults.standard.string(forKey: "token")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
