//
//  ViewController.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 14.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var questionText: UITextView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    lazy var answerButtons: [UIButton] = [button1, button2, button3, button4]
    var theAnswer: String?
    var token: String?
    var difficulty: String?
    var type: String?
    var points: Int = 0 {
        didSet{
            self.scoreLabel.text = "Score: \(self.points)"
            self.scoreLabel.setNeedsDisplay()
        }
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        let answerTapped = sender.titleLabel?.text
        if answerTapped == theAnswer {
            animateButton(button: sender, withColor: .green)
            self.points += 10
        } else {
            animateButton(button: sender, withColor: .red)
            self.points -= 10
            for button in answerButtons{
                if button.titleLabel?.text == theAnswer{
                    animateButton(button: button, withColor: .green)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.setupQuestionView()
        })
        
    }
    
    func animateButton(button: UIButton, withColor: UIColor){
        UIView.animate(withDuration: 0.7) {
            button.backgroundColor = withColor
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupQuestionView()
        
        
    }

    func setupQuestionView(){
        guard let token = token else { return }
        var urlString = "https://opentdb.com/api.php?amount=1"
        
        if let difficulty = self.difficulty{
            urlString += "&difficulty=\(difficulty)"
        }
        
        if let type = self.type{
            urlString += "&type=\(type)"
        }
        
        urlString += "&token=\(token)"
        
        guard let url = URL(string: urlString) else { return }
        
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let resp = try JSONDecoder().decode(Response.self, from: data)
                
                if resp.response_code == 0{
                    let questions = resp.results
                    
                    for question in questions{
                        self.theAnswer = question.correct_answer.htmlDecoded()
                        DispatchQueue.main.async {
                            self.categoryLabel.text = question.category
                            self.questionText.text = question.question.htmlDecoded()
                            self.difficultyLabel.text = question.difficulty.rawValue.capitalized
                            
                            var answers = question.getAnswers().shuffled()
                            for button in self.answerButtons{
                                button.backgroundColor = .brown
                                if question.type == .boolean && (button.tag == 1 || button.tag == 4){
                                    button.isHidden = true
                                } else {
                                    button.isHidden = false
                                    button.setTitle(answers.popLast()?.htmlDecoded(), for: .normal)
                                }
                            }
                        
                        }
                    }
                    
                }
                //Get back to the main queue
                
                
            } catch let jsonError {
                print(jsonError)
                let alert = UIAlertController(title: "Alert", message: "TriviaDB could not be reached. Pleas try again later", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
            }.resume()
    }

}

