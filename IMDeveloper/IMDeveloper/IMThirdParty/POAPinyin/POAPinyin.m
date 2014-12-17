//
//  POAPinyin.m
//  POA
//
//  Created by haung he on 11-7-18.
//  Copyright 2011年 huanghe. All rights reserved.
//

#import "POAPinyin.h"
//#import "RegexKitLite.h"


#import "POAHead.h"






@implementation POAPinyin

static short *cache = NULL;
static short *cache2 = NULL;
static int cacheHigh = 0;
static int cacheLow = 0;



+ (void)clearCache {
    if (cache) {
        free(cache);
        cache = NULL;
    }
}

+(void)initCache
{
    if (cache2 != NULL) {
        return;
    }
    int pycount = sizeof(pinyinTable) / sizeof(pinyinTableCell);
        
        unsigned int max = 0, min = 0xffffffff;
        for (int i = 0; i < pycount; i++) {
            pinyinTableCell pycell = pinyinTable[i];
            NSString *hz = pycell.hanzi;
            int hzCount = [hz length];
            for (int j = 0; j < hzCount; j++) {
                unichar c = [hz characterAtIndex:j];
                max = MAX(max, c);
                min = MIN(min, c);
            }
        }
        cacheLow = min;
        cacheHigh = max;
        
    NSUInteger cacheLength = cacheHigh - cacheLow + 1;
        
    cache2 = malloc(cacheLength * sizeof(pinyinTableCell *));
        
    for (int i = 0; i < pycount; i++) {
        pinyinTableCell pycell = pinyinTable[i];
        NSString *hz = pycell.hanzi;
        int hzCount = [hz length];
        for (int j = 0; j < hzCount; j++) {
            unichar c = [hz characterAtIndex:j];
            cache2[c - cacheLow] = i;
        }
    }
    
}

+(NSString*) stringConvert:(NSString*)hzString
{
    [POAPinyin initCache];
    int hzLength = [hzString length];
    
    NSMutableString *string = [NSMutableString string];
    
//    for (int i = 0; i < hzLength; i++) {
//        unichar c = [hzString characterAtIndex:i];
//        if (c >= chcheLow && c <= cacheHight) {
//            int pos = cache[c - chcheLow];
//            pinyinTableCell pycell = pinyinTable[pos];
//            [string appendFormat:@"%@", pycell.pinyin];    
//            continue;
//        }
//        else
//            [string appendFormat:@"%@", [NSString stringWithCharacters:&c length:1]];
//    }

//    int beginRang = 0;
    for (int i = 0; i < hzLength; i++) {
        unichar c = [hzString characterAtIndex:i];
        if (c >= cacheLow && c <= cacheHigh) {
            int pos = cache[c - cacheLow];
            pinyinTableCell pycell = pinyinTable[pos];
            [string appendFormat:@"%@", pycell.pinyin];    
            continue;
        }
        else
            [string appendFormat:@"%@", [hzString substringWithRange:NSMakeRange(i, 1)]];
    }
    
    return [string uppercaseString];
    
}

+ (NSString *)quickConvert:(NSString *)hzString {
    static unsigned int cacheFloor = 0xffffffff;
    static unsigned int cacheCeil = 0;
    
    //  cache
    if (cache == NULL) {
        int pycount = sizeof(pinyinTable) / sizeof(pinyinTableCell);
        
        if (cacheCeil == 0 && cacheFloor == 0xffffffff) {
            unsigned int max = 0, min = 0xffffffff;
            for (int i = 0; i < pycount; i++) {
                pinyinTableCell pycell = pinyinTable[i];
                NSString *hz = pycell.hanzi;
                int hzCount = [hz length];
                for (int j = 0; j < hzCount; j++) {
                    unichar c = [hz characterAtIndex:j];
                    max = MAX(max, c);
                    min = MIN(min, c);
                }
            }
            cacheFloor = min;
            cacheCeil = max;
        }

        NSUInteger cacheLength = cacheCeil - cacheFloor + 1;
        
        cache = malloc(cacheLength * sizeof(pinyinTableCell *));
        
        for (int i = 0; i < pycount; i++) {
            pinyinTableCell pycell = pinyinTable[i];
            NSString *hz = pycell.hanzi;
            int hzCount = [hz length];
            for (int j = 0; j < hzCount; j++) {
                unichar c = [hz characterAtIndex:j];
                cache[c - cacheFloor] = i;
            }
        }
    }
    
    int hzLength = [hzString length];
    
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i < hzLength; i++) {
        unichar c = [hzString characterAtIndex:i];
        if (c < 0xff) {
            [string appendFormat:@"%c", c];
            continue;
        }
        
        NSInteger cell = c - cacheFloor;
        if (cell < 0 || cell > cacheCeil - cacheFloor) {
            continue;
        }
        int pos = cache[c - cacheFloor];
        pinyinTableCell pycell = pinyinTable[pos];
        [string appendFormat:@"%@", pycell.pinyin];
    }
    
    return [string uppercaseString];
}

//输入中文，返回拼音。
+ (NSString *) convert:(NSString *) hzString
{
    

    NSString * pyString = @"";
 //   int chrAsc = 0;
  //  int i1 = 0;
  //  int i2 = 0;
    
   for (int j = 0; j < [hzString length]; j++)
   {
        NSRange rang;
        rang.location = j;
        rang.length = 1;
    
       NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
       NSData *data = [[hzString substringWithRange:rang] dataUsingEncoding:enc];
       
       NSRange zrang;
       zrang.location = 1;
       zrang.length = [[data description] length] -2;
       NSString *zi =  [[data description] substringWithRange:zrang];
      // NSLog(@"%@",zi);
       
       if([zi length]<4){
           pyString = [pyString stringByAppendingFormat:@"%@",[hzString substringWithRange:rang]];
       
       }
       
      const unsigned char *byte = [data bytes];
       
       int bh = byte[0] - 0xA0;
       
       
       if((0x10 <= bh) && (bh <= 0x57))//是gb2312汉字
       {
           bool isFind = false;
           for (int j = 0; j < pyCount; j++)
           {
              NSRange  tRang = [pinyinTable[j].hanzi rangeOfString:[hzString substringWithRange:rang]];
              
               if (tRang.location != NSNotFound)
               {
                   pyString = [pyString stringByAppendingFormat:@"%@",pinyinTable[j].pinyin];
                   isFind = true;
                   break;
               }
             
           }
           if (!isFind){
                pyString = [pyString stringByAppendingFormat:@"%@",[hzString substringWithRange:rang]];
           }
           
       }
       else{
           pyString = [pyString stringByAppendingFormat:@"%@",[hzString substringWithRange:rang]];
       }

       
           
   }
    
    return [pyString uppercaseString];
    

}


@end
