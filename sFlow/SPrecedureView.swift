//
//  SPrecedureView.swift
//  Sflow
//
//  Created by 朱龙飞 on 15/9/2.
//  Copyright (c) 2015年 朱龙飞. All rights reserved.
//

import Foundation
import UIKit

//html颜色转成 UIColor
func HexRGB(rgbValue:Int32)->UIColor {
    return UIColor(red: (CGFloat((rgbValue & 0xFF0000) >> 16))/255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8))/255.0, blue: (CGFloat((rgbValue & 0xFF)))/255.0, alpha: CGFloat(1))
}

class SPrecedureView: UITableViewController {
    
    var detailURL = "http://218.75.65.122:4002/progress?ids="//获取数据的链接
    var m_ids:String?//选中的项目ids
    
    var allnames:Dictionary<Int, [[String]] >? = Dictionary<Int, [[String]] >()//流程下的人员进度统计项
    var adHeaders:Dictionary<Int, [String]>? = Dictionary<Int, [String]>()//统计的流程项
    var m_time:String = "today"//统计过滤条件
    
    let colorMap=[
        "Footage": HexRGB(0x47d175),
        "Preprod": HexRGB(0xc24444),
        "Roto": HexRGB(0x0f9bb9),
        "3D": HexRGB(0x0a54bd),
        "Depth": HexRGB(0x1c72bd),
        "New View": HexRGB(0x398174),
        "Compensa": HexRGB(0x59a516),
        "Correction": HexRGB(0x03567c),
        
        "序列": HexRGB(0xf17721),
        "扫描": HexRGB(0x51a0d9),
        "定标": HexRGB(0x0a54bd),
        "对齐": HexRGB(0x4c6c6d),
        "调整": HexRGB(0x73149c),
        "贴图": HexRGB(0x19c233),
        
        "需求分析": HexRGB(0x3232ab),
        "方案设计": HexRGB(0xca7875),
        "代码实现": HexRGB(0x34b4b4),
        "测试": HexRGB(0xb12960),
        "发布": HexRGB(0x3aaa32)
    ]
    
    func loadResource() {
        var url = detailURL + m_ids! + "&date=\(m_time)"
        var loadURL = NSURL(string:url)
        var request = NSURLRequest(URL: loadURL!)
        var loadDataSourceQueue = NSOperationQueue();
//        println(url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: loadDataSourceQueue, completionHandler: { response, data, error in
            if (error != nil) {
                println(error)
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
                println( json )
                self.adHeaders!.removeAll(keepCapacity: true)
                self.allnames!.removeAll(keepCapacity: true)
                
                var k = 0
                for currentNews : AnyObject in json {
                    
                    var procedureTitle:[String] = [String]()
                    procedureTitle.append(currentNews["Procedure"] as! String)
                    procedureTitle.append( String(currentNews["Finished"] as! Int) )
                    
                    self.adHeaders![k] = procedureTitle
                    
                    var laborDetailList = [[String]]()
                    for labor: AnyObject in currentNews["Details"] as! NSArray {
                        var detail = [String]()
                        var name = labor["Name"] as! String
                        var group = labor["Group"] as! String
                        var time = labor["LogTime"] as! String
                        var finished = String(labor["Finished"] as! Int)
                        detail.append("\(name) \(group) \(time)")
                        detail.append(finished)
                        laborDetailList.append(detail)
                    }
                    self.allnames![k] = laborDetailList
                    
                    k++
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
        })
    }
    
    init(projectIds initIds: String){
        m_ids = initIds
        super.init(nibName:nil, bundle:nil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建表视图
//        self.tableView = UITableView(frame:self.view.frame, style:UITableViewStyle.Grouped)
//        self.tableView!.delegate = self
//        self.tableView!.dataSource = self
        
        //创建一个重用的单元格
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SwiftCell")
        
        self.setupRefresh()
        
        loadResource()
    }
    
    //刷新函数
    func setupRefresh(){
        self.tableView.addHeaderWithCallback({
            
            //refresh data here
            self.loadResource()
            
            let delayInSeconds:Int64 =  1000000000  * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
//                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
            })
        })
        
        self.tableView.addFooterWithCallback({
            
            //add data here
            self.loadResource()
            
            let delayInSeconds:Int64 = 1000000000 * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
//                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
                //self.tableView.setFooterHidden(true)
            })
        })
    }
    
    //返回分组数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.adHeaders!.count
    }
    
    //返回每组表格行数（也就是返回控件数）
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var data = self.allnames?[section]
        return data!.count
    }
    
    //组标题高度
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    //尾标题高度
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 30.0)) // Doesn't care about x, y offset
        var headers = self.adHeaders?[section]
        label.text = "  \(headers![0]) 完成：\(headers![1])"
        label.backgroundColor = UIColor(red: 0.867, green: 0.867, blue: 0.867, alpha: 1)
        return label
    }
    
    
    // UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
//    override func tableView(tableView:UITableView, titleForHeaderInSection
//        section:Int)->String
//    {
//        var headers =  self.adHeaders?[section]
//        return "\(headers![0]) 完成：\(headers![1])"
//    }
    
    // UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的尾部
//    override func tableView(tableView:UITableView, titleForFooterInSection
//        section:Int)->String
//    {
//        var data = self.allnames?[section]
//        return "有\(data!.count)个控件"
//    }
    
    
    //行高
//    override func tableView(tableView: (UITableView!), heightForRowAtIndexPath indexPath: (NSIndexPath!)) -> CGFloat {
//        return 80
//    }
    
    //创建各单元显示内容(创建参数indexPath指定的单元）
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //为了提供表格显示性能，已创建完成的单元需重复使用
        let identify:String = "SwiftCell"
        //同一形式的单元格重复使用，在声明时已注册
//        let cell = tableView.dequeueReusableCellWithIdentifier(identify, forIndexPath: indexPath) as! UITableViewCell
//        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identify)
        
        var secno = indexPath.section
        var data = self.allnames?[secno]
        
        cell.textLabel?.text = data![indexPath.row][0]
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        
        var headers = self.adHeaders?[secno]
        cell.backgroundColor = colorMap[headers![0]]
        
        cell.detailTextLabel?.text = data![indexPath.row][1]
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        
//        cell.layer.cornerRadius = 30
        
        return cell
    }
    
    // UITableViewDelegate 方法，处理列表项的选中事件
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: false)
//
//        var itemString = self.allnames![indexPath.section]![indexPath.row]
//        
//        var alertview = UIAlertView();
//        alertview.title = "提示!"
//        alertview.message = "你选中了【\(itemString)】";
//        alertview.addButtonWithTitle("确定")
//        alertview.show();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
}
