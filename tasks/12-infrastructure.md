# 基础设施

> 数据库、缓存、消息队列、存储、CDN、转码、监控、CI/CD

---

### INF-001 数据库设计
- **优先级**: P0
- **预估工时**: 5天
- **依赖**: 无
- **描述**: 设计全量数据库表结构，覆盖用户、内容、订单、合作方、分账、审核、埋点所有业务。
- **技术要点**:
  - 用户库：users, devices, user_sessions, watch_history, favorites, memberships
  - 内容库：dramas, episodes, tags, drama_tags, banners, topics, rankings
  - 订单库：orders, payments, refunds, coins_transactions
  - 合作方库：partners, partner_qualifications, partner_contracts, partner_bank_info
  - 分账库：billing_events, billing_rules, rule_versions, settlements, reconciliations, invoices
  - 审核库：reviews, review_evidences, review_operations, qualifications
  - 广告库：ad_configs, ad_events, ad_revenues
  - 索引设计：按查询频率建立合适索引
  - 分库分表策略：用户相关按 user_id 分，内容相关按 drama_id 分
  - 使用 MySQL 8.0 / PostgreSQL 15
- **涉及文件**: `backend/database/migrations/`, `backend/database/schema.sql`
- **验收标准**:
  - [ ] 表结构覆盖所有业务
  - [ ] 索引合理
  - [ ] 支持百万级数据量
  - [ ] 有完整的 migration 脚本

### INF-002 Redis缓存层
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: INF-001
- **描述**: 搭建Redis缓存层，缓存热门内容、用户Session、播放进度、排行榜等高频数据。
- **技术要点**:
  - 热门内容：首页/频道页数据缓存，TTL 5分钟
  - 用户Session：JWT Token + Redis 存储会话信息
  - 播放进度：Hash结构，user:progress → {episode_id: position}
  - 排行榜：Sorted Set，按播放量/热度实时排名
  - 分布式锁：Redlock，用于结算等关键操作
  - 缓存穿透/击穿防护：布隆过滤器 + 互斥锁
- **涉及文件**: `backend/cache/`, `backend/config/redis.py`
- **验收标准**:
  - [ ] 缓存命中率 > 80%
  - [ ] 排行榜实时更新
  - [ ] 缓存穿透防护生效

### INF-003 消息队列Kafka
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: 无
- **描述**: 搭建Kafka集群，用于埋点事件流、分账事件流、审核任务流。
- **技术要点**:
  - Topic设计：analytics_events, billing_events, review_tasks, notification_events
  - 分区：按 user_id hash 分区，保证同一用户事件有序
  - Consumer Group：每种消费场景独立 Group
  - 数据保留：7天
  - 监控：消费延迟、堆积量告警
- **涉及文件**: `backend/config/kafka.py`, `backend/mq/`
- **验收标准**:
  - [ ] 消息不丢失
  - [ ] 消费延迟 < 5秒
  - [ ] 堆积告警正常

### INF-004 对象存储OSS
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: 无
- **描述**: 配置对象存储服务，存储视频原片、转码文件、封面图、资质材料等。
- **技术要点**:
  - Bucket设计：videos-raw(原片), videos-transcoded(转码), images(图片), documents(资质)
  - 权限：videos/images 公开读（通过CDN），documents 私有（签名URL访问）
  - 生命周期：原片保留90天后转低频存储
  - 跨区域复制：可选，容灾
  - 上传：服务端签名 + 客户端直传
- **涉及文件**: `backend/storage/oss.py`, `backend/config/oss.py`
- **验收标准**:
  - [ ] 上传/下载正常
  - [ ] 权限控制正确
  - [ ] 签名URL生效

### INF-005 CDN配置
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: INF-004
- **描述**: 配置CDN加速视频分发和图片加载，设置防盗链。
- **技术要点**:
  - 视频CDN：HLS切片分发，就近节点
  - 图片CDN：封面/海报/头像加速
  - 防盗链：Referer白名单 + URL签名（时间戳+token）
  - HTTPS：全站HTTPS
  - 缓存策略：视频切片长期缓存，API响应不缓存
- **涉及文件**: `backend/config/cdn.py`
- **验收标准**:
  - [ ] 视频播放流畅（首屏 < 2秒）
  - [ ] 防盗链生效
  - [ ] CDN命中率 > 90%

### INF-006 视频转码服务
- **优先级**: P0
- **预估工时**: 4天
- **依赖**: INF-004
- **描述**: 视频上传后自动触发转码，输出多码率HLS格式。
- **技术要点**:
  - 转码配置：360p(500kbps) / 480p(800kbps) / 720p(1500kbps) / 1080p(3000kbps)
  - 输出格式：HLS(.m3u8 + .ts)，切片10秒
  - 自动截图：每隔10秒截取一帧，用于封面候选
  - 转码引擎：FFmpeg 自建 或 阿里云/腾讯云转码服务
  - 回调：转码完成后回调通知，更新内容状态
  - 并发控制：同时最多N个转码任务
- **涉及文件**: `backend/transcode/`, `backend/config/transcode.py`
- **验收标准**:
  - [ ] 四种码率输出正确
  - [ ] HLS播放兼容
  - [ ] 转码完成回调正常
  - [ ] 10分钟视频转码 < 5分钟

### INF-007 日志系统ELK
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: 无
- **描述**: 搭建ELK(Elasticsearch+Logstash+Kibana)日志系统。
- **技术要点**:
  - 应用日志：后端服务日志（INFO/WARN/ERROR），结构化JSON
  - 访问日志：API请求日志（URL/状态码/耗时/IP）
  - 错误日志：异常堆栈、告警
  - Logstash：日志采集、解析、转发
  - Kibana：日志检索、可视化面板
  - 日志保留：30天
- **涉及文件**: `backend/config/logging.py`, `infrastructure/elk/`
- **验收标准**:
  - [ ] 日志检索响应 < 3秒
  - [ ] 错误日志自动告警
  - [ ] 面板展示正常

### INF-008 监控告警
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: 无
- **描述**: 搭建Prometheus+Grafana监控系统，监控服务健康、API性能、业务指标。
- **技术要点**:
  - 服务指标：CPU/内存/磁盘/网络
  - API指标：QPS、响应时间P50/P95/P99、错误率
  - 业务指标：DAU、播放量、付费转化率、审核通过率
  - 告警规则：错误率>5%、P99>3秒、服务不可用
  - 告警通道：飞书/邮件/短信
- **涉及文件**: `infrastructure/prometheus/`, `infrastructure/grafana/`
- **验收标准**:
  - [ ] 监控面板完整
  - [ ] 告警及时（<1分钟）
  - [ ] 历史数据可回看

### INF-009 CI/CD流水线
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: 无
- **描述**: 搭建自动化构建、测试、部署流水线。
- **技术要点**:
  - iOS：Fastlane 自动打包 → TestFlight 分发
  - 后端：Docker 构建 → 镜像仓库 → K8s/Docker Compose 部署
  - Web前端：npm build → OSS/CDN 部署
  - 触发：Git push 到 main/develop 分支自动触发
  - 环境：dev / staging / production 三套环境
  - 回滚：一键回滚到上一版本
- **涉及文件**: `.github/workflows/`, `Fastfile`, `Dockerfile`, `docker-compose.yml`
- **验收标准**:
  - [ ] Push 后自动构建
  - [ ] 测试通过后自动部署到 staging
  - [ ] Production 部署需手动确认
  - [ ] 回滚 < 5分钟

### INF-010 API网关
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: 无
- **描述**: 搭建统一API网关，处理鉴权、限流、灰度、日志、跨域。
- **技术要点**:
  - 技术选型：Kong / Nginx + Lua / 自建 Go 网关
  - 鉴权：JWT验证，Token过期自动刷新
  - 限流：IP级别 + 用户级别，漏桶/令牌桶算法
  - 灰度：按用户ID/设备ID/IP/比例灰度路由
  - 日志：请求/响应日志记录
  - 跨域：CORS配置（后台Web端需要）
  - 健康检查：后端服务健康探测
- **涉及文件**: `infrastructure/gateway/`, `backend/config/gateway.py`
- **验收标准**:
  - [ ] 鉴权正确
  - [ ] 限流生效
  - [ ] 灰度路由可控
  - [ ] 单点无故障（高可用）
