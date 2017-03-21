//
//  NumberToString.swift
//  SinoFI
//
//  Created by 刘 强 on 2017/3/21.
//  Copyright © 2017年 刘 强. All rights reserved.
//

import Foundation
class 数字转中文{
    //public 部分
    
    class func 小写(数字: Double) -> String {
        return convert(数字: 数字, 模式: 0)
    }
    
    class func 大写(数字: Double) -> String {
        return convert(数字: 数字, 模式: 1)
    }
    
    
    
    
    //禁止创建实例
    private init(){}
    
    private class func convert(数字: Double, 模式: Int) -> String {
        let 浮点偏差 = 0.0000000001
        let 四舍五入 = 0.005
        
        //防止数字超出范围则
        if 数字+浮点偏差+四舍五入 >= 10_0000_0000_0000 || 数字+浮点偏差+四舍五入 <= -10_0000_0000_0000 {
            return "⚠最高只能到“兆”位！"
        }
        
        //单位对照表
        let 单位对照表 = [
            00: "分", 01: "角", 02: "元", 03: "十", 04: "百",
            05: "千", 06: "万", 07: "十", 08: "百", 09: "千",
            10: "亿", 11: "十", 12: "百", 13: "千", 14: "兆"]
        
        //汉字对照表
        let 数字对照表 = [
            0: "零", 1: "一", 2: "二", 3: "三", 4: "四",
            5: "五", 6: "六", 7: "七", 8: "八", 9: "九"]
        
        //大写对照表
        let 大写对照表 = ["十": "拾", "百": "佰", "千": "仟", "一": "壹", "二": "贰", "三": "叁",
                               "四": "肆", "五": "伍", "六": "陆", "七": "柒", "八": "捌", "九": "玖"]
        
        
        
        
        //创建数组：数字对号入座
        var 数字队列 = [Int?](repeating: nil, count: 15)
        
        //辅助函数：得到最高位数字，返回数字及单位对应数字
        func 计算最高位( 数字: Double) -> (Int, Int)? {
            var 数字 = 数字
            let 浮点偏差 = 0.0000000001
            let 四舍五入 = 0.005
            数字 += 浮点偏差 + 四舍五入
            
            var 最高位数字: Int = 0
            var 最高位位数: Int = 0
            
            if 数字 >= 1 || 数字 <= -1 {
                最高位位数 = 1 //移到元右一位
                while 数字 >= 1 || 数字 <= -1 {
                    最高位位数 += 1
                    最高位数字 = Int(数字)
                    数字 /= 10
                }
            } else {
                最高位位数 = 2 //移到角左一位
                while 最高位数字 == 0 && 最高位位数 > 0 {
                    最高位位数 -= 1
                    数字 *= 10
                    最高位数字 = Int(数字)
                }
            }
            
            if 最高位数字 == 0 && 最高位位数 == 0 {
                return nil
            } else {
                return (Int(最高位数字), 最高位位数)
            }
        }
        
        //创建一个函数：将数字对号入座到数字队列
        func 对号入座( 数字: Double , 数字队列: inout [Int?]) {
            var 数字 = 数字
            while let (x, y) = 计算最高位(数字: 数字) {
                数字队列[y] = x
                //删除最高位
                数字 -= Double(x) * pow(10, Double(y)-2)
            }
        }
        
        
        
        //使用以上创建的函数，将数字填入对应的槽
        对号入座(数字: 数字, 数字队列: &数字队列)
        
        
        
        
        //判断process
        
        //如果数字队列中都是nil，即四舍五入后数字为0，则直接返回“零元整”
        var 数字为0 = true
        for item in 数字队列 {
            if let x = item {
                数字为0 = false
            }
        }
        if 数字为0 {
            return "零元整"
        }
        
        //创建一个数组，用来记录是否需要加零，默认为不要加
        var 需要加零 = [Bool](repeating: false, count: 15)
        //逐个进行判断是否需要加零
        //角、千、千万、千亿位永不需要加零，本程序设定的能够表示的最大位兆也不用判断
        //剩下的位数中如果某位有值而前一位没值的话，需要在前面加零
        var 最高位位数: Int?
        for (index, item) in 数字队列.enumerated() {
            if let x = item {//如果自身有值
                switch index {
                case 1, 5, 9, 13, 14: break//如果是角、千、千万、千亿、兆位则不需要进行判定
                default:
                    //如果前一位为nil，则说明需要加零
                    if 数字队列[index + 1] == nil {
                        需要加零[index] = true
                    }
                }
                最高位位数 = index
            }
        }
        //如果是最高位也不需要加零，将需要加零改为false
        if let x = 最高位位数 {
            需要加零[x] = false
        }
        
        
        
        //判断是否需要加“整”
        var 需要加整 = false
        if 数字队列[0] == nil {
            需要加整 = true
        }
        
        
        //判断是否需要加“元”
        var 需要加元 = false
        if 数字队列[2] == nil && 最高位位数! > 2 {
            需要加元 = true
        }
        
        
        //判断是否需要加“万”和“亿”
        var 需要加万 = false
        var 需要加亿 = false
        //如果最高位大于万，而且万到千万之间有非0值，而且万位为零，则需要加万
        if 最高位位数! > 6 && 数字队列[6] == nil {
            for x in 7...9 {
                if let temp = 数字队列[x] {
                    需要加万 = true
                }
            }
        }
        //如果最高位大于亿，而且亿到千亿之间有非0值，而且亿位为零，则需要加亿
        if 最高位位数! > 10 && 数字队列[10] == nil {
            for x in 11...13 {
                if let temp = 数字队列[x] {
                    需要加亿 = true
                }
            }
        }
        
        
        //组成string
        var str = String()
        
        //以下是对每一位逐个进行判断
        
        for (index, item) in 数字队列.enumerated() {
            
            var tempStr = String()//因为数字队列是倒序，所以需要一个临时string
            
            if let x = item {//如果有值
                //首先判断是否需要加零
                if 需要加零[index] {
                    tempStr += "零"
                }
                //然后将数字加入
                tempStr += 数字对照表[x]!
                //最后加上单位
                tempStr += 单位对照表[index]!
            }
            
            //判断是否需要加元
            if index == 2 && 需要加元 == true {
                tempStr = "元"
            }
            
            //判断是否需要加万
            if index == 6 && 需要加万 == true {
                tempStr = "万"
            }
            
            //判断是否需要加亿
            if index == 10 && 需要加亿 == true {
                tempStr = "亿"
            }
            
            str = tempStr + str
        }
        
        
        //在逐个判断完成后，判断是否需要加整
        if 需要加整 {
            str += "整"
        }
        
        
        if 模式 == 1{
            var str2 = ""
            
            for item in Array(str.characters) {
                if 大写对照表[String(item)] != nil {
                    str2 += 大写对照表[String(item)]!
                } else {
                    
                    str2 += String(item)
                }
            }
            return str2
        } else {
            return str
        }
        
        
    }
    
    
}
