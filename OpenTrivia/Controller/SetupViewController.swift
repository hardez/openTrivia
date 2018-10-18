//
//  SetupViewController.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 15.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    
    @IBOutlet weak var startGameOutlet: UIButton!
    var token: String? = nil
    var categories = [TriviaCategorie]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameSegue" {
            let destVC = segue.destination as! QuestionViewController
            destVC.token = self.token
            destVC.categories = self.categories
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.categories.count == 0){
            let urlString = "https://opentdb.com/api_category.php"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                //Implement JSON decoding and parsing
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let resp = try JSONDecoder().decode(TriviaCategories.self, from: data)
                    
                    for categorie in resp.trivia_categories{
                        if !(categorie.name.starts(with: "Entertainment:")){
                            self.categories.append(categorie)
                        }
                    }
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        self.startGameOutlet.isHidden = false
                    }
                    } catch let jsonError {
                        print(jsonError)
                }
                
                
                }.resume()
        }
        
        
        let tokenDate = UserDefaults.standard.object(forKey: "tokenTime") as? Date ?? Date(timeIntervalSince1970: 0)
        let sixHourseInSeconds = Double(6*60*60)
        
        if Date().timeIntervalSince(tokenDate) < sixHourseInSeconds {
                self.token = UserDefaults.standard.string(forKey: "token")
        } else {
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
                            UserDefaults.standard.set(Date(), forKey:"tokenTime")
                            UserDefaults.standard.set(resp.token, forKey:"token")
                        }
                        
                        // need to make sure that categories are available
                        // very hacky, need to find a better way
                        while(self.categories.count == 0){
                            sleep(1)
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

}
