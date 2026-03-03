# 02 — 网络层与数据层

> iOS (Objective-C) | 共 10 个任务

---

## 1. 网络请求框架

### NET-001 统一网络请求框架
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: 无
- **描述**: 基于AFNetworking封装统一的网络请求管理器，支持GET/POST/PUT/DELETE，统一请求头注入、参数签名、日志打印、错误码解析。所有业务层网络请求通过此框架发出。
- **技术要点**: 
  - 基于AFHTTPSessionManager封装RRVHTTPClient单例
  - 统一请求头：User-Agent、App-Version、Device-ID、Platform(iOS)、Channel
  - 请求参数签名：timestamp + nonce + params排序拼接 + HMAC-SHA256签名
  - 响应统一解析：code/message/data三层结构，code!=0时封装为NSError
  - 支持请求重试（指数退避，最多3次）
  - 超时设置：普通接口15s，上传接口60s，下载接口120s
  - 网络状态监听（AFNetworkReachabilityManager）
  - Debug模式下打印请求/响应日志（cURL格式）
- **涉及文件**: 
  - `redredvideo/Network/RRVHTTPClient.h/.m` (新建)
  - `redredvideo/Network/RRVRequestSigner.h/.m` (新建)
  - `redredvideo/Network/RRVResponseParser.h/.m` (新建)
  - `redredvideo/Network/RRVNetworkLogger.h/.m` (新建)
  - `redredvideo/Network/RRVNetworkConfig.h/.m` (新建，配置baseURL等)
  - `Podfile` (添加AFNetworking依赖)
- **验收标准**:
  - [ ] GET/POST/PUT/DELETE四种方法均可正常使用
  - [ ] 请求头自动注入正确
  - [ ] 参数签名正确，服务端可验证通过
  - [ ] 错误码统一解析，业务层可直接获取错误信息
  - [ ] 网络异常时自动重试
  - [ ] Debug日志格式规范，Release不输出

---

### NET-002 API接口管理与版本控制
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: NET-001
- **描述**: 统一管理所有API接口地址，支持多环境切换（开发/测试/预发/生产）和API版本控制（v1/v2）。所有接口路径集中定义，避免硬编码分散在业务代码中。
- **技术要点**: 
  - RRVAPIRouter：所有接口路径的枚举/常量定义
  - 支持宏定义或plist配置切换环境
  - API版本控制：baseURL携带版本号（如/api/v1/）
  - 路径模板支持参数替换（如/drama/{drama_id}/episodes）
  - 编译期可选择环境（Debug=dev, Release=prod）
- **涉及文件**: 
  - `redredvideo/Network/RRVAPIRouter.h/.m` (新建)
  - `redredvideo/Network/RRVEnvironment.h/.m` (新建)
  - `redredvideo/Network/Config/dev.plist` (新建)
  - `redredvideo/Network/Config/prod.plist` (新建)
- **验收标准**:
  - [ ] 所有接口路径集中管理，无硬编码
  - [ ] 切换环境只需修改一处配置
  - [ ] 支持至少dev/test/staging/prod四个环境
  - [ ] API版本号可全局配置

---

### NET-003 Token认证与自动刷新
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: NET-001
- **描述**: 实现JWT Token认证机制。登录后获取access_token和refresh_token，请求自动携带access_token。token过期时自动使用refresh_token刷新，刷新期间的请求排队等待，刷新失败则踢回登录。
- **技术要点**: 
  - Token存储：Keychain保存access_token和refresh_token（不用NSUserDefaults）
  - 请求拦截器：在RRVHTTPClient的requestSerializer中自动注入Authorization头
  - 401检测：响应拦截器检测到401/token_expired时触发刷新流程
  - 刷新锁：使用dispatch_semaphore或NSLock确保同一时间只有一个刷新请求
  - 请求队列：刷新期间其他请求暂存队列，刷新成功后用新token重发
  - 刷新失败：清除token → 发送通知 → 跳转登录页
  - refresh_token也过期时强制重新登录
- **涉及文件**: 
  - `redredvideo/Network/Auth/RRVTokenManager.h/.m` (新建)
  - `redredvideo/Network/Auth/RRVAuthInterceptor.h/.m` (新建)
  - `redredvideo/Services/Keychain/RRVKeychainHelper.h/.m` (新建)
  - `redredvideo/Network/RRVHTTPClient.h/.m` (修改，添加拦截器)
- **验收标准**:
  - [ ] 登录成功后token正确存储到Keychain
  - [ ] 请求自动携带Authorization头
  - [ ] token过期后自动刷新，业务层无感知
  - [ ] 多个请求同时401时只触发一次刷新
  - [ ] 刷新成功后排队请求全部重发成功
  - [ ] refresh_token过期时正确踢回登录页
  - [ ] App卸载重装后token清除

---

### NET-004 文件上传管理器
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: NET-001
- **描述**: 封装文件上传管理器，支持图片和视频上传到OSS/服务端。支持上传进度回调、断点续传（大文件分片）、后台上传、上传队列管理。
- **技术要点**: 
  - 小文件（<5MB）：直接multipart/form-data上传到服务端
  - 大文件（≥5MB）：使用OSS SDK分片上传（先从服务端获取临时STS凭证）
  - 上传进度：NSProgress + block回调
  - 后台上传：使用NSURLSession的backgroundSessionConfiguration
  - 上传队列：NSOperationQueue控制并发数（最多3个同时上传）
  - 图片上传前压缩（质量0.7，最大尺寸1920px）
  - 视频上传前可选压缩（AVAssetExportSession）
- **涉及文件**: 
  - `redredvideo/Network/Upload/RRVUploadManager.h/.m` (新建)
  - `redredvideo/Network/Upload/RRVOSSUploader.h/.m` (新建)
  - `redredvideo/Network/Upload/RRVImageCompressor.h/.m` (新建)
  - `redredvideo/Network/Upload/RRVUploadTask.h/.m` (新建)
- **验收标准**:
  - [ ] 图片上传成功并返回URL
  - [ ] 大文件分片上传成功
  - [ ] 上传进度实时回调
  - [ ] 上传失败可重试
  - [ ] App切后台后上传继续进行
  - [ ] 并发控制正确，不超过最大并发数

---

### NET-005 缓存策略管理
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: NET-001
- **描述**: 实现网络请求缓存策略，支持多种缓存模式。高频但不常变的数据（如分类列表、配置）使用缓存加速首屏加载，用户敏感数据（如余额、订单）不缓存。
- **技术要点**: 
  - 缓存模式枚举：
    - `CacheOnly`：仅取缓存
    - `NetworkOnly`：仅请求网络
    - `CacheFirst`：先返回缓存再请求网络更新
    - `NetworkFirst`：先请求网络，失败时降级缓存
  - 缓存存储：磁盘缓存（基于URL+参数MD5为key）
  - 缓存有效期：每个接口可单独配置（如分类列表1小时，配置信息24小时）
  - 缓存大小限制：磁盘最大100MB，LRU淘汰
  - 图片缓存使用SDWebImage自带的缓存机制
- **涉及文件**: 
  - `redredvideo/Network/Cache/RRVNetworkCache.h/.m` (新建)
  - `redredvideo/Network/Cache/RRVCachePolicy.h` (新建，枚举定义)
  - `redredvideo/Network/RRVHTTPClient.h/.m` (修改，支持缓存参数)
- **验收标准**:
  - [ ] CacheFirst模式下首屏秒开（无网络延迟）
  - [ ] 缓存过期后自动从网络更新
  - [ ] 缓存大小不超过限制
  - [ ] 用户敏感接口不走缓存
  - [ ] 可手动清除全部缓存

---

## 2. 本地数据层

### NET-006 本地数据库（CoreData/FMDB）
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: 无
- **描述**: 搭建本地数据库层，用于存储播放历史、下载记录、搜索历史、用户偏好等离线数据。选择CoreData或FMDB作为底层方案，封装统一的数据访问接口（DAO层）。
- **技术要点**: 
  - 推荐方案：FMDB（更轻量，OC项目更常用）
  - 数据库版本管理：创建migration机制，版本升级时自动执行SQL
  - DAO层封装：每个表对应一个DAO类，提供CRUD方法
  - 线程安全：使用FMDatabaseQueue保证多线程安全
  - 表设计：
    - `play_history`：drama_id, episode_id, progress, updated_at
    - `search_history`：keyword, searched_at
    - `download_record`：drama_id, episode_id, file_path, status, size
    - `user_preference`：key, value
  - 数据库文件路径：Documents/redredvideo.db
- **涉及文件**: 
  - `redredvideo/Services/Storage/RRVDatabaseManager.h/.m` (新建)
  - `redredvideo/Services/Storage/RRVDBMigration.h/.m` (新建)
  - `redredvideo/Services/Storage/DAO/RRVPlayHistoryDAO.h/.m` (新建)
  - `redredvideo/Services/Storage/DAO/RRVSearchHistoryDAO.h/.m` (新建)
  - `redredvideo/Services/Storage/DAO/RRVDownloadRecordDAO.h/.m` (新建)
  - `Podfile` (添加FMDB依赖)
- **验收标准**:
  - [ ] 数据库创建和初始化正常
  - [ ] CRUD操作正确
  - [ ] 多线程并发读写不崩溃
  - [ ] 数据库版本升级迁移正常
  - [ ] App卸载后数据清除

---

### NET-007 离线缓存内容管理
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: NET-006
- **描述**: 管理App的离线缓存内容，包括已缓存的剧集信息、封面图片等。用户在有网环境下浏览过的内容，离线时仍可查看基本信息（但不能播放非下载内容）。
- **技术要点**: 
  - 剧集元数据本地缓存：剧名、简介、封面URL、集数等
  - 封面图片缓存：SDWebImage自动缓存
  - 缓存有效期管理：超过7天的元数据标记为stale
  - 离线模式检测：网络不可达时自动切换离线数据源
  - 缓存清理：设置页提供"清除缓存"功能，显示缓存大小
- **涉及文件**: 
  - `redredvideo/Services/Storage/RRVOfflineCacheManager.h/.m` (新建)
  - `redredvideo/Services/Storage/DAO/RRVDramaCacheDAO.h/.m` (新建)
- **验收标准**:
  - [ ] 浏览过的剧集信息离线可查看
  - [ ] 封面图片离线正常展示
  - [ ] 缓存过期数据自动标记
  - [ ] 清除缓存功能正常，释放存储空间
  - [ ] 缓存大小统计准确

---

### NET-008 视频下载管理器
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: NET-001, NET-006
- **描述**: 实现剧集视频离线下载功能。支持单集下载和批量下载，下载队列管理，断点续传，下载进度展示，已下载内容管理（删除/统计大小）。
- **技术要点**: 
  - HLS下载：使用AVAssetDownloadURLSession下载m3u8内容
  - 下载队列：NSOperationQueue，最多同时下载2个
  - 断点续传：AVAssetDownloadTask支持resume
  - 后台下载：使用background session，App被杀后系统继续下载
  - 下载状态管理：waiting / downloading / paused / completed / failed
  - 存储路径：Library/Caches/Downloads/{drama_id}/{episode_id}/
  - 空间检测：下载前检查剩余存储空间，不足时提示
  - DRM保护：如果有FairPlay，需处理证书请求
- **涉及文件**: 
  - `redredvideo/Services/Download/RRVDownloadManager.h/.m` (新建)
  - `redredvideo/Services/Download/RRVDownloadTask.h/.m` (新建)
  - `redredvideo/Services/Download/RRVDownloadQueue.h/.m` (新建)
  - `redredvideo/Services/Storage/DAO/RRVDownloadRecordDAO.h/.m` (修改)
- **验收标准**:
  - [ ] 单集下载和批量下载正常
  - [ ] 下载进度实时更新
  - [ ] 暂停后可恢复，进度不丢失
  - [ ] App切后台后下载继续
  - [ ] 下载完成后离线可播放
  - [ ] 空间不足时给出提示
  - [ ] 已下载内容可删除，空间正确释放

---

## 3. 数据同步

### NET-009 数据同步引擎
- **优先级**: P2
- **预估工时**: 2天
- **依赖**: NET-001, NET-006
- **描述**: 实现客户端与服务端的数据同步机制，主要同步收藏列表、播放历史、用户设置等。支持增量同步、冲突解决、弱网环境下的离线操作延迟同步。
- **技术要点**: 
  - 同步策略：App启动时全量同步，之后增量同步（基于timestamp）
  - 冲突解决：服务端timestamp更新者优先（Last-Writer-Wins）
  - 离线操作队列：离线时将操作（收藏/取消收藏等）写入pending_ops表
  - 网络恢复时批量提交pending_ops
  - 同步频率：前台每5分钟增量同步一次
  - 同步数据范围：收藏列表、播放进度、追剧列表
- **涉及文件**: 
  - `redredvideo/Services/Sync/RRVSyncEngine.h/.m` (新建)
  - `redredvideo/Services/Sync/RRVSyncConflictResolver.h/.m` (新建)
  - `redredvideo/Services/Sync/RRVPendingOpsQueue.h/.m` (新建)
- **验收标准**:
  - [ ] App启动后自动同步最新数据
  - [ ] 多设备间数据最终一致
  - [ ] 离线操作恢复网络后正确同步
  - [ ] 冲突解决策略正确
  - [ ] 同步过程不影响App使用体验

---

### NET-010 WebSocket长连接
- **优先级**: P2
- **预估工时**: 1.5天
- **依赖**: NET-001, NET-003
- **描述**: 建立WebSocket长连接通道，用于接收服务端实时推送消息（如新剧上线通知、付费状态变更、系统公告等）。支持自动重连和心跳保活。
- **技术要点**: 
  - 使用SocketRocket（Facebook开源）或Starscream
  - 连接时携带token认证
  - 心跳机制：每30秒发送ping，超时未收到pong则断线重连
  - 自动重连：指数退避（1s → 2s → 4s → 8s → 最大30s）
  - 消息类型分发：根据消息type字段路由到对应handler
  - 前后台切换管理：进后台断开，回前台重连
  - 消息类型：
    - `new_episode`：新集上线
    - `payment_success`：支付成功确认
    - `system_notice`：系统公告
    - `review_result`：审核结果（合作方用）
- **涉及文件**: 
  - `redredvideo/Network/WebSocket/RRVWebSocketManager.h/.m` (新建)
  - `redredvideo/Network/WebSocket/RRVWSMessageHandler.h/.m` (新建)
  - `redredvideo/Network/WebSocket/RRVWSHeartbeat.h/.m` (新建)
  - `Podfile` (添加SocketRocket依赖)
- **验收标准**:
  - [ ] WebSocket连接建立成功
  - [ ] 心跳保活正常，不被服务端断开
  - [ ] 断线后自动重连
  - [ ] 收到推送消息后正确分发处理
  - [ ] App切后台时断开连接，回前台时重连
  - [ ] token过期时重新认证
