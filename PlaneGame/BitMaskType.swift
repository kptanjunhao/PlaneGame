//
//  BitMaskType.swift
//  PlaneGame
//
//  Created by 谭钧豪 on 16/2/10.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

class BitMaskType {
    class var plane:UInt32 {
        return 1<<0
    }
    class var bullet:UInt32 {
        return 1<<1
    }
    class var enemy:UInt32 {
        return 1<<2
    }
    class var weapon:UInt32{
        return 1<<3
    }
    class var addlife:UInt32{
        return 1<<4
    }
}