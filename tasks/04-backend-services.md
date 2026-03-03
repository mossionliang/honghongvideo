# 04 — 后端核心服务

> Go / gRPC + HTTP Gateway | 共 11 个服务模块

---

## 1. 内容管理服务

### SVC-001 内容管理服务（剧/集 CRUD、上下架状态机）
- **优先级**: P0
- **预估工时**: 5天
- **依赖**: API-001（接口层基础框架）
- **描述**: 实现短剧和剧集的完整生命周期管理。包括短剧信息的创建/编辑/删除、剧集（Episode）的批量管理、上下架状态机流转、排序与置顶功能。支持草稿→待审核→审核中→已上架→已下架→已删除的完整状态流转。
- **技术要点**: 
  - 剧（Drama）表设计：id, title, description, cover_url, category_id, tags, total_episodes, status, content_provider_id, score, play_count, created_at, updated_at, deleted_at
  - 剧集（Episode）表设计：id, drama_id, episode_number, title, video_id(关联媒资), duration, is_free, price, sort_order, status
  - 状态机引擎：基于 looplab/fsm 实现状态流转，每次流转记录操作日志
  - 状态流转规则：draft→pending_review（提交审核）、pending_review→reviewing（开始审核）、reviewing→published（审核通过）、reviewing→rejected（审核驳回）、published→offline（下架）、offline→published（重新上架）
  - 批量操作：批量上架、批量下架、批量删除（软删除）
  - 分类/标签体系：Category 树形结构 + Tag 多对多关联
  - 缓存策略：剧详情 Redis 缓存，TTL 10min，状态变更时主动失效
  - 列表查询：支持按分类、标签、状态、CP 筛选，分页采用 cursor-based pagination
- **涉及文件**: 
  - `internal/service/content/drama_service.go` (新建)
  - `internal/service/content/episode_service.go` (新建)
  - `internal/service/content/fsm.go` (新建，状态机定义)
  - `internal/model/drama.go` (新建)
  - `internal/model/episode.go` (新建)
  - `internal/model/category.go` (新建)
  - `internal/repo/drama_repo.go` (新建)
  - `internal/repo/episode_repo.go` (新建)
  - `migrations/004_create_drama_tables.sql` (新建)
- **验收标准**:
  - [ ] 剧/集 CRUD 接口功能完整，参数校验覆盖
  - [ ] 状态机流转规则正确，非法流转返回明确错误
  - [ ] 每次状态变更写入操作审计日志
  - [ ] 批量操作支持事务，部分失败可回滚
  - [ ] 缓存命中率 > 90%，状态变更后缓存立即失效
  - [ ] cursor-based 分页在 100 万条数据下查询 < 50ms

---

## 2. 媒资管理服务

### SVC-002 媒资管理服务（视频上传分片、转码多码率、自动截图封面、字幕提取、CDN 分发）
- **优先级**: P0
- **预估工时**: 8天
- **依赖**: 无
- **描述**: 实现视频从上传到播放的完整媒资处理流水线。支持大文件分片上传、断点续传，上传完成后自动触发转码（多码率/多分辨率）、截图（自动选帧生成封面和缩略图雪碧图）、字幕提取（语音识别ASR）、CDN 预热分发。所有处理任务异步执行，通过消息队列驱动。
- **技术要点**: 
  - 分片上传：客户端将文件切片（每片 5MB），服务端返回 uploadId，逐片上传至对象存储（阿里云 OSS / AWS S3），全部分片完成后合并
  - 断点续传：服务端记录已上传分片列表，客户端查询后跳过已完成分片
  - 上传凭证：服务端生成 STS 临时凭证，客户端直传 OSS，避免流量经服务端
  - 转码流水线（基于阿里云 MPS / FFmpeg）：
    - 输入：原始视频（支持 mp4/mov/avi/mkv）
    - 输出码率：1080p(4Mbps) / 720p(2Mbps) / 480p(1Mbps) / 360p(500Kbps)
    - 输出格式：HLS (m3u8 + ts) 用于播放、MP4 用于下载
    - 自适应码率：生成 Master Playlist
  - 自动截图：转码完成后在 10%/30%/50%/70%/90% 时间点截取关键帧，取第 3 张作为默认封面；同时生成缩略图雪碧图（sprite sheet）用于进度条预览
  - 字幕提取：调用阿里云 ASR / Whisper 对音轨进行语音识别，生成 SRT/VTT 字幕文件
  - CDN 分发：转码产物推送至 CDN 预热，热门内容预加载至边缘节点
  - 媒资表设计：id, original_url, original_size, duration, resolution, codec, status(uploading/processing/ready/failed), transcode_outputs(JSON), thumbnails(JSON), subtitles(JSON)
  - 消息队列：上传完成 → 发送 MQ 消息 → 转码 Worker 消费 → 转码完成 → 截图 Worker → 字幕 Worker → 状态更新 → 通知内容服务
  - 回调机制：云厂商转码完成回调 + 主动轮询兜底
- **涉及文件**: 
  - `internal/service/media/upload_service.go` (新建，分片上传)
  - `internal/service/media/transcode_service.go` (新建，转码管理)
  - `internal/service/media/screenshot_service.go` (新建，截图)
  - `internal/service/media/subtitle_service.go` (新建，字幕提取)
  - `internal/service/media/cdn_service.go` (新建，CDN管理)
  - `internal/worker/transcode_worker.go` (新建，转码消费者)
  - `internal/worker/screenshot_worker.go` (新建)
  - `internal/worker/subtitle_worker.go` (新建)
  - `internal/model/media_asset.go` (新建)
  - `internal/repo/media_repo.go` (新建)
  - `internal/pkg/oss/client.go` (新建，OSS SDK封装)
  - `migrations/005_create_media_tables.sql` (新建)
- **验收标准**:
  - [ ] 1GB 视频分片上传成功，断点续传验证通过
  - [ ] STS 临时凭证有效期 15min，过期自动刷新
  - [ ] 转码输出 4 种码率 + 自适应码率 Master Playlist
  - [ ] 截图 5 张 + 雪碧图生成正确
  - [ ] 中文语音字幕识别准确率 > 85%
  - [ ] 转码失败自动重试 3 次，最终失败发送告警
  - [ ] 媒资状态流转完整，可通过管理后台查看处理进度

---

## 3. 播放服务

### SVC-003 播放服务（播放地址签名、防盗链、码率策略、DRM）
- **优先级**: P0
- **预估工时**: 5天
- **依赖**: SVC-002
- **描述**: 为客户端提供安全的视频播放地址。根据用户会员等级、网络状况返回合适码率的播放地址，地址带时效签名防盗链。付费内容实施 DRM 加密保护。记录播放行为用于后续数据分析和分账计费。
- **技术要点**: 
  - 播放地址签名：基于 CDN 的 URL 鉴权（TypeA：timestamp + rand + uid + key → MD5），有效期 30min
  - 防盗链策略：
    - Referer 白名单（仅允许 App 和管理后台域名）
    - IP 限频（单 IP 单视频 10次/min）
    - User-Agent 校验
    - Token 防盗链（URL 中携带签名 token）
  - 码率策略：
    - 会员用户：最高 1080p
    - 免费用户：最高 720p
    - 网络探测：客户端上报网络类型（WiFi/4G/5G），服务端推荐初始码率
    - ABR（自适应码率）：返回 Master Playlist 由播放器自动切换
  - DRM 保护：
    - 付费内容使用 FairPlay Streaming（iOS）加密
    - License Server：验证用户购买权限后下发解密密钥
    - 密钥轮换：每部剧独立 content key，定期轮换
  - 播放鉴权：检查用户是否有权播放（免费集 / 已购买 / 会员权益）
  - 播放事件上报：play_start / play_pause / play_resume / play_complete / play_error，写入 Kafka 用于计费和分析
- **涉及文件**: 
  - `internal/service/play/play_service.go` (新建)
  - `internal/service/play/url_signer.go` (新建，URL签名)
  - `internal/service/play/antihotlink.go` (新建，防盗链)
  - `internal/service/play/bitrate_strategy.go` (新建，码率策略)
  - `internal/service/play/drm_service.go` (新建，DRM管理)
  - `internal/service/play/license_server.go` (新建，密钥分发)
  - `internal/middleware/play_auth.go` (新建，播放鉴权)
- **验收标准**:
  - [ ] 签名 URL 在有效期内可播放，过期返回 403
  - [ ] 非授权 Referer / IP 超频 / 非法 UA 均拦截成功
  - [ ] 免费用户最高获取 720p 地址，会员获取 1080p
  - [ ] FairPlay DRM 加密视频仅授权用户可播放
  - [ ] 播放事件完整写入 Kafka，延迟 < 500ms
  - [ ] 单集播放地址获取 API P99 < 100ms

---

## 4. 用户服务

### SVC-004 用户服务（注册登录、信息管理、设备管理）
- **优先级**: P0
- **预估工时**: 5天
- **依赖**: 无
- **描述**: 实现用户完整的账号体系。支持手机号+验证码登录、Apple Sign In、微信登录、游客模式。用户信息管理（昵称、头像、个人简介）。设备管理（多设备登录控制、设备列表、强制下线）。
- **技术要点**: 
  - 注册登录方式：
    - 手机号+短信验证码（接入阿里云短信 / Twilio）
    - Apple Sign In（identityToken 验证，获取 userIdentifier）
    - 微信登录（OAuth2.0，code 换 access_token → 获取 unionid）
    - 游客模式（基于 device_id 自动创建匿名账号，后续可绑定手机号升级）
  - 账号合并：游客升级绑定手机号时，数据迁移至正式账号
  - JWT Token：access_token(2h) + refresh_token(30d)，签发包含 uid/device_id/role
  - 用户表设计：id, phone, apple_id, wechat_unionid, nickname, avatar_url, gender, birthday, bio, status(normal/banned/deleted), vip_level, register_channel, register_ip, created_at
  - 设备管理：
    - 设备表：id, user_id, device_id, device_name, device_model, os_version, app_version, push_token, last_login_at, is_active
    - 同时在线设备数限制：普通用户 3 台，VIP 5 台
    - 强制下线：管理端可踢某设备下线（使其 token 失效）
  - 安全措施：
    - 短信验证码：6 位数字，5min 有效，同号码 60s 间隔，每日上限 10 条
    - 登录频率限制：同 IP 5次/min，同手机号 10次/hour
    - 密码（可选）：bcrypt 加盐哈希
    - 敏感操作二次验证
- **涉及文件**: 
  - `internal/service/user/user_service.go` (新建)
  - `internal/service/user/auth_service.go` (新建，登录认证)
  - `internal/service/user/sms_service.go` (新建，短信发送)
  - `internal/service/user/oauth_service.go` (新建，第三方登录)
  - `internal/service/user/device_service.go` (新建，设备管理)
  - `internal/model/user.go` (新建)
  - `internal/model/user_device.go` (新建)
  - `internal/repo/user_repo.go` (新建)
  - `internal/pkg/jwt/jwt.go` (新建)
  - `internal/pkg/sms/aliyun.go` (新建)
  - `migrations/006_create_user_tables.sql` (新建)
- **验收标准**:
  - [ ] 四种登录方式均可正常注册/登录
  - [ ] 游客升级为正式账号后数据完整迁移
  - [ ] JWT Token 签发/验证/刷新流程正确
  - [ ] 超出设备数限制时最早登录设备自动下线
  - [ ] 短信验证码频率限制生效
  - [ ] 登录接口 P99 < 200ms

---

## 5. 支付服务

### SVC-005 支付服务（订单管理、IAP 验证、退款流程）
- **优先级**: P0
- **预估工时**: 6天
- **依赖**: SVC-004
- **描述**: 实现 App 内购（IAP）支付全流程。创建订单、客户端发起 IAP 购买、服务端验证 Apple Receipt、确认订单、发放权益。支持订阅型和消耗型商品。处理退款回调，支持人工退款审核。
- **技术要点**: 
  - 商品表：id, product_id(Apple), name, type(subscription/consumable/non_consumable), price_tier, duration_days(订阅), coin_amount(充值), status
  - 订单表：id, order_no(雪花ID), user_id, product_id, amount, currency, status(created/paid/verified/fulfilled/refunded/failed), receipt_data, transaction_id, original_transaction_id, purchase_date, expires_date, created_at
  - IAP 验证流程：
    1. 客户端完成购买 → 上报 receipt_data
    2. 服务端调用 App Store Server API (v2) 验证
    3. 先请求 Production URL，若返回 21007 再请求 Sandbox URL
    4. 验证通过 → 更新订单状态 → 发放权益
    5. 验证失败 → 标记异常 → 人工审核队列
  - App Store Server Notifications V2：
    - 监听 SUBSCRIBED / DID_RENEW / EXPIRED / DID_FAIL_TO_RENEW / REFUND 等通知
    - 自动续订：收到 DID_RENEW 更新 expires_date
    - 退款：收到 REFUND 回收权益 + 生成退款单
  - 订单幂等：基于 transaction_id 去重，防止重复发放
  - 退款流程：
    - Apple 退款回调 → 创建退款单 → 回收权益（扣减会员天数/回收金币）
    - 人工退款：客服审核 → 调用 Apple API 退款 → 回收权益
  - 掉单处理：定时任务扫描 created 超 30min 未确认的订单，主动查询 Apple 交易状态
  - 对账：每日拉取 Apple 财务报告，与本地订单交叉对账
- **涉及文件**: 
  - `internal/service/payment/order_service.go` (新建)
  - `internal/service/payment/iap_verifier.go` (新建，IAP验证)
  - `internal/service/payment/subscription_service.go` (新建，订阅管理)
  - `internal/service/payment/refund_service.go` (新建，退款处理)
  - `internal/service/payment/reconciliation.go` (新建，对账)
  - `internal/handler/webhook/appstore_notification.go` (新建)
  - `internal/model/product.go` (新建)
  - `internal/model/order.go` (新建)
  - `internal/model/refund.go` (新建)
  - `internal/repo/order_repo.go` (新建)
  - `internal/job/order_timeout_job.go` (新建，掉单扫描)
  - `migrations/007_create_payment_tables.sql` (新建)
- **验收标准**:
  - [ ] IAP 购买→验证→发放全流程 < 3s
  - [ ] 同一 transaction_id 重复提交不会重复发放
  - [ ] App Store 通知回调正确处理所有事件类型
  - [ ] 退款后权益立即回收
  - [ ] 掉单扫描任务每 5min 执行，修复率 > 99%
  - [ ] 日对账差异自动告警

---

## 6. 会员服务

### SVC-006 会员服务（订阅管理、权益判断、到期处理）
- **优先级**: P0
- **预估工时**: 4天
- **依赖**: SVC-005
- **描述**: 管理用户会员订阅的完整生命周期。定义会员等级和权益体系，实时判断用户当前权益，处理订阅到期/续费/降级。支持限时促销活动。
- **技术要点**: 
  - 会员等级：免费用户 / 月度VIP / 年度VIP / 终身VIP
  - 权益定义表：vip_level, max_resolution(1080p), ad_free(bool), download_enabled(bool), max_devices(int), exclusive_content(bool), early_access_days(int)
  - 会员订阅表：id, user_id, vip_level, start_date, expire_date, auto_renew(bool), subscription_source(iap/promo/gift), original_transaction_id, status(active/expired/cancelled/grace_period)
  - 权益判断服务：
    - `HasPermission(uid, permission)` → bool
    - `CanPlayEpisode(uid, episode_id)` → (bool, reason)
    - `GetMaxResolution(uid)` → string
    - 结果缓存 Redis，TTL 5min，权益变更时主动清除
  - 到期处理：
    - 到期前 3 天 / 1 天 / 当天 Push 提醒续费
    - 到期宽限期：过期后 7 天内仍可续费衔接，超过则降级
    - 降级：权益即时回收，已缓存的高清内容标记失效
  - 促销活动：
    - 活动表：id, name, vip_level, original_price, promo_price, start_time, end_time, max_quota
    - 首月特惠、年度折扣、拉新赠送等
- **涉及文件**: 
  - `internal/service/member/member_service.go` (新建)
  - `internal/service/member/permission_service.go` (新建，权益判断)
  - `internal/service/member/expiry_handler.go` (新建，到期处理)
  - `internal/service/member/promo_service.go` (新建，促销)
  - `internal/model/member_subscription.go` (新建)
  - `internal/model/vip_benefit.go` (新建)
  - `internal/model/promo_activity.go` (新建)
  - `internal/repo/member_repo.go` (新建)
  - `internal/job/member_expiry_job.go` (新建，到期检查定时任务)
  - `migrations/008_create_member_tables.sql` (新建)
- **验收标准**:
  - [ ] 购买会员后权益立即生效，权益判断接口 P99 < 10ms
  - [ ] 到期提醒按时发送（-3d / -1d / 当天）
  - [ ] 宽限期内续费则到期时间从原 expire_date 顺延
  - [ ] 超出宽限期自动降级为免费用户
  - [ ] 促销活动到期自动关闭，库存扣减准确
  - [ ] 并发购买相同促销不超卖（Redis 原子扣减）

---

## 7. 广告服务

### SVC-007 广告服务（广告配置、频控规则、收益回传归因）
- **优先级**: P1
- **预估工时**: 5天
- **依赖**: SVC-004
- **描述**: 管理 App 内广告投放。支持多广告位配置（开屏、插屏、激励视频、信息流原生广告），广告频次控制，对接广告联盟 SDK（穿山甲/AdMob），广告收益回传与归因统计。VIP 用户免广告。
- **技术要点**: 
  - 广告位配置表：id, slot_name(splash/interstitial/rewarded/native), platform(ios/android), ad_network(csj/admob), ad_unit_id, priority, is_active, target_audience
  - 广告请求流程：
    1. 客户端请求广告位配置
    2. 服务端判断用户是否免广告（VIP跳过）
    3. 返回广告位配置（可能多个network，瀑布流）
    4. 客户端按优先级依次请求广告 SDK
  - 频控规则表：id, slot_name, rule_type(daily_cap/interval/session_cap), rule_value, target_user_type
  - 频控策略：
    - 开屏广告：每次冷启动展示，间隔 > 30min
    - 插屏广告：每日上限 5 次，间隔 > 3min
    - 激励视频：用户主动触发，每日上限 10 次
    - 信息流：每 5 条内容插入 1 条广告
  - 频控实现：Redis bitmap（用户+广告位+日期 → 计数器），客户端本地也做一层缓存兜底
  - 广告事件上报：ad_request / ad_fill / ad_show / ad_click / ad_complete / ad_error，写入 Kafka
  - 收益回传：
    - 穿山甲 S2S 回调：验证签名 → 记录收益
    - AdMob SSV 回调：验证 reward callback
    - 归因：将广告收益关联到具体内容(drama_id)和内容提供商(cp_id)，用于分账
  - eCPM 统计：按广告位 / 日期 / 地区聚合计算 eCPM，低于阈值告警
- **涉及文件**: 
  - `internal/service/ad/ad_service.go` (新建)
  - `internal/service/ad/freq_control.go` (新建，频控)
  - `internal/service/ad/revenue_tracker.go` (新建，收益追踪)
  - `internal/service/ad/attribution.go` (新建，归因)
  - `internal/handler/webhook/ad_callback.go` (新建，广告回调)
  - `internal/model/ad_slot.go` (新建)
  - `internal/model/ad_freq_rule.go` (新建)
  - `internal/model/ad_event.go` (新建)
  - `internal/repo/ad_repo.go` (新建)
  - `migrations/009_create_ad_tables.sql` (新建)
- **验收标准**:
  - [ ] 广告位配置可热更新，无需发版
  - [ ] VIP 用户请求广告接口返回空（免广告）
  - [ ] 频控规则准确执行，超限后不再展示
  - [ ] 穿山甲/AdMob 回调签名验证通过
  - [ ] 广告收益可归因到具体剧集和 CP
  - [ ] eCPM 日报表自动生成

---

## 8. 推荐服务

### SVC-008 推荐服务（规则+热度 MVP → 协同过滤+模型）
- **优先级**: P1
- **预估工时**: 6天
- **依赖**: SVC-001, SVC-011
- **描述**: 为用户提供个性化内容推荐。MVP 阶段基于规则引擎+热度排序实现，后期迭代引入协同过滤和深度学习模型。推荐场景包括首页推荐流、猜你喜欢、看了又看、相似推荐。
- **技术要点**: 
  - **MVP 阶段（规则+热度）**：
    - 热度分计算：play_count × 0.3 + like_count × 0.2 + share_count × 0.2 + complete_rate × 0.3，每小时更新
    - 新剧加权：上线 7 天内热度 × 1.5 boost
    - 规则引擎：
      - 首页推荐：运营置顶 > 热度 Top50 > 按分类轮询
      - 猜你喜欢：基于用户最近观看 3 部剧的分类，拉取同分类热门
      - 看了又看：看过剧 A 的人还看了什么（共现矩阵，离线计算）
      - 相似推荐：同分类 + 同标签 + 同 CP 的剧
    - 推荐池：从全量内容中预筛选 status=published + score>3.0 的内容
    - 去重/过滤：已看过、已不感兴趣的内容从结果中剔除
  - **进阶阶段（协同过滤+模型）**：
    - ItemCF：基于物品的协同过滤，item-item 相似度矩阵离线计算（Spark）
    - 特征工程：用户画像（年龄/性别/偏好分类/活跃时段）+ 内容画像（分类/标签/时长/评分）
    - 排序模型：LightGBM / DeepFM，特征输入 → CTR 预估 → 排序
    - 召回+粗排+精排+重排 四层架构
    - A/B 实验框架：按用户分桶，对比不同策略的 CTR / 完播率
  - 接口设计：
    - `GET /recommend/feed?scene=home&page=1` 首页推荐流
    - `GET /recommend/similar?drama_id=xxx` 相似推荐
    - `GET /recommend/guess` 猜你喜欢
  - 缓存：用户推荐结果 Redis 缓存 30min，滑动窗口分页
- **涉及文件**: 
  - `internal/service/recommend/recommend_service.go` (新建)
  - `internal/service/recommend/hot_score.go` (新建，热度计算)
  - `internal/service/recommend/rule_engine.go` (新建，规则引擎)
  - `internal/service/recommend/recall.go` (新建，召回层)
  - `internal/service/recommend/ranker.go` (新建，排序层)
  - `internal/service/recommend/filter.go` (新建，去重过滤)
  - `internal/service/recommend/ab_test.go` (新建，A/B实验)
  - `internal/job/hot_score_job.go` (新建，热度定时任务)
  - `internal/model/user_preference.go` (新建)
  - `internal/repo/recommend_repo.go` (新建)
- **验收标准**:
  - [ ] MVP 推荐流返回结果多样化，不出现重复内容
  - [ ] 热度分每小时更新，Top50 排序正确
  - [ ] 推荐接口 P99 < 100ms（缓存命中时 < 10ms）
  - [ ] 已观看内容不再重复推荐
  - [ ] A/B 实验框架可按比例分流，指标可追踪
  - [ ] 冷启动用户（无行为）返回热门+编辑推荐

---

## 9. 搜索服务

### SVC-009 搜索服务（ES 索引、中文分词、热搜榜）
- **优先级**: P1
- **预估工时**: 4天
- **依赖**: SVC-001
- **描述**: 基于 Elasticsearch 实现全文搜索，支持中文分词、拼音搜索、搜索联想（suggest）、搜索结果高亮。维护热搜榜和搜索历史。
- **技术要点**: 
  - ES 索引设计（drama_index）：
    - 字段：title, title.pinyin, description, tags, category, actors, director, cp_name, status, score, play_count, created_at
    - 分词器：ik_max_word（索引时细粒度分词）+ ik_smart（搜索时粗粒度分词）
    - 拼音分词器：pinyin analyzer，支持全拼和首字母
    - 同义词：配置同义词词典（如 "甜宠" = "甜蜜" "宠溺"）
  - 搜索功能：
    - 关键词搜索：multi_match 查询，boost 权重 title > tags > description
    - 拼音搜索："tlcg" → "甜蜜陷阱"
    - 搜索联想：completion suggester，输入前缀实时推荐
    - 筛选+排序：按分类/评分/播放量筛选，按相关度/热度/最新排序
    - 结果高亮：匹配关键词 <em> 标签包裹
  - 数据同步：
    - 全量同步：每日凌晨全量重建索引
    - 增量同步：内容变更 → MQ → ES 同步消费者，延迟 < 5s
    - 状态过滤：仅索引 status=published 的内容
  - 热搜榜：
    - Redis ZSet 记录搜索关键词频次，按小时/天聚合
    - 热搜榜展示 Top20，支持人工置顶/屏蔽敏感词
    - 热搜数据每 5min 刷新一次
  - 搜索历史：用户最近 20 条搜索记录，Redis List 存储
- **涉及文件**: 
  - `internal/service/search/search_service.go` (新建)
  - `internal/service/search/index_builder.go` (新建，索引构建)
  - `internal/service/search/suggest_service.go` (新建，搜索联想)
  - `internal/service/search/hot_search.go` (新建，热搜榜)
  - `internal/worker/es_sync_worker.go` (新建，增量同步消费者)
  - `internal/pkg/es/client.go` (新建，ES客户端封装)
  - `config/es/drama_index_mapping.json` (新建，索引映射)
  - `config/es/synonyms.txt` (新建，同义词词典)
  - `internal/job/es_full_sync_job.go` (新建，全量同步定时任务)
- **验收标准**:
  - [ ] 中文搜索准确，"都市甜宠" 可命中相关剧集
  - [ ] 拼音搜索可用，首字母缩写可命中
  - [ ] 搜索联想响应 < 50ms
  - [ ] 热搜榜 Top20 每 5min 更新，可人工干预
  - [ ] 增量同步延迟 < 5s，内容下架后搜索结果 < 10s 消失
  - [ ] 10 万条数据搜索 P99 < 100ms

---

## 10. 通知服务

### SVC-010 通知服务（APNs Push、站内信）
- **优先级**: P1
- **预估工时**: 4天
- **依赖**: SVC-004
- **描述**: 统一通知中心，支持 APNs 远程推送和站内消息。支持按用户/用户群/全量推送，消息模板管理，推送时段控制，未读数管理。
- **技术要点**: 
  - 推送通道：
    - APNs（Apple Push Notification service）：基于 HTTP/2 的 provider API，使用 Token-Based (.p8) 认证
    - 备选：接入极光推送 / 个推作为推送聚合平台
  - 推送类型：
    - 系统通知：版本更新、维护公告
    - 内容通知：关注的剧更新、推荐新剧
    - 营销通知：优惠活动、会员到期提醒
    - 交易通知：购买成功、退款通知
  - 消息模板：
    - 模板表：id, type, title_template, body_template, variables(JSON), channel(push/inbox/both)
    - 变量替换：`{{user.nickname}} 您关注的《{{drama.title}}》更新了第{{episode.number}}集`
  - 推送策略：
    - 免打扰时段：22:00-08:00 不推送营销类消息（紧急通知除外）
    - 频率限制：每用户每天最多 5 条推送
    - 静默推送：更新角标数但不弹窗
  - 站内信：
    - 消息表：id, user_id, type, title, content, is_read, extra_data(JSON), created_at
    - 全局消息：一条记录 + 用户已读位图（bitmap），节省存储
    - 未读数：Redis 计数器，实时更新
  - 批量推送：
    - 全量推送：分批发送（每批 1000），控制 QPS 避免 APNs 限流
    - 用户群推送：按标签/VIP等级/地区筛选用户
    - 异步队列：推送任务写入 MQ，Worker 异步消费执行
  - 推送回执：记录推送是否送达、用户是否点击，统计到达率和点击率
- **涉及文件**: 
  - `internal/service/notification/notify_service.go` (新建)
  - `internal/service/notification/apns_pusher.go` (新建，APNs推送)
  - `internal/service/notification/template_engine.go` (新建，模板渲染)
  - `internal/service/notification/inbox_service.go` (新建，站内信)
  - `internal/service/notification/badge_service.go` (新建，未读数)
  - `internal/worker/push_worker.go` (新建，推送消费者)
  - `internal/model/notification.go` (新建)
  - `internal/model/message_template.go` (新建)
  - `internal/repo/notification_repo.go` (新建)
  - `internal/pkg/apns/client.go` (新建，APNs客户端)
  - `migrations/010_create_notification_tables.sql` (新建)
- **验收标准**:
  - [ ] APNs 推送到达率 > 95%（设备在线时）
  - [ ] 推送模板变量替换正确，支持富文本
  - [ ] 免打扰时段内营销推送自动延迟至次日 08:00
  - [ ] 站内信未读数实时准确
  - [ ] 全量推送 100 万用户 < 30min 完成
  - [ ] 推送点击率可追踪统计

---

## 11. 数据埋点服务

### SVC-011 数据埋点服务（事件采集清洗、实时/离线管道）
- **优先级**: P1
- **预估工时**: 5天
- **依赖**: 无
- **描述**: 建设数据采集和处理管道。客户端和服务端产生的行为事件（播放、点击、购买等）统一采集、清洗、存储，供实时看板和离线分析使用。支持自定义事件和标准化事件体系。
- **技术要点**: 
  - 事件 Schema 设计：
    ```json
    {
      "event_id": "uuid",
      "event_name": "video_play_start",
      "event_time": "2025-01-01T12:00:00Z",
      "user_id": "uid_xxx",
      "device_id": "did_xxx",
      "session_id": "sid_xxx",
      "properties": {
        "drama_id": "d_001",
        "episode_id": "e_001",
        "duration": 30,
        "source": "recommend_feed"
      },
      "context": {
        "app_version": "1.0.0",
        "os": "iOS",
        "os_version": "17.0",
        "device_model": "iPhone15,2",
        "network": "WiFi",
        "ip": "x.x.x.x",
        "country": "CN",
        "city": "Beijing"
      }
    }
    ```
  - 标准事件：app_launch, page_view, video_play_start/pause/complete, ad_show/click, purchase, search, share, like, follow
  - 采集接口：`POST /events/batch` 批量上报（客户端本地攒 10 条或 30s 一次上报）
  - 数据管道：
    - 实时管道：API → Kafka → Flink/ClickHouse → 实时看板（Grafana）
    - 离线管道：Kafka → Flink → Parquet → 对象存储 → Spark → 数仓（Hive/ClickHouse）
  - 数据清洗（Flink）：
    - 去重：基于 event_id 精确去重
    - 补全：IP → 地理位置（GeoIP2）、device_id → 用户关联
    - 校验：必填字段非空、event_time 合理范围（前后 24h）
    - 过滤：机器人流量识别和过滤
  - ClickHouse 表设计：
    - 按天分区，event_name + user_id 排序键
    - 物化视图：PV/UV 日汇总、视频播放量汇总、收入汇总
  - 数据看板：
    - 实时：DAU/MAU、在线人数、实时播放量
    - 日报：留存率、LTV、ARPU、内容消费分布
- **涉及文件**: 
  - `internal/service/analytics/event_service.go` (新建，事件采集接口)
  - `internal/service/analytics/event_validator.go` (新建，事件校验)
  - `internal/service/analytics/kafka_producer.go` (新建)
  - `internal/worker/event_cleaner.go` (新建，Flink清洗Job)
  - `internal/worker/event_aggregator.go` (新建，聚合Job)
  - `internal/pkg/geoip/geoip.go` (新建，IP地理位置)
  - `config/clickhouse/event_schema.sql` (新建，ClickHouse建表)
  - `config/clickhouse/materialized_views.sql` (新建，物化视图)
  - `config/grafana/dashboards/realtime.json` (新建，实时看板)
  - `config/grafana/dashboards/daily_report.json` (新建，日报)
- **验收标准**:
  - [ ] 批量上报接口 P99 < 50ms，支持 10000 QPS
  - [ ] 事件从产生到 ClickHouse 可查 < 10s（实时管道）
  - [ ] 事件去重准确率 100%
  - [ ] GeoIP 解析覆盖率 > 98%
  - [ ] 实时看板数据延迟 < 30s
  - [ ] 离线数据 T+1 可用，Spark 任务凌晨 06:00 前完成

---

## 总结

| 服务 | 任务ID | 优先级 | 工时 | 关键依赖 |
|------|--------|--------|------|----------|
| 内容管理服务 | SVC-001 | P0 | 5天 | API层 |
| 媒资管理服务 | SVC-002 | P0 | 8天 | 无 |
| 播放服务 | SVC-003 | P0 | 5天 | SVC-002 |
| 用户服务 | SVC-004 | P0 | 5天 | 无 |
| 支付服务 | SVC-005 | P0 | 6天 | SVC-004 |
| 会员服务 | SVC-006 | P0 | 4天 | SVC-005 |
| 广告服务 | SVC-007 | P1 | 5天 | SVC-004 |
| 推荐服务 | SVC-008 | P1 | 6天 | SVC-001, SVC-011 |
| 搜索服务 | SVC-009 | P1 | 4天 | SVC-001 |
| 通知服务 | SVC-010 | P1 | 4天 | SVC-004 |
| 数据埋点服务 | SVC-011 | P1 | 5天 | 无 |
| **合计** | | | **57天** | |
