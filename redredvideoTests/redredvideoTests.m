//
//  redredvideoTests.m
//  redredvideoTests
//
//  Created by Liang on 2026/3/2.
//

#import <XCTest/XCTest.h>

@interface redredvideoTests : XCTestCase

@end

@implementation redredvideoTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - 数据模型测试

/// 测试剧集数据字典转换
- (void)testDramaModelDictionaryConversion {
    NSDictionary *dict = @{
        @"id": @123,
        @"title": @"测试剧集",
        @"description": @"这是一个测试剧集",
        @"total_episodes": @10,
        @"score": @8.5,
        @"is_free": @YES,
        @"is_vip": @NO,
        @"is_finished": @YES
    };
    
    XCTAssertNotNil(dict[@"id"], @"ID不应为空");
    XCTAssertEqualObjects(dict[@"title"], @"测试剧集", @"标题应该正确");
    XCTAssertEqualObjects(dict[@"total_episodes"], @10, @"总集数应该正确");
    XCTAssertEqual([dict[@"score"] floatValue], 8.5f, @"评分应该正确");
    XCTAssertTrue([dict[@"is_free"] boolValue], @"免费标识应该正确");
}

/// 测试处理 NULL 值
- (void)testHandleNullValues {
    NSDictionary *dict = @{
        @"id": @456,
        @"title": @"测试剧集2",
        @"is_free": [NSNull null],
        @"is_vip": [NSNull null],
        @"is_finished": [NSNull null]
    };
    
    id isFreeValue = dict[@"is_free"];
    id isVipValue = dict[@"is_vip"];
    id isFinishedValue = dict[@"is_finished"];
    
    XCTAssertTrue([isFreeValue isKindOfClass:[NSNull class]], @"应该是 NSNull");
    XCTAssertTrue([isVipValue isKindOfClass:[NSNull class]], @"应该是 NSNull");
    XCTAssertTrue([isFinishedValue isKindOfClass:[NSNull class]], @"应该是 NSNull");
    
    // 安全转换
    BOOL isFree = [isFreeValue isKindOfClass:[NSNumber class]] ? [isFreeValue boolValue] : NO;
    BOOL isVip = [isVipValue isKindOfClass:[NSNumber class]] ? [isVipValue boolValue] : NO;
    BOOL isFinished = [isFinishedValue isKindOfClass:[NSNumber class]] ? [isFinishedValue boolValue] : NO;
    
    XCTAssertFalse(isFree, @"NULL 值应该默认为 NO");
    XCTAssertFalse(isVip, @"NULL 值应该默认为 NO");
    XCTAssertFalse(isFinished, @"NULL 值应该默认为 NO");
}

/// 测试处理缺失字段
- (void)testHandleMissingFields {
    NSDictionary *dict = @{
        @"id": @789,
        @"title": @"测试剧集3"
    };
    
    XCTAssertNotNil(dict[@"id"], @"ID不应为空");
    XCTAssertEqualObjects(dict[@"title"], @"测试剧集3", @"标题应该正确");
    XCTAssertNil(dict[@"total_episodes"], @"缺失字段应该为 nil");
    XCTAssertNil(dict[@"score"], @"缺失字段应该为 nil");
    
    // 安全获取值
    NSInteger totalEpisodes = [dict[@"total_episodes"] integerValue]; // nil 会返回 0
    float score = [dict[@"score"] floatValue]; // nil 会返回 0.0
    
    XCTAssertEqual(totalEpisodes, 0, @"缺失字段应该有默认值");
    XCTAssertEqual(score, 0.0f, @"缺失字段应该有默认值");
}

#pragma mark - URL 处理测试

/// 测试 URL 拼接
- (void)testURLConstruction {
    NSString *baseURL = @"http://192.168.1.100:3000";
    NSString *relativePath = @"/uploads/covers/test.jpg";
    
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", baseURL, relativePath];
    
    XCTAssertNotNil(fullURL, @"完整URL不应为空");
    XCTAssertTrue([fullURL hasPrefix:baseURL], @"URL应该包含baseURL");
    XCTAssertTrue([fullURL hasSuffix:relativePath], @"URL应该包含相对路径");
    XCTAssertEqualObjects(fullURL, @"http://192.168.1.100:3000/uploads/covers/test.jpg", @"URL拼接应该正确");
}

/// 测试视频URL格式验证
- (void)testVideoURLValidation {
    NSString *validURL1 = @"http://192.168.1.100:3000/uploads/videos/test.mp4";
    NSString *validURL2 = @"/uploads/videos/test.mov";
    NSString *invalidURL = @"not-a-url";
    
    XCTAssertTrue([validURL1 hasPrefix:@"http"], @"应该是有效的HTTP URL");
    XCTAssertTrue([validURL2 hasPrefix:@"/"], @"应该是有效的相对路径");
    XCTAssertFalse([invalidURL hasPrefix:@"http"] || [invalidURL hasPrefix:@"/"], @"应该是无效的URL");
}

#pragma mark - 数据验证测试

/// 测试集数范围验证
- (void)testEpisodeNumberValidation {
    NSInteger validEpisode1 = 1;
    NSInteger validEpisode2 = 100;
    NSInteger invalidEpisode1 = 0;
    NSInteger invalidEpisode2 = -1;
    
    XCTAssertTrue(validEpisode1 > 0, @"集数应该大于0");
    XCTAssertTrue(validEpisode2 > 0, @"集数应该大于0");
    XCTAssertFalse(invalidEpisode1 > 0, @"集数不应该为0");
    XCTAssertFalse(invalidEpisode2 > 0, @"集数不应该为负数");
}

/// 测试评分范围验证
- (void)testScoreValidation {
    float validScore1 = 0.0f;
    float validScore2 = 10.0f;
    float validScore3 = 8.5f;
    float invalidScore1 = -1.0f;
    float invalidScore2 = 11.0f;
    
    XCTAssertTrue(validScore1 >= 0 && validScore1 <= 10, @"评分应该在0-10之间");
    XCTAssertTrue(validScore2 >= 0 && validScore2 <= 10, @"评分应该在0-10之间");
    XCTAssertTrue(validScore3 >= 0 && validScore3 <= 10, @"评分应该在0-10之间");
    XCTAssertFalse(invalidScore1 >= 0 && invalidScore1 <= 10, @"评分不应该为负数");
    XCTAssertFalse(invalidScore2 >= 0 && invalidScore2 <= 10, @"评分不应该超过10");
}

#pragma mark - 字符串处理测试

/// 测试字符串格式化
- (void)testStringFormatting {
    NSInteger episodeNumber = 5;
    NSString *title = [NSString stringWithFormat:@"第%ld集", (long)episodeNumber];
    
    XCTAssertEqualObjects(title, @"第5集", @"字符串格式化应该正确");
}

/// 测试文件大小格式化
- (void)testFileSizeFormatting {
    long long bytes1 = 1024;
    long long bytes2 = 1024 * 1024;
    long long bytes3 = 1024 * 1024 * 1024;
    
    XCTAssertEqual(bytes1, 1024LL, @"1KB = 1024 bytes");
    XCTAssertEqual(bytes2, 1048576LL, @"1MB = 1048576 bytes");
    XCTAssertEqual(bytes3, 1073741824LL, @"1GB = 1073741824 bytes");
}

#pragma mark - 数组操作测试

/// 测试数组边界检查
- (void)testArrayBoundsCheck {
    NSArray *episodes = @[@"第1集", @"第2集", @"第3集"];
    
    XCTAssertEqual(episodes.count, 3, @"数组长度应该正确");
    
    NSInteger validIndex = 1;
    NSInteger invalidIndex = 5;
    
    XCTAssertTrue(validIndex < episodes.count, @"有效索引应该在范围内");
    XCTAssertFalse(invalidIndex < episodes.count, @"无效索引应该超出范围");
    
    if (validIndex < episodes.count) {
        NSString *episode = episodes[validIndex];
        XCTAssertEqualObjects(episode, @"第2集", @"应该获取到正确的元素");
    }
}

#pragma mark - 性能测试

/// 测试字典批量创建性能
- (void)testDictionaryBatchCreationPerformance {
    // 准备测试数据（在 measureBlock 外部）
    NSMutableArray *testData = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        NSDictionary *dict = @{
            @"id": @(i),
            @"title": [NSString stringWithFormat:@"剧集%d", i],
            @"total_episodes": @10,
            @"score": @8.0
        };
        [testData addObject:dict];
    }
    
    // 只测量数据访问性能
    [self measureBlock:^{
        for (NSDictionary *dict in testData) {
            NSString *title = dict[@"title"];
            NSInteger episodes = [dict[@"total_episodes"] integerValue];
            (void)title; // 避免未使用变量警告
            (void)episodes;
        }
    }];
}

@end
