//
//  SetupViewController.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 15.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    var token: String?
    
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
                self.token = String(data: data, encoding: .utf8)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    //print(articlesData)
                    self.articles = articlesData
                    self.collectionView?.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            
            }.resume()
        
    }

}
