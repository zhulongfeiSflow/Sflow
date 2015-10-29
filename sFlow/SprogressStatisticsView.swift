//
//  SprogressStatisticsView.swift
//  Sflow
//
//  Created by 朱龙飞 on 15/8/27.
//  Copyright (c) 2015年 朱龙飞. All rights reserved.
//

import Foundation
import UIKit

class SprogressStatisticsView: UIViewController {
    
    //data
    var projectIds: String?//选择的项目ids
    
    //UI
    var segmentedControl: UISegmentedControl?//时间过滤按钮空控件
    var precedureView: SPrecedureView?//统计信息界面
    
    init(projectIds initIds: String){
        self.projectIds = initIds
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:0.5,green:0.5,blue:0.5,alpha:255)
        self.view.backgroundColor = UIColor.whiteColor()
        segmentedControl = UISegmentedControl(items: ["今日","昨日","本周","上周","总进度"])
        segmentedControl!.frame = CGRectMake( 0, 70, self.view.bounds.size.width, 30 )
        segmentedControl!.addTarget(self, action: "segmentChanged:", forControlEvents: UIControlEvents.ValueChanged)
        segmentedControl!.selectedSegmentIndex = 0
        self.view.addSubview(segmentedControl!)//时间过滤按钮
        
        precedureView = SPrecedureView( projectIds: self.projectIds! )
        precedureView!.view.frame = CGRectMake( 0, 100, self.view.bounds.size.width, self.view.bounds.size.height - 100 )
        self.view.addSubview(precedureView!.view)//统计信息界面
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    func segmentChanged(segment: UISegmentedControl)
    {
        let index = segment.selectedSegmentIndex;
        
        switch (index) {
        case 0:
            self.precedureView?.m_time = "today"
            self.refresh()
        case 1:
            self.precedureView?.m_time = "yesterday"
            self.refresh()
        case 2:
            self.precedureView?.m_time = "thisweek"
            self.refresh()
        case 3:
            self.precedureView?.m_time = "lastweek"
            self.refresh()
        case 4:
            self.precedureView?.m_time = "all"
            self.refresh()
        default:
            break;
        }
    }

    func refresh() {
        self.precedureView!.loadResource()
    }

}
