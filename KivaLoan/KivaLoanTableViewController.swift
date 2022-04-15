//
//  KivaLoanTableViewController.swift
//  KivaLoan
//
//  Created by Simon Ng on 4/10/2016.
//  Updated by Simon Ng on 6/12/2021.
//  Copyright © 2022 AppCoda. All rights reserved.
//

import UIKit

struct Loan: Hashable {

    var name: String = ""
    var country: String = ""
    var use: String = ""
    var amount: Int = 0

}

enum Section {
    case all
}

class KivaLoanTableViewController: UITableViewController {
  
  private let kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
  private var loans = [Loan]()
  lazy var dataSource = configureDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.estimatedRowHeight = 92.0
    tableView.rowHeight = UITableView.automaticDimension
    getLatestLoans()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func getLatestLoans() {
    guard let loanUrl = URL(string: kivaLoanURL) else {
      return
    }
    
    let request = URLRequest(url: loanUrl)
    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      
      if let error = error {
        print(error)
        return
      }
      
      // Parse JSON data
      if let data = data {
        self.loans = self.parseJsonData(data: data)
        
        // Update table view's data
        OperationQueue.main.addOperation({
          self.updateSnapshot()
        })
      }
    })
    
    task.resume()
  }

  
  func parseJsonData(data: Data) -> [Loan] {

      var loans = [Loan]()

      do {
          let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary

          // Parse JSON data
          let jsonLoans = jsonResult?["loans"] as! [AnyObject]
          for jsonLoan in jsonLoans {
              var loan = Loan()
              loan.name = jsonLoan["name"] as! String
              loan.amount = jsonLoan["loan_amount"] as! Int
              loan.use = jsonLoan["use"] as! String
              let location = jsonLoan["location"] as! [String:AnyObject]
              loan.country = location["country"] as! String
              loans.append(loan)
          }

      } catch {
          print(error)
      }

      return loans
  }
  
  
  func configureDataSource() -> UITableViewDiffableDataSource<Section, Loan> {

      let cellIdentifier = "Cell"

      let dataSource = UITableViewDiffableDataSource<Section, Loan>(
          tableView: tableView,
          cellProvider: {  tableView, indexPath, loan in
              let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! KivaLoanTableViewCell

              cell.nameLabel.text = loan.name
              cell.countryLabel.text = loan.country
              cell.useLabel.text = loan.use
              cell.amountLabel.text = "$\(loan.amount)"

              return cell
          }
      )

      return dataSource
  }

  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("section:\(indexPath.section)\nrow:\(indexPath.row)")
  }
  
  func updateSnapshot(animatingChange: Bool = true) {

      // Create a snapshot and populate the data
      var snapshot = NSDiffableDataSourceSnapshot<Section, Loan>()
      snapshot.appendSections([.all])
      snapshot.appendItems(loans, toSection: .all)

    
      dataSource.apply(snapshot, animatingDifferences: animatingChange)
    
  }

}
