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
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    lazy var answerButtons: [UIButton] = [button1, button2, button3, button4]
    var theAnswer: String?
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        print("Button tapped")
        let answerTapped = sender.titleLabel?.text
        print(answerTapped)
        if answerTapped == theAnswer {
            animateButton(button: sender, withColor: .green)
        } else {
            animateButton(button: sender, withColor: .red)
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
        let urlString = "https://opentdb.com/api.php?amount=1"
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
                        print(question.question)
                        self.theAnswer = question.correct_answer
                        DispatchQueue.main.async {
                            //print(articlesData)
                            print("set Labels")
                            self.categoryLabel.text = question.category
                            self.questionText.text = question.question
                            
                            var answers = question.getAnswers().shuffled()
                            print(answers.count)
                            print(self.answerButtons.count)
                            for button in self.answerButtons{
                                print(button.tag)
                                button.backgroundColor = .brown
                                if question.type == .boolean && (button.tag == 1 || button.tag == 4){
                                    print("hide button")
                                    button.isHidden = true
                                } else {
                                    print("set Button Label to \(String(describing: answers.last))")
                                    button.setTitle(answers.popLast(), for: .normal)
                                }
                            }
                        
                        }
                    }
                    
                }
                //Get back to the main queue
                
                
            } catch let jsonError {
                print(jsonError)
                let alert = UIAlertController(title: "Alert", message: jsonError as? String, preferredStyle: UIAlertController.Style.alert)
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

