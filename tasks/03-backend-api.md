# 03 — 后端API接口

> 后端服务 | 共 20 个任务

---

## 1. 用户认证接口

### API-001 登录/注册接口
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: INF-001
- **描述**: 实现用户登录和注册API，支持手机号+验证码登录（一键注册）、Apple ID登录、微信登录三种方式。返回access_token和refresh_token。
- **技术要点**: 
  - `POST /api/v1/auth/login/phone` — 手机号验证码登录
  - `POST /api/v1/auth/login/apple` — Apple ID登录（验证identityToken）
  - `POST /api/v1/auth/login/wechat` — 微信登录（code换取openid/unionid）
  - 首次登录自动创建用户，合并第三方账号信息
  - access_token有效期2小时，refresh_token有效期30天
  - JWT payload: user_id, device_id, iat, exp
  - 登录日志记录：IP、设备信息、登录方式、时间
  - 频率限制：同一手机号1分钟内最多发送1次验证码
- **涉及文件**: 
  - `controllers/auth_controller` (新建)
  - `services/auth_service` (新建)
  - `services/sms_service` (新建)
  - `services/apple_auth_service` (新建)
  - `services/wechat_auth_service` (新建)
  - `models/user` (新建)
  - `models/user_auth` (新建)
  - `middleware/rate_limiter` (新建)
- **验收标准**:
  - [ ] 手机号验证码登录流程通畅
  - [ ] Apple ID登录验证通过
  - [ ] 微信登录获取用户信息正确
  - [ ] 返回的JWT格式正确，可解析
  - [ ] 频率限制生效
  - [ ] 登录日志正确记录

---

### API-002 Token刷新接口
- **优先级**: P0
- **预估工时**: 0.5天
- **依赖**: API-001
- **描述**: 实现access_token刷新接口。客户端使用refresh_token获取新的access_token，避免用户频繁重新登录。
- **技术要点**: 
  - `POST /api/v1/auth/refresh` — 传入refresh_token，返回新access_token
  - 验证refresh_token有效性和过期时间
  - 可选：refresh_token轮转（每次刷新同时返回新的refresh_token）
  - 旧refresh_token在轮转后标记为已使用
  - 检测到已使用的refresh_token被重放时，吊销该用户所有token（安全策略）
- **涉及文件**: 
  - `controllers/auth_controller` (修改)
  - `services/token_service` (新建)
  - `models/refresh_token` (新建)
- **验收标准**:
  - [ ] 有效refresh_token能获取新access_token
  - [ ] 过期refresh_token返回401
  - [ ] token轮转机制正确
  - [ ] 重放攻击检测生效

---

## 2. 内容接口

### API-003 短剧列表接口
- **优先级**: P0
- **预估工时**: 1.5天
- **依赖**: INF-001, SVC-001
- **描述**: 获取短剧列表，支持分页、分类筛选、排序、搜索等多种查询方式。是App首页、分类页、搜索结果页的核心数据源。
- **技术要点**: 
  - `GET /api/v1/dramas` — 短剧列表
  - 查询参数：
    - `page` / `page_size` — 分页（默认page_size=20）
    - `category_id` — 分类筛选
    - `region` — 地区筛选
    - `year` — 年份筛选
    - `status` — 状态筛选（连载中/已完结）
    - `sort` — 排序方式（hot/new/rating）
    - `keyword` — 搜索关键词（模糊匹配标题/标签）
  - 返回字段：drama_id, title, cover_url, category, rating, heat, episode_count, status, tags
  - 使用Elasticsearch做全文搜索，MySQL做筛选查询
  - 响应增加cache-control头，客户端可缓存5分钟
  - 列表接口不返回详情字段（简介/演员），减少传输量
- **涉及文件**: 
  - `controllers/drama_controller` (新建)
  - `services/drama_query_service` (新建)
  - `models/drama` (新建)
  - `serializers/drama_list_serializer` (新建)
- **验收标准**:
  - [ ] 分页查询正确，总数和列表对应
  - [ ] 各筛选条件独立和组合使用均正确
  - [ ] 搜索关键词匹配准确
  - [ ] 排序结果正确
  - [ ] 响应时间 < 200ms（缓存命中时）
  - [ ] 空结果返回空数组而非null

---

### API-004 短剧详情接口
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: API-003
- **描述**: 获取单部短剧的完整详情信息，包括剧情简介、演员列表、版权方信息、备案号、评分统计等。
- **技术要点**: 
  - `GET /api/v1/dramas/{drama_id}` — 短剧详情
  - 返回字段：完整剧信息 + 演员列表 + 版权方 + 备案号 + 评分 + 用户关系（是否收藏/是否追剧）
  - 用户关系字段需根据请求者身份动态填充（未登录时为false）
  - 备案号字段（license_no）必须返回，无备案号的剧不应出现
  - 阅读次数/热度值使用Redis计数器，定时同步到MySQL
  - 响应增加ETag，支持条件请求（304 Not Modified）
- **涉及文件**: 
  - `controllers/drama_controller` (修改)
  - `serializers/drama_detail_serializer` (新建)
  - `services/drama_service` (新建)
- **验收标准**:
  - [ ] 详情信息完整返回
  - [ ] 备案号字段不为空
  - [ ] 用户收藏/追剧状态正确
  - [ ] 不存在的drama_id返回404
  - [ ] ETag条件请求正确返回304

---

### API-005 集数列表接口
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: API-004
- **描述**: 获取某部短剧的所有集数信息。每集包含集号、标题、时长、封面、付费状态。支持正序/倒序和分段查询。
- **技术要点**: 
  - `GET /api/v1/dramas/{drama_id}/episodes` — 集数列表
  - 查询参数：
    - `sort` — asc/desc
    - `range_start` / `range_end` — 分段查询（如1-30、31-60）
  - 返回字段：episode_id, episode_no, title, duration, cover_url, is_free, price_coins, is_purchased（登录用户）
  - 付费状态判断：根据短剧的免费集数配置 + 用户购买记录
  - 如用户是VIP，所有集标记为is_free=true
  - 全剧已购用户标记所有集is_purchased=true
- **涉及文件**: 
  - `controllers/episode_controller` (新建)
  - `services/episode_service` (新建)
  - `models/episode` (新建)
  - `serializers/episode_serializer` (新建)
- **验收标准**:
  - [ ] 集数列表正确返回，支持排序
  - [ ] 付费状态标记准确
  - [ ] VIP用户所有集显示免费
  - [ ] 分段查询正确
  - [ ] 已购买的集标记正确

---

### API-006 播放地址接口
- **优先级**: P0
- **预估工时**: 1.5天
- **依赖**: API-005, SVC-003
- **描述**: 获取某一集的播放地址。需要鉴权（付费集需验证购买状态），返回多码率HLS地址，并附带防盗链签名。
- **技术要点**: 
  - `GET /api/v1/episodes/{episode_id}/play_url` — 获取播放地址
  - 鉴权逻辑：
    1. 免费集 → 直接返回
    2. 付费集 → 检查是否已购/VIP/看广告解锁
    3. 未购买 → 返回403 + 购买引导信息
  - 返回字段：play_urls数组（每个元素含quality、url、bitrate）
  - 防盗链：URL附带签名参数（token + expire + ip_hash）
  - 有效期：播放URL有效期2小时
  - CDN加速：返回的URL通过CDN域名
  - 并发控制：同一账号最多3个设备同时播放
- **涉及文件**: 
  - `controllers/play_controller` (新建)
  - `services/play_auth_service` (新建)
  - `services/cdn_sign_service` (新建)
- **验收标准**:
  - [ ] 免费集直接返回播放地址
  - [ ] 付费集需验证购买状态
  - [ ] 未购买返回403和购买引导
  - [ ] 播放URL带防盗链签名
  - [ ] URL过期后不可用
  - [ ] 并发设备数超限时阻止新设备

---

### API-007 播放进度同步接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: API-001, INF-002
- **描述**: 实现播放进度上报和查询接口。客户端定期上报播放进度，支持跨设备续播。
- **技术要点**: 
  - `POST /api/v1/play/progress` — 上报播放进度
    - Body: drama_id, episode_id, progress(秒), duration(秒), device_id
  - `GET /api/v1/play/progress/{drama_id}` — 查询该剧最新进度
  - `GET /api/v1/play/history` — 播放历史列表（最近观看）
  - 进度存储：Redis作为热数据（最近7天），MySQL作为冷数据
  - 上报频率限制：同一集同一设备最快5秒上报一次
  - 进度到95%以上标记为已看完
  - 按drama分组返回最新观看的集和进度
- **涉及文件**: 
  - `controllers/play_progress_controller` (新建)
  - `services/play_progress_service` (新建)
  - `models/play_progress` (新建)
- **验收标准**:
  - [ ] 进度上报成功
  - [ ] 查询返回最新进度
  - [ ] 播放历史按时间倒序
  - [ ] 跨设备进度一致
  - [ ] 频率限制生效

---

### API-008 收藏/追剧接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: API-001
- **描述**: 实现用户收藏和追剧功能的接口。收藏表示喜欢，追剧表示订阅更新通知。
- **技术要点**: 
  - `POST /api/v1/favorites` — 收藏短剧 (drama_id)
  - `DELETE /api/v1/favorites/{drama_id}` — 取消收藏
  - `GET /api/v1/favorites` — 收藏列表（分页）
  - `POST /api/v1/subscriptions` — 追剧（订阅更新）
  - `DELETE /api/v1/subscriptions/{drama_id}` — 取消追剧
  - `GET /api/v1/subscriptions` — 追剧列表
  - 追剧的剧集有新集更新时，通过推送通知用户
  - 收藏数作为热度计算的一个维度
- **涉及文件**: 
  - `controllers/favorite_controller` (新建)
  - `controllers/subscription_controller` (新建)
  - `models/favorite` (新建)
  - `models/subscription` (新建)
- **验收标准**:
  - [ ] 收藏/取消收藏正确
  - [ ] 重复收藏返回友好提示（幂等）
  - [ ] 收藏列表分页正确
  - [ ] 追剧新集有推送通知
  - [ ] 收藏/追剧状态在详情接口正确反映

---

### API-009 搜索与热搜接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: INF-001, INF-007
- **描述**: 实现搜索联想词和热搜榜接口。联想词提供实时搜索建议，热搜榜分为运营配置和自动计算两部分。
- **技术要点**: 
  - `GET /api/v1/search/suggest?q=xxx` — 搜索联想（根据输入前缀匹配）
  - `GET /api/v1/search/hot` — 热搜榜（top 20）
  - 联想词：使用ES的suggest功能或Redis sorted set前缀匹配
  - 热搜计算：统计最近24小时搜索频次 + 运营手动配置的置顶词
  - 热搜更新频率：每10分钟重新计算（定时任务）
  - 热搜缓存：Redis缓存，客户端可缓存10分钟
  - 搜索词日志：记录用户搜索行为，用于后续推荐
- **涉及文件**: 
  - `controllers/search_controller` (新建)
  - `services/search_service` (新建)
  - `services/hot_search_service` (新建)
  - `jobs/hot_search_calculator_job` (新建)
- **验收标准**:
  - [ ] 联想词响应 < 100ms
  - [ ] 联想结果与输入相关
  - [ ] 热搜榜包含运营置顶词和自动计算词
  - [ ] 热搜词有排名序号和热度标签
  - [ ] 搜索行为日志正确记录

---

### API-010 推荐接口
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: API-003, SVC-001
- **描述**: 实现短剧推荐接口，包括个性化推荐（基于用户行为）和相关推荐（基于当前剧集）。
- **技术要点**: 
  - `GET /api/v1/recommend/personalized` — 个性化推荐（首页信息流）
    - 参数：page, page_size
    - 基于用户观看历史、收藏、搜索行为
  - `GET /api/v1/recommend/related?drama_id=xxx` — 相关推荐（详情页底部）
    - 基于标签相似度、分类、用户协同过滤
  - 冷启动策略：新用户返回热门榜 + 编辑精选
  - 推荐列表去重：不推荐用户已看完的剧
  - 推荐结果缓存：Redis缓存60秒
  - 推荐多样性：同类型不超过3部
- **涉及文件**: 
  - `controllers/recommend_controller` (新建)
  - `services/recommend_service` (新建)
  - `services/collaborative_filter_service` (新建)
- **验收标准**:
  - [ ] 个性化推荐结果与用户偏好相关
  - [ ] 相关推荐与当前剧有相似性
  - [ ] 新用户冷启动正常
  - [ ] 不推荐已看完的剧
  - [ ] 响应时间 < 300ms

---

### API-011 Banner/运营位接口
- **优先级**: P1
- **预估工时**: 0.5天
- **依赖**: INF-001
- **描述**: 获取App各运营位配置，包括Banner轮播图、弹窗广告、公告等。支持按位置ID查询，运营后台可动态配置。
- **技术要点**: 
  - `GET /api/v1/banners?position=home_top` — 获取指定位置的Banner
  - 返回字段：banner_id, image_url, link_type(drama/url/activity), link_value, sort_order, start_time, end_time
  - 运营位类型：首页顶部Banner、首页弹窗、频道页推荐位等
  - 时间控制：根据start_time/end_time决定是否展示
  - 缓存：Redis缓存 + 客户端缓存30分钟
- **涉及文件**: 
  - `controllers/banner_controller` (新建)
  - `services/banner_service` (新建)
  - `models/banner` (新建)
- **验收标准**:
  - [ ] 按位置正确返回Banner列表
  - [ ] 过期Banner不返回
  - [ ] 排序正确
  - [ ] 链接类型和值正确

---

## 3. 广告接口

### API-012 广告配置接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: INF-001
- **描述**: 获取广告配置信息，包括前贴片/中插/后贴片广告的素材和策略、频控规则等。
- **技术要点**: 
  - `GET /api/v1/ads/config?drama_id=xxx&episode_no=xxx` — 获取广告配置
  - 返回内容：
    - `preroll`：前贴片广告（素材URL、时长、跳过秒数）
    - `midroll`：中插广告（触发时间点数组、素材）
    - `postroll`：后贴片广告
    - `frequency_rules`：频控规则（preroll_interval、midroll_max等）
    - `user_policy`：用户广告策略（VIP免广告、新用户保护期等）
  - 广告素材支持A/B测试配置
  - VIP用户返回空广告配置
  - 配置缓存：Redis + 客户端session级别缓存
- **涉及文件**: 
  - `controllers/ad_controller` (新建)
  - `services/ad_config_service` (新建)
  - `models/ad_config` (新建)
  - `models/ad_creative` (新建)
- **验收标准**:
  - [ ] 广告配置正确返回
  - [ ] VIP用户返回空配置
  - [ ] 频控规则完整
  - [ ] 不同剧集可配置不同广告策略
  - [ ] A/B分组正确

---

### API-013 广告事件上报接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: API-012, INF-008
- **描述**: 接收客户端上报的广告事件（展示、点击、完播、跳过等），用于广告收益计算和效果分析。
- **技术要点**: 
  - `POST /api/v1/ads/events` — 批量上报广告事件
  - 事件类型：impression(曝光)、click(点击)、complete(完播)、skip(跳过)、error(加载失败)
  - 上报字段：ad_id, event_type, timestamp, drama_id, episode_id, position(preroll/midroll/postroll), duration_watched, device_info
  - 批量上报：客户端攒5条或30秒上报一次
  - 事件写入Kafka异步处理
  - 防刷校验：同一广告短时间内重复上报去重
  - 上报失败客户端本地缓存，下次重传
- **涉及文件**: 
  - `controllers/ad_event_controller` (新建)
  - `services/ad_event_service` (新建)
  - `producers/ad_event_producer` (新建)
  - `consumers/ad_event_consumer` (新建)
- **验收标准**:
  - [ ] 事件上报接口高性能（< 50ms响应）
  - [ ] 批量上报解析正确
  - [ ] 事件写入Kafka成功
  - [ ] 防刷去重生效
  - [ ] 各事件类型计数准确

---

## 4. 支付接口

### API-014 创建订单接口
- **优先级**: P0
- **预估工时**: 1.5天
- **依赖**: API-001, SVC-004, INF-001
- **描述**: 创建支付订单，支持单集购买、全集购买、金币充值、VIP订阅等订单类型。返回订单号供客户端调起支付。
- **技术要点**: 
  - `POST /api/v1/orders` — 创建订单
  - 请求Body：order_type(episode/bundle/recharge/vip), product_id, amount
  - 订单号生成：年月日时分秒 + 4位随机数 + 用户ID后4位
  - 订单状态：created → paying → paid → delivered → completed / refunded
  - 金额校验：服务端重新计算价格，不信任客户端传入的金额
  - 重复购买检测：已购集/已生效VIP不允许重复购买
  - 订单超时：30分钟未支付自动取消
  - 分布式锁：防止并发创建重复订单
- **涉及文件**: 
  - `controllers/order_controller` (新建)
  - `services/order_service` (新建)
  - `models/order` (新建)
  - `jobs/order_timeout_job` (新建)
- **验收标准**:
  - [ ] 各类型订单创建成功
  - [ ] 订单号唯一
  - [ ] 金额服务端校验正确
  - [ ] 重复购买正确拦截
  - [ ] 超时订单自动取消
  - [ ] 并发创建不重复

---

### API-015 IAP Receipt验证接口
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: API-014
- **描述**: 接收iOS客户端提交的IAP收据（receipt），向Apple服务器验证后完成发货（充值到账/VIP开通/集解锁）。
- **技术要点**: 
  - `POST /api/v1/payments/iap/verify` — 提交receipt验证
  - 请求Body：order_id, receipt_data(base64)
  - 服务端流程：
    1. 解码receipt_data
    2. 调用Apple verifyReceipt接口（先prod环境，21007错误码换sandbox）
    3. 验证bundle_id、product_id、transaction_id匹配
    4. 检查transaction_id是否已处理（防重复发货）
    5. 验证通过 → 更新订单状态 → 发货（加金币/开VIP/解锁集）
  - 订阅类型：额外处理auto-renew状态、过期时间、grace period
  - Apple Server-to-Server通知处理：续费、退款、过期等事件
  - 失败重试：验证失败的receipt暂存，定时重试
- **涉及文件**: 
  - `controllers/payment_controller` (新建)
  - `services/iap_verify_service` (新建)
  - `services/delivery_service` (新建)
  - `controllers/apple_webhook_controller` (新建)
  - `models/iap_transaction` (新建)
- **验收标准**:
  - [ ] 有效receipt验证通过并发货
  - [ ] 无效/伪造receipt验证失败
  - [ ] 同一transaction_id不重复发货
  - [ ] 沙盒环境和生产环境均正确处理
  - [ ] 订阅续费/退款webhook正确处理
  - [ ] 验证失败的receipt可重试

---

### API-016 用户会员状态接口
- **优先级**: P0
- **预估工时**: 0.5天
- **依赖**: API-015
- **描述**: 查询用户VIP会员状态，包含会员类型、到期时间、自动续费状态等信息。
- **技术要点**: 
  - `GET /api/v1/user/vip` — 查询VIP状态
  - 返回字段：is_vip, vip_type(monthly/quarterly/yearly), expire_time, auto_renew, remaining_days
  - 会员状态缓存：Redis缓存，过期时间与会员到期时间对齐
  - 到期前3天提醒（通过推送）
  - VIP过期后立即失效（不缓存过期的VIP状态）
- **涉及文件**: 
  - `controllers/vip_controller` (新建)
  - `services/vip_service` (新建)
  - `models/vip_membership` (新建)
- **验收标准**:
  - [ ] VIP状态查询正确
  - [ ] 过期VIP立即失效
  - [ ] 自动续费状态准确
  - [ ] 响应时间 < 50ms（缓存命中）

---

## 5. 用户接口

### API-017 用户信息接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: API-001
- **描述**: 查询和修改用户基本信息，包括昵称、头像、个人简介、性别等。
- **技术要点**: 
  - `GET /api/v1/user/profile` — 查询个人信息
  - `PUT /api/v1/user/profile` — 修改个人信息
  - 可修改字段：nickname, avatar_url, bio, gender, birthday
  - 昵称敏感词过滤（调AI-015敏感词服务）
  - 头像上传走文件上传接口，此处只保存URL
  - 修改频率限制：昵称每天最多改3次
- **涉及文件**: 
  - `controllers/user_controller` (新建)
  - `services/user_service` (新建)
  - `serializers/user_profile_serializer` (新建)
- **验收标准**:
  - [ ] 查询个人信息完整
  - [ ] 修改信息成功更新
  - [ ] 昵称敏感词拦截
  - [ ] 修改频率限制生效

---

### API-018 金币/钱包接口
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: API-015
- **描述**: 查询用户金币余额和交易记录。金币是虚拟货币，通过IAP充值获得，用于购买付费集。
- **技术要点**: 
  - `GET /api/v1/user/wallet` — 查询钱包（金币余额、赠送金币余额）
  - `GET /api/v1/user/wallet/transactions` — 交易记录（分页）
  - 余额分为：充值金币 + 赠送金币，消费时优先扣赠送金币
  - 交易类型：recharge(充值)、gift(赠送)、purchase(购买)、refund(退款)
  - 余额使用乐观锁更新（version字段），防止并发扣款问题
  - 余额不允许为负数
  - 每笔交易生成流水记录
- **涉及文件**: 
  - `controllers/wallet_controller` (新建)
  - `services/wallet_service` (新建)
  - `models/wallet` (新建)
  - `models/wallet_transaction` (新建)
- **验收标准**:
  - [ ] 余额查询准确
  - [ ] 充值金币和赠送金币分开展示
  - [ ] 交易记录完整，分页正确
  - [ ] 并发扣款不超扣
  - [ ] 余额不会变为负数

---

### API-019 消息通知接口
- **优先级**: P2
- **预估工时**: 1天
- **依赖**: API-001
- **描述**: 获取用户的站内消息通知列表，支持系统通知、追剧更新通知、支付通知等分类。
- **技术要点**: 
  - `GET /api/v1/notifications` — 通知列表（分页）
  - `PUT /api/v1/notifications/{id}/read` — 标记已读
  - `PUT /api/v1/notifications/read_all` — 全部已读
  - `GET /api/v1/notifications/unread_count` — 未读数
  - 通知类型：system(系统通知)、update(追剧更新)、payment(支付相关)、activity(活动)
  - 未读数使用Redis计数器，实时性高
  - 通知生成走异步队列（Kafka），不阻塞业务流程
- **涉及文件**: 
  - `controllers/notification_controller` (新建)
  - `services/notification_service` (新建)
  - `models/notification` (新建)
  - `consumers/notification_consumer` (新建)
- **验收标准**:
  - [ ] 通知列表按类型分类展示
  - [ ] 标记已读后未读数更新
  - [ ] 全部已读功能正确
  - [ ] 未读数实时准确
  - [ ] 通知生成不阻塞主流程

---

### API-020 反馈/举报接口
- **优先级**: P2
- **预估工时**: 0.5天
- **依赖**: API-001
- **描述**: 用户提交反馈建议和内容举报的接口。举报内容将进入审核队列。
- **技术要点**: 
  - `POST /api/v1/feedback` — 提交反馈（type, content, contact, screenshots[]）
  - `POST /api/v1/reports` — 举报内容（target_type, target_id, reason, description）
  - 举报目标类型：drama(短剧)、comment(评论)、user(用户)
  - 举报写入审核队列，人工处理
  - 频率限制：同一用户每小时最多提交5次
  - 自动回复：提交后返回反馈编号
- **涉及文件**: 
  - `controllers/feedback_controller` (新建)
  - `controllers/report_controller` (新建)
  - `models/feedback` (新建)
  - `models/report` (新建)
- **验收标准**:
  - [ ] 反馈提交成功，返回编号
  - [ ] 举报写入审核队列
  - [ ] 频率限制生效
  - [ ] 截图附件正确关联
