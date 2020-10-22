//
//  ContentView.swift
//  OwnRestApiSailsJS_SwiftUI
//
//  Created by Maxim Macari on 21/10/2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        NavigationView{
            Home()
                .navigationTitle("Sails JS")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// 1. Createe new Sails JS project
// 2. Craete routse for: user


struct Home: View {
    
    @StateObject var data = Server()
    
    var body: some View{
        
        VStack{
            if data.users.isEmpty {
                if data.noData{
                    Text("No users found")
                }else{
                    ProgressView()
                }
            }else{
                List{
                    ForEach(data.users, id: \.id){ user in
                        
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("\(user.username)")
                                .fontWeight(.bold)
                            
                            Text("\(user.password)")
                                .font(.caption)
                        })
                        
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { i in
                            data.deleteUser(idUser: data.users[i].id)
                            
                        }
                    })
                    
                }
            }
        }
        
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    data.newUser()
                }){
                    Text("Create user")
                }
            }
        })
        
        
    }
}



class Server: ObservableObject{
    
    @Published var users: [User] = []
    private let urlString = "http://192.168.1.88:1337/user"
    @Published var noData = false
    
    init() {
        getUsers()
        
    }
    
    func setUser(username: String, password: String){
        
        let session = URLSession(configuration: .default)
        
        if let url =  URL(string: urlString){
            var request  = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            //Adding header values
            
            request.addValue(username, forHTTPHeaderField: "username")
            request.addValue(password, forHTTPHeaderField: "password")
            
            session.dataTask(with: request){ (data, res, err) in
                
                if err != nil, let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                guard let response = data else {
                    return
                }
                
                let status = String(data: response, encoding: .utf8) ?? ""
                
                if status == "PASS"{
                    self.getUsers()
                }else{
                    print("Failed to POST user", status)
                }
                
            }
            .resume()
            
        }
        
        
    }
    
    func getUsers(){
        if let url =  URL(string: urlString){
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: request) { (data, res, err) in
                
                if err != nil, let err = err {
                    print(err.localizedDescription)
                    self.noData.toggle()
                    return
                }
                
                guard let response = data else { return }
                
                let users = try! JSONDecoder().decode([User].self, from: response)
                
                DispatchQueue.main.async {
                    self.users = users
                    if users.isEmpty{
                        self.noData.toggle()
                    }
                }
                
            }
            .resume()
            
            
        }
    }
    
    func deleteUser(idUser:  Int){
        if let url =  URL(string: urlString){
            var request = URLRequest(url: url)
            
            request.httpMethod = "DELETE"
            
            request.addValue("\(idUser)", forHTTPHeaderField: "id")
            
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: request) { (data, res, err) in
                
                if err != nil, let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                guard let response = data else { return }
                
                let status = String(data: response, encoding: .utf8) ?? ""
                
                if status == "PASS" {
                    DispatchQueue.main.async {
                        
                        //removing data in list
                        self.users.removeAll { (user) -> Bool in
                            
                            return user.id == idUser
                            
                        }
                    }
                }
                else{
                    print("Failed to delete")
                }
                
            }
            .resume()
        }
    }
    
    func newUser(){
        
        //Alert view
        let alert = UIAlertController(title: "New User", message: "Create an account", preferredStyle: .alert)
        
        alert.addTextField { (user) in
            user.placeholder = "Username"
        }
        
        alert.addTextField { (pass) in
            pass.placeholder = "Password"
            pass.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (_) in
            if let userName = alert.textFields?[0].text, let pass = alert.textFields?[1].text  {
                self.setUser(username: userName, password: pass)
            }
            
        }))
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        
    }
}


struct User: Decodable {
    
    var id: Int
    var username: String
    var password: String
    
    
    
}
