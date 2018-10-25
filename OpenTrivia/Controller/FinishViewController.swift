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
    @IBOutlet weak var newGameButton: UIButton!
    
    var score = 0
    var savedCategories = [TriviaCategorie]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreLabel.text = "Final Score: \(score)"
        if savedCategories.count <= 1{
            newGameButton.isHidden = true
            let urlString = "https://opentdb.com/api_category.php"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                do {
                    let resp = try JSONDecoder().decode(TriviaCategories.self, from: data)
                    
                    for categorie in resp.trivia_categories{
                        if !(categorie.name.starts(with: "Entertainment:")){
                            self.savedCategories.append(categorie)
                        }
                    }
                    //Get back to the main queue
                    
                    DispatchQueue.main.async {
                        self.newGameButton.isHidden = false
                    }
                    
                    
                } catch let jsonError {
                    print(jsonError)
                }
                
                
                }.resume()
        
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Config.Triviaseques.newGame.rawValue {
            let destVC = segue.destination as! QuestionViewController
            destVC.token = UserDefaults.standard.string(forKey: "token")
            destVC.categories = savedCategories
        }
    }

}
