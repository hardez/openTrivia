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
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    let timerPointsLabel = UILabel()
    
    
    lazy var answerButtons: [UIButton] = [button1, button2, button3, button4]
//    var theAnswer: String?
    var token: String?
    var currentDifficulty = [Difficulty.easy, Difficulty.medium, Difficulty.hard]
    var questionType = [QuestionType.boolean, QuestionType.multiple]
    var categories = [TriviaCategorie]()
    var question: Question?
    var correctAnswers = 0 {
        didSet{
            self.scoreLabel.text = "Score: \(self.correctAnswers)"
            self.scoreLabel.setNeedsDisplay()
        }
    }
    //var timer = Timer()
    var timer = Timer()
    var timerIsRunning = false
    var timeLeft: Float = 60 {
        didSet{
            self.timeLabel.text = "\(Int(self.timeLeft))s"
            self.timeLabel.setNeedsDisplay()
        }
    }
    
    func animateAnswer(points: Float, fromButton: UIButton){
        var withColor: UIColor
        if points > 0{
            withColor = .green
            self.correctAnswers += 1
            timerPointsLabel.text = "+\(Int(points))"
        } else {
            withColor = .red
            timerPointsLabel.text = "\(Int(points))"
        }
        timerPointsLabel.textColor = withColor
        timerPointsLabel.textAlignment = .center
        timerPointsLabel.font = timerPointsLabel.font.withSize(5)
        //timerPointsLabel.backgroundColor = .red
        self.view.addSubview(timerPointsLabel)
        timerPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        timerPointsLabel.widthAnchor.constraint(equalToConstant: 100)
        timerPointsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        timerPointsLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 250).isActive = true
        self.view.layoutIfNeeded()
        animate(label: timerPointsLabel, button: fromButton, withColor: withColor)
        self.timeLeft += points
        
    }
    
    func animate(label: UILabel, button: UIButton, withColor: UIColor){
        UIView.animate(withDuration: 0.5) {
            label.bottomAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 40).isActive = true
            label.font = label.font.withSize(40)
            button.backgroundColor = withColor
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            label.removeFromSuperview()
        })
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        for button in self.answerButtons{
            button.isEnabled = false
        }
        let answerTapped = sender.titleLabel?.text
        guard let question = question else {return}
        
        var plusPoints: Float = 0.0
        var minusPoints: Float = 0.0
        
        switch question.difficulty {
        case .easy:
            plusPoints = 10.0
            minusPoints = -30.0
        case .medium:
            plusPoints = 20.0
            minusPoints = -20.0
        case .hard:
            plusPoints = 30.0
            minusPoints = -10
        }
        
        
        if answerTapped == self.question?.correct_answer.htmlDecoded() {
            //animateButton(button: sender, withColor: .green)
            animateAnswer(points: plusPoints, fromButton: sender)
            //self.correctAnswers += 1
            //self.timeLeft += 10
        } else {
            //animateButton(button: sender, withColor: .red)
            animateAnswer(points: minusPoints, fromButton: sender)
            //self.timeLeft -= 5
            for button in answerButtons{
                if button.titleLabel?.text == self.question?.correct_answer.htmlDecoded(){
                    animateButton(button: button, withColor: .green)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.setupQuestionView()
        })
        
    }
    
    func animateButton(button: UIButton, withColor: UIColor){
        UIView.animate(withDuration: 0.5) {
            button.backgroundColor = withColor
        }
    }
    
    @objc func fireTimer(){
        if(timerIsRunning){
            self.timeLeft -= 0.1
            if self.timeLeft <= 0{
                self.timer.invalidate()
                performSegue(withIdentifier: Config.Triviaseques.finishSegue.rawValue, sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Config.Triviaseques.finishSegue.rawValue {
            let destVC = segue.destination as! FinishViewController
            destVC.score = self.correctAnswers
            destVC.savedCategories = self.categories
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupQuestionView()
        self.timer = Timer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer, forMode: .common)
    }

    func setupQuestionView(){
        var urlString = "https://opentdb.com/api.php?amount=1"
        urlString += "&difficulty=\(self.currentDifficulty.randomElement() ?? Difficulty.easy)"
        urlString += "&type=\(self.questionType.randomElement() ?? QuestionType.multiple)"
        urlString += "&category=\((self.categories.randomElement())?.id ?? 9)" // 9 is Category General Knowledge
        if let token = self.token{
            urlString += "&token=\(token)"
        }
        guard let url = URL(string: urlString) else { return }
        
        self.timerIsRunning = false
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
                        // there is only one question asked for...
                        self.question = question
                        DispatchQueue.main.async {
                            self.categoryLabel.text = question.category
                            self.questionText.text = question.question.htmlDecoded()
                            self.difficultyLabel.text = "Difficulty: \(question.difficulty.rawValue.capitalized)"
                            
                            var answers = question.getAnswers().shuffled()
                            for button in self.answerButtons{
                                button.backgroundColor = .blue
                                if question.type == .boolean && (button.tag == 1 || button.tag == 4){
                                    button.isHidden = true
                                } else {
                                    button.isHidden = false
                                    button.isEnabled = true
                                    button.setTitle(answers.popLast()?.htmlDecoded(), for: .normal)
                                }
                            }
                        
                        }
                    }
                    self.timerIsRunning = true
                } else {
                    print(resp)
                    self.categories.removeLast()
                    self.setupQuestionView()
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

