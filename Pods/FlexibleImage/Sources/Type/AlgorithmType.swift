//
//  AlgorithmType.swift
//  Test Project
//
//  Created by Kawoou on 2017. 5. 13..
//  Copyright © 2017년 test. All rights reserved.
//

public typealias AlgorithmType = (
    _ x: Int,
    _ y: Int,
    _ color: ColorType,
    _ width: Int,
    _ height: Int,
    _ memoryPool: UnsafeMutablePointer<UInt8>
) -> ColorType
