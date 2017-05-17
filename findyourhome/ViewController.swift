//
//  Created by Adam Jacobs
// This file handles the initial view's logic, meaning handling population and refreshing of the table view and data requests.
//  Copyright © 2017 Adam Jacobs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Listings shown in table view
    var listings:[Listing] = [Listing]()
    
    @IBOutlet var tableView: UITableView!
    
    // Used for different kinds of refreshing animations
    private let refreshControl = UIRefreshControl()
    var indicator = UIActivityIndicatorView()
    
    // Cell identifier for table view cells
    let cellReuseIdentifier = "cell"
    
    var dateFormatter: DateFormatter = DateFormatter()
    
    // Sequence number is used to know where you are in the 'pagination' of listings.
    // Starts as nil but is set when listigns are fetched
    var seqNumber: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorSetup()
        setUpTableView()
        getLatestListingsIntoTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * MARK - Class fields' methods and operations
    */
    
    // Update seqNumber via the oldest one in an empty listings arr
    func sequenceNumberUpdate() {
        let count: Int = self.listings.count
        if count > 0 {
            self.seqNumber = self.listings[count - 1].seqNumber
            print(self.seqNumber)
        }
    }
    
    /*
     * MARK - Refreshing and spinner ui methods
     */
    
    func stopRefresherAndUpdateTitle() {
        // update "last updated" title for refresh control
        let now = Date()
        let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
        self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
        if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }
    }
    
    func activityIndicatorSetup() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    func startSpinner() {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
    }
    
    func stopSpinner() {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    /*
    * MARK - Listing Data handling
    */
    
    func refreshListings(sender:AnyObject) {
        print("Pull down to refresh!")
        getLatestListingsIntoTableView()
    }
    
    func getLatestListingsIntoTableView() {
        // Date today
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        let now = self.dateFormatter.string(from: Date())
        self.listings = [Listing]()
        // Fetch later or equal to the current date with count equal to 10
        prepareListingRequest("http://findyourhome.se:2932/api?apikey=aKwo4vIzpEKSeE70kQG7yQoLAfHV2lPo&datefilter=lte:\(now)&count=10")
    }
    
    func addListingsToBottom() {
        prepareListingRequest("http://findyourhome.se:2932/api?apikey=aKwo4vIzpEKSeE70kQG7yQoLAfHV2lPo&seqfilter=lt:\(seqNumber)&count=10")
    }
    
    // Fetches certain listings according to what parameters are passed in the link url
    func prepareListingRequest(_ link: String) {
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.extractListings(data)
        })
        task.resume()
        
    }
    
    func extractListings(_ data: Data?) {
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
            print("failed to convert json to array")
            return
        }
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let concurrentQueue = DispatchQueue(label: "com.queue.Concurrent", attributes: .concurrent)
        
        for i in 0 ..< data_array.count {
            concurrentQueue.sync {
                if let data_object = data_array[i] as? NSDictionary {
                    if let data_link = data_object["id"] as? String,
                        let data_address = data_object["addess"] as? String,
                        let data_price = data_object["price"] as? String,
                        let data_publishedDate = data_object["publishedDate"] as? String,
                        let data_imageUrl = data_object["imageUrl"] as? String,
                        let data_contract = data_object["contract"] as? String,
                        let data_area = data_object["area"] as? String,
                        let data_size = data_object["size"] as? String,
                        let data_seqNumber = data_object["seqNumber"] as? Int
                        
                    {
                        let pictureURL = URL(string: data_imageUrl)!
                        let index = data_publishedDate.index(data_publishedDate.startIndex, offsetBy: 10)
                        let pDate = data_publishedDate.substring(to: index)
                        let date = self.dateFormatter.date(from: pDate)!
                        let price = Int(data_price)!
                        let imageData = try! Data(contentsOf: pictureURL)
                        let fetchedImage = UIImage(data: imageData)!
                        self.listings.append(Listing(data_link, data_address, price, date, fetchedImage, data_contract, data_area, data_size, data_seqNumber))
                    }
                    
                }
            }
        }
        
        self.sequenceNumberUpdate()
        
        print("data fetch done, sorting and then refreshing..")
        
        // sort data by date
        self.listings.sort { $0.publishedDate > $1.publishedDate }
        
        print("refreshing..")
        
        self.stopRefresherAndUpdateTitle()
        
        self.stopSpinner()
        
        self.refreshTableViewNow()
    }
    /*
    * MARK: - Table View Logic
    */
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        
        // Add to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(ViewController.refreshListings(sender:)), for: .valueChanged)

    }
    
    // Runs when at bottom of table view. Will add more listings according to the sequence number
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = listings.count - 1
        if indexPath.row == lastElement {
            // handle your logic here to get more items, add it to dataSource and reload tableview
            print("Bottom Of TABLE!")
            let seq = self.seqNumber
            if seq != nil && seq! > 0 {
                addListingsToBottom()
            }
        }
    }
    
    func refreshTableViewNow() {
        print("refreshing..")
        DispatchQueue.main.async(
            execute:
            {
                self.tableView.reloadData()
            }
        )
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("NUM OF ROWS: \(self.listings.count)")
        return self.listings.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ListingCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListingCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        // Slice date to yyyy-mm-dd format
        let dateString = "\(self.listings[indexPath.row].publishedDate)"
        let index = dateString.index(dateString.startIndex, offsetBy: 10)
        cell.publishedDate.text = dateString.substring(to: index)
        
        cell.area.text = self.listings[indexPath.row].area
        cell.price.text = "\(self.listings[indexPath.row].price) / month"
        cell.listingImage.image = self.listings[indexPath.row].listingImage
        cell.contract.text = self.listings[indexPath.row].contract
        
        return cell
    }
    
    // Method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
    // MARK: - Navigation
    
    // Send listing data to the detail view
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
