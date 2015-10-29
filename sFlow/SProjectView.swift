//
//  SProjectView.swift
//  Sflow
//
//  Created by 朱龙飞 on 15/8/28.
//  Copyright (c) 2015年 朱龙飞. All rights reserved.
//

import Foundation
import UIKit

class SProjectView: UITableViewController {
    
    
    //选择的项目id
    var selectedProjectIdList = Dictionary<Int, String>()
    
    var dataSource = []
    
    var thumbQueue = NSOperationQueue()
    
    var hackerNewsApiUrl = "http://218.75.65.122:4002/project"
    
    override func viewWillDisappear(animated: Bool) {
        self.tableView!.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        //         self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let editButton = UIBarButtonItem(title: "选择项目" , style: UIBarButtonItemStyle.Plain, target: self, action: "selectionSlot:")
        self.navigationItem.rightBarButtonItem = editButton
        
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.addTarget(self, action: "loadDataSource", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        loadDataSource()
        
    }
    
    func loadDataSource() {
        self.refreshControl!.beginRefreshing()
        
        let loadURL = NSURL(string:hackerNewsApiUrl)
        let request = NSURLRequest(URL: loadURL!)
        let loadDataSourceQueue = NSOperationQueue();
        
        NSURLConnection.sendAsynchronousRequest(request, queue: loadDataSourceQueue, completionHandler: { response, data, error in
            if (error != nil) {
//                print(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl!.endRefreshing()
                })
            } else {
                let json = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
//                println( json )
                var names = String()
                let currentNewsDataSource = NSMutableArray()
                
                //数据遍历时乱序的
                for (key, currentNews) in json { //"_"下划线意思是忽略key的AnyObject
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["name"] as! NSString
                    newsItem.newsID = currentNews["id"] as! NSNumber
                    newsItem.dataId = key as! NSString
                    currentNewsDataSource.addObject(newsItem)
                    names +=  " \(newsItem.newsTitle)-\(key)"
                }
                print( names )
                //重新排序
                currentNewsDataSource.sortUsingComparator({ (s1:AnyObject!, s2:AnyObject!) -> NSComparisonResult in
                    let str1 = s1 as! XHNewsItem
                    let str2 = s2 as! XHNewsItem
                    return str1.dataId.localizedCompare(str2.dataId as String)
                })
                
                names = String()
                for (_, value) in self.selectedProjectIdList {
                    names += value
                }
                print( names )
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.dataSource = currentNewsDataSource
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                })
            }
        })
        
        
    }
    
    //选择项目后进入项目统计界面
    func selectionSlot(sender: AnyObject) {
        self.tableView!.setEditing(!self.tableView!.editing, animated: true)
        
        if self.tableView!.editing {
            self.navigationItem.rightBarButtonItem!.title = "确定"
            selectedProjectIdList = [:]//clear
            self.tableView!.reloadData()
        } else {
            self.navigationItem.rightBarButtonItem!.title = "选择项目"
            var projectIds = String()
            
            for (key, _) in selectedProjectIdList {
                if projectIds.isEmpty {
                    projectIds = String(key)
                } else {
                    projectIds += "," + String(key)
                }
            }
            if selectedProjectIdList.count > 0 {
                
                //open the statistics page
                let webView = SprogressStatisticsView(projectIds: projectIds)
                print( projectIds )
                //webView.detailID=data.newsID
                //取导航控制器,添加subView
                self.navigationController!.pushViewController(webView,animated:true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return dataSource.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        
        let newsItem = dataSource[indexPath.row] as! XHNewsItem
        cell.textLabel!.text = newsItem.newsTitle as String
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        if (selectedProjectIdList[ newsItem.newsID as Int ] != nil) {
            cell.backgroundColor = UIColor.greenColor()
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
//        println( "\(newsItem.newsTitle) \(newsItem.newsID)" )
        
        return cell
    }
    
    //行高
    override func tableView(tableView: (UITableView!), heightForRowAtIndexPath indexPath: (NSIndexPath!)) -> CGFloat {
        return 80
    }
    
    // #pragma mark - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("aa")
    }
    
    //选择一行
    override func tableView(tableView: (UITableView!), didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if self.tableView!.editing {
            let row=indexPath.row as Int
            let data=self.dataSource[row] as! XHNewsItem
            selectedProjectIdList[ data.newsID as Int ] = data.newsTitle as String
            
            print( "Select \(data.newsTitle) \(data.newsID)" )
        }
//        //入栈
//        
//        var webView = SprogressStatisticsView()
//        //webView.detailID=data.newsID
//        //取导航控制器,添加subView
//        self.navigationController!.pushViewController(webView,animated:true)
    }
    
    //释放一行
    override func tableView(tableView: (UITableView!), didDeselectRowAtIndexPath indexPath: NSIndexPath){
        
        if self.tableView!.editing {
            let row=indexPath.row as Int
            let data=self.dataSource[row] as! XHNewsItem
            selectedProjectIdList.removeValueForKey(data.newsID as Int)
            
            print( "Deselect \(data.newsTitle) \(data.newsID)" )
        }
    }
    
    //编辑模式设为多选
    override func tableView(tableView: (UITableView!), editingStyleForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    
}

