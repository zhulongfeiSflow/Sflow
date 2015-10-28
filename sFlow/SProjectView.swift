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
    
    let hackerNewsApiUrl = "http://218.75.65.122:4002/project"
    
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
        
        self.setupRefresh()
        
        loadDataSource()
        
    }
    
    //刷新函数
    func setupRefresh(){
        self.tableView.addHeaderWithCallback({
            
            //refresh data here
            self.loadDataSource()
            
            let delayInSeconds:Int64 = 1000000000  * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
            })
        })
        
        self.tableView.addFooterWithCallback({
            
            //add data here
            self.loadDataSource()
            
            let delayInSeconds:Int64 = 1000000000 * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
                //self.tableView.setFooterHidden(true)
            })
        })
    }
    
    func loadDataSource() {
//        self.refreshControl!.beginRefreshing()
        
//        var currentNewsDataSource = NSMutableArray()
//        let proNames = [ ("杨家沟的天", 1), ("珍珠港", 2), ("诱狼3D", 3), ("RYRY_R1", 4), ("斯大林格勒", 5)]
//        for (name, id) in proNames{
//            let newsItem = XHNewsItem()
//            newsItem.newsTitle = name
//            newsItem.newsID = "\(id)"
//            currentNewsDataSource.addObject(newsItem)
//        }
//        println(proNames)
//        self.dataSource = currentNewsDataSource
//        self.refreshControl!.endRefreshing()
        
        var loadURL = NSURL(string:hackerNewsApiUrl)
        var request = NSURLRequest(URL: loadURL!)
        var loadDataSourceQueue = NSOperationQueue();
        
        NSURLConnection.sendAsynchronousRequest(request, queue: loadDataSourceQueue, completionHandler: { response, data, error in
            if (error != nil) {
                println(error)
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.refreshControl!.endRefreshing()
//                })
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
//                println( json )
                var  names = String()
                var currentNewsDataSource = NSMutableArray()
                for (_, currentNews : AnyObject) in json { //"_"下划线意思是忽略key的AnyObject
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["name"] as! NSString
                    newsItem.newsID = currentNews["id"] as! NSNumber
                    currentNewsDataSource.addObject(newsItem)
                    names +=  " \(newsItem.newsTitle)"
                }
                println( names )
                
                names = String()
                for (key, value) in self.selectedProjectIdList {
                    names += value
                }
                println( names )
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.dataSource = currentNewsDataSource
                    self.tableView.reloadData()
//                    self.refreshControl!.endRefreshing()
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
            
            for (key, value) in selectedProjectIdList {
                if projectIds.isEmpty {
                    projectIds = String(key)
                } else {
                    projectIds += "," + String(key)
                }
            }
            if selectedProjectIdList.count > 0 {
                
                //open the statistics page
                var webView = SprogressStatisticsView(projectIds: projectIds)
                println( projectIds )
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
        
        
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
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
        println("aa")
    }
    
    //选择一行
    override func tableView(tableView: (UITableView!), didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if self.tableView!.editing {
            var row=indexPath.row as Int
            var data=self.dataSource[row] as! XHNewsItem
            selectedProjectIdList[ data.newsID as Int ] = data.newsTitle as String
            
            println( "Select \(data.newsTitle) \(data.newsID)" )
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
            var row=indexPath.row as Int
            var data=self.dataSource[row] as! XHNewsItem
            selectedProjectIdList.removeValueForKey(data.newsID as Int)
            
            println( "Deselect \(data.newsTitle) \(data.newsID)" )
        }
    }
    
    //编辑模式设为多选
    override func tableView(tableView: (UITableView!), editingStyleForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    
}

