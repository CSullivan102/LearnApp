//
//  TopicConfigTableViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/25/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit

protocol TopicConfigTableViewControllerDelegate {
    func didSelectTopic(topic: Topic)
}

class TopicConfigTableViewController: UITableViewController {

    var delegate: TopicConfigTableViewControllerDelegate?
    var topics: [Topic]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView?.backgroundColor = UIColor.clearColor()
        tableView.backgroundView?.opaque = false
        tableView.backgroundColor = UIColor.clearColor()
        tableView.opaque = false
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let topics = topics
        else { fatalError("Trying to display topics config table view without topics") }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = topics[indexPath.row].name
        cell.contentView.opaque = false
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let topics = topics
        else { fatalError("Picking topics in config table view with nil topics?") }
        
        delegate?.didSelectTopic(topics[indexPath.row])
    }
}
