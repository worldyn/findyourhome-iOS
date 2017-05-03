import UIKit
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listings:[Listing] = [Listing]()
    
    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "cell"
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.get_data("http://findyourhome.se:2932/api?apikey=aKwo4vIzpEKSeE70kQG7yQoLAfHV2lPo")
    }
    
    func get_data(_ link: String) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.extract_data(data)
        })
        task.resume()

    }
    
    func extract_data(_ data: Data?) {
        let json:Any?
        
        if(data == nil) {
            print("Fetched Data is nil")
            return
        }
        
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        } catch {
            print("Failed jsonserialization")
            return
        }
        
        guard let data_array = json as? NSArray else {
            print("failed to convert json to nsarray")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //let concurrentQueue = DispatchQueue(label: "com.queue.Concurrent", attributes: .concurrent)
        
        for i in 0 ..< data_array.count {
            //concurrentQueue.sync {
                if let data_object = data_array[i] as? NSDictionary {
                    if let data_link = data_object["id"] as? String,
                        let data_address = data_object["addess"] as? String,
                        let data_price = data_object["price"] as? String,
                        let data_publishedDate = data_object["publishedDate"] as? String,
                        let data_imageUrl = data_object["imageUrl"] as? String
                        
                    {
                        let pictureURL = URL(string: data_imageUrl)!
                        let date = dateFormatter.date(from: data_publishedDate)!
                        let price = Int(data_price)!
                        let imageData = try! Data(contentsOf: pictureURL)
                        let fetchedImage = UIImage(data: imageData)!
                        self.listings.append(Listing(data_link, data_address, price, date, fetchedImage))
                    }
                    
                }
            //}
        }
        
        
        print("data fetch done, sorting and then refreshing..")

        // sort data by date
        /*
        * CHANGE DIRECTION OF < to: >
        */
        self.listings.sort { $0.publishedDate < $1.publishedDate }
        
        self.refresh_now()
    }
    
    func refresh_now() {
        print("refreshing..")
        DispatchQueue.main.async(
            execute:
            {
                self.tableView.reloadData()
            }
        )
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("NUM OF ROWS: \(self.listings.count)")
        return self.listings.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ListingCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListingCell
        
        //cell.link.text = self.listings[indexPath.row].link
        cell.address.text = self.listings[indexPath.row].address
        cell.price.text = "\(self.listings[indexPath.row].price) / month"
        let dateString = "\(self.listings[indexPath.row].publishedDate)"
        let index = dateString.index(dateString.startIndex, offsetBy: 10)
        cell.publishedDate.text = dateString.substring(to: index)
        cell.listingImage.image = self.listings[indexPath.row].listingImage
        
        print("ROW CELL: \(indexPath.row)")
        
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let identifier = segue.identifier {
            switch identifier {
                case "ShowDetail":
                    let listingDetailVC = segue.destination as! ListingDetailViewController
                    if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                        listingDetailVC.listing = self.listings[indexPath.row]
                    }
                
                default:
                    break
            }
        }
     }
    
}
