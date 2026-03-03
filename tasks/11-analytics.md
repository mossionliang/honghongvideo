# 数据埋点

> App端埋点SDK + 全链路事件定义 + 上报管道

---

### EVT-001 iOS端埋点SDK封装
- **优先级**: P0
- **预估工时**: 4天
- **依赖**: NET-001
- **描述**: 封装iOS端通用埋点SDK，支持事件队列管理、批量上报、失败重试、离线缓存。
- **技术要点**:
  - 单例管理：RRAnalyticsSDK 全局实例
  - 事件队列：内存队列 + SQLite 持久化，满50条或每30秒触发上报
  - 批量上报：gzip 压缩 + 批量 JSON 数组
  - 失败重试：指数退避，最多3次
  - 离线缓存：无网络时存本地，恢复网络后自动上报
  - 公共参数：device_id, user_id, session_id, app_version, os_version, network_type, timestamp
- **涉及文件**: `redredvideo/Analytics/RRAnalyticsSDK.h/.m`, `redredvideo/Analytics/RREventQueue.h/.m`
- **验收标准**:
  - [ ] 事件采集不丢失
  - [ ] 离线缓存恢复上报
  - [ ] 批量上报减少请求数
  - [ ] 内存占用合理（<5MB）

### EVT-002 内容曝光事件
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: EVT-001
- **描述**: 在Feed流/推荐列表中，短剧卡片可见面积>=50%且持续>=1秒时上报曝光事件。
- **技术要点**:
  - 可见性检测：UICollectionView 滚动监听 + 可见区域计算
  - 去重：同一 session 内同一内容只上报一次
  - 参数：drama_id, source_page, position, recommendation_id
- **涉及文件**: `redredvideo/Analytics/Events/RRExposureTracker.h/.m`
- **验收标准**:
  - [ ] 50%面积+1秒阈值准确
  - [ ] 去重逻辑正确

### EVT-003 内容点击事件
- **优先级**: P0
- **预估工时**: 0.5天
- **依赖**: EVT-001
- **描述**: 用户点击短剧卡片时上报。
- **技术要点**:
  - 参数：drama_id, source_page, position, click_area(poster/title/tag), recommendation_id
- **涉及文件**: `redredvideo/Analytics/Events/RRClickEvent.h/.m`
- **验收标准**:
  - [ ] 点击事件100%触发
  - [ ] 来源页面和位置准确

### EVT-004 起播事件
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: EVT-001
- **描述**: 视频首帧渲染完成时上报起播事件。
- **技术要点**:
  - 首帧时间：从用户点击到首帧渲染的耗时
  - 参数：drama_id, episode_id, load_duration_ms, source(detail/feed/continue), quality, network_type
- **涉及文件**: `redredvideo/Analytics/Events/RRPlayStartEvent.h/.m`
- **验收标准**:
  - [ ] 首帧时间统计准确
  - [ ] 各来源正确标记

### EVT-005 有效播放事件
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: EVT-001
- **描述**: 播放时长>=30秒时上报有效播放事件（计费核心事件）。
- **技术要点**:
  - 时长统计：实际播放时长（排除暂停、缓冲）
  - 前台检测：App进后台时暂停计时
  - 倍速处理：2x倍速播放30秒 = 实际15秒，不算有效
  - 参数：drama_id, episode_id, play_duration_ms, quality, is_foreground, playback_speed
- **涉及文件**: `redredvideo/Analytics/Events/RRValidPlayEvent.h/.m`
- **验收标准**:
  - [ ] 30秒阈值准确
  - [ ] 后台时间不计入
  - [ ] 倍速正确处理

### EVT-006 完播事件
- **优先级**: P0
- **预估工时**: 0.5天
- **依赖**: EVT-001
- **描述**: 单集播放完成时上报完播事件。
- **技术要点**:
  - 完播定义：播放进度>=95%（考虑片尾曲提前切换）
  - 参数：drama_id, episode_id, total_duration, actual_watch_duration, completion_rate, skipped_intro, skipped_outro
- **涉及文件**: `redredvideo/Analytics/Events/RRCompletionEvent.h/.m`
- **验收标准**:
  - [ ] 95%阈值准确
  - [ ] 完播率计算正确

### EVT-007 追剧/收藏事件
- **优先级**: P1
- **预估工时**: 0.5天
- **依赖**: EVT-001
- **描述**: 用户追剧/取消追剧、收藏/取消收藏时上报。
- **技术要点**:
  - 参数：drama_id, action(follow/unfollow/favorite/unfavorite), source_page
- **涉及文件**: `redredvideo/Analytics/Events/RRInteractionEvent.h/.m`
- **验收标准**:
  - [ ] 操作事件正确上报
  - [ ] 取消操作也记录

### EVT-008 分享事件
- **优先级**: P1
- **预估工时**: 0.5天
- **依赖**: EVT-001
- **描述**: 用户分享短剧时上报。
- **技术要点**:
  - 参数：drama_id, episode_id, share_channel(wechat/qq/weibo/link/poster), share_result(success/cancel/fail)
- **涉及文件**: `redredvideo/Analytics/Events/RRShareEvent.h/.m`
- **验收标准**:
  - [ ] 分享渠道准确
  - [ ] 分享结果正确记录

### EVT-009 广告事件
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: EVT-001
- **描述**: 广告展示、点击、完成观看、跳过时上报（计费核心事件）。
- **技术要点**:
  - 事件类型：impression(展示) / click(点击) / complete(完成) / skip(跳过)
  - 参数：ad_id, ad_type(pre/mid/post), drama_id, episode_id, ecpm, duration, click_position
  - 防重复：同一广告展示只上报一次 impression
- **涉及文件**: `redredvideo/Analytics/Events/RRAdEvent.h/.m`
- **验收标准**:
  - [ ] 四种事件类型正确上报
  - [ ] eCPM 正确回传
  - [ ] 防重复机制生效

### EVT-010 付费链路事件
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: EVT-001
- **描述**: 完整付费链路埋点：到达付费页 → 选择商品 → 发起支付 → 支付成功/失败 → 退款。
- **技术要点**:
  - 漏斗事件：pay_page_view → product_select → pay_initiate → pay_success / pay_fail → refund
  - 参数：order_id, product_type(episode/drama/membership), price, payment_method
  - 转化率计算：每一步的转化率
- **涉及文件**: `redredvideo/Analytics/Events/RRPaymentEvent.h/.m`
- **验收标准**:
  - [ ] 漏斗各步骤完整
  - [ ] 支付结果准确
  - [ ] 可计算各步转化率

### EVT-011 反作弊特征采集
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: EVT-001, FRD-001
- **描述**: 采集用于反作弊分析的设备和行为特征。
- **技术要点**:
  - 设备特征：设备指纹、越狱检测、模拟器检测、代理检测
  - 行为序列：播放行为时间序列（快速切集模式、异常播放速率）
  - IP信息：IP地址、运营商、是否代理/VPN
  - 上报频率：每个 session 上报一次设备特征，行为序列实时上报
- **涉及文件**: `redredvideo/Analytics/Events/RRAntiFraudEvent.h/.m`
- **验收标准**:
  - [ ] 设备特征采集完整
  - [ ] 越狱/模拟器检测准确
  - [ ] 行为序列时间戳精确

### EVT-012 埋点数据上报队列
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: EVT-001
- **描述**: 优化埋点数据上报策略，区分 WiFi 和蜂窝网络不同的上报策略。
- **技术要点**:
  - WiFi：实时批量上报（50条或30秒）
  - 蜂窝：延迟上报（200条或5分钟），减少流量消耗
  - 本地存储：SQLite，最多缓存10000条，超过时丢弃最旧的
  - 压缩：gzip 压缩请求体
  - 优先级：计费事件（播放/广告/付费）优先上报
- **涉及文件**: `redredvideo/Analytics/RREventQueue.h/.m`, `redredvideo/Analytics/RRUploadStrategy.h/.m`
- **验收标准**:
  - [ ] WiFi/蜂窝策略区分生效
  - [ ] 本地缓存上限保护
  - [ ] 优先级队列正确
  - [ ] 数据不丢失
