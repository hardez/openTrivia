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
    
    @IBOutlet var answerButtons: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupQuestionView()
        
    }

    func setupQuestionView(){
        let urlString = "https://opentdb.com/api.php?amount=1&difficulty=easy"
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
                        DispatchQueue.main.async {
                            //print(articlesData)
                            print("set Labels")
                            self.categoryLabel.text = question.category
                            self.questionText.text = question.question
                            
                            var answers = question.getAnswers().shuffled()
                            
                            for button in self.answerButtons{
                                if answers.count > 2 && (button.tag == 1 || button.tag == 4){
                                    button.isHidden = true
                                } else {
                                    print("set Button Label to \(String(describing: answers.last))")
                                    button.titleLabel?.text = answers.popLast()
                                }
                            }
                        
                        }
                    }
                    
                }
                //Get back to the main queue
                
                
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }

}

