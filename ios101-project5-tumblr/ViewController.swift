//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        let url = URL(string: "\(post.photos[0].originalSize.url)")!
        Nuke.loadImage(with: url, into: cell.postImage)
        cell.summaryLabel.text = post.summary
        return cell
    }
    
    
    @IBOutlet weak var postsTableView: UITableView!
    
    private var posts = [Post]()
    private let refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshPosts(_:)), for: .valueChanged)
        postsTableView.refreshControl = refreshControl
        
        fetchPosts()
    }
    
    @objc func refreshPosts(_ sender: Any) {
        fetchPosts()
    }



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/pitchersandpoets.tumblr.com/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    self?.posts = posts
                    self?.postsTableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }

            } catch {
                self.refreshControl.endRefreshing()
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
