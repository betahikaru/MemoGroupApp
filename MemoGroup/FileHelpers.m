//
//  FileHelpers.m
//  Homepwner
//
//  Created by 鈴木 光 on 2012/11/25.
//  Copyright (c) 2012年 鈴木 光. All rights reserved.
//

#import "FileHelpers.h"

// ファイル名を渡すとDocumentsディレクトリ内にあるファイルへのフルパスを構築する
NSString *pathInDocumentDirectory(NSString *fileName)
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    // Documentsディレクトリを指定
                                        NSUserDomainMask,
                                        YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // 取得したディレクトリに、渡されたファイル名をつけて返す
    return [documentDirectory stringByAppendingPathComponent:fileName];
}
