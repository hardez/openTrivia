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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! QuestionViewController
        destVC.token = self.token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            }
            
            
            }.resume()
        
    }

}
