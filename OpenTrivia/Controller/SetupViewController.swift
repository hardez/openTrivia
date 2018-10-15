//
//  SetupViewController.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 15.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    
    @IBOutlet weak var difficulty: UISegmentedControl!
    @IBOutlet weak var questiontype: UISegmentedControl!
    @IBOutlet weak var startGameOutlet: UIButton!
    var token: String? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! QuestionViewController
        destVC.token = self.token
        
        switch(difficulty.selectedSegmentIndex){
            case 0:
                destVC.difficulty = nil
            case 1:
                destVC.difficulty = "easy"
            case 2:
                destVC.difficulty = "medium"
            case 3:
                destVC.difficulty = "hard"
            default:
                destVC.difficulty = nil
        }
        
        
        switch(questiontype.selectedSegmentIndex){
        case 0:
            destVC.type = nil
        case 1:
            destVC.type = "boolean"
        case 2:
            destVC.type = "multiple"
        default:
            destVC.type = nil
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.token == nil || self.token == ""){
            let urlString = "https://opentdb.com/api_token.php?command=request"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let resp = try JSONDecoder().decode(TokenResponse.self, from: data)
                    
                    if resp.response_code == 0{
                        self.token = resp.token
                    }
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.startGameOutlet.isHidden = false
                    }
                    
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

}
