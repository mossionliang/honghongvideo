# redredvideo — 主任务清单

> 乐播App短剧 + 红果式分账 + 第三方入驻上传 + 合规AI审查 完整平台
>
> iOS 项目 (Objective-C) | AI 比赛项目，AI 功能是核心亮点

---

## 📊 项目概览

| 模块 | 文件 | 任务数 | P0 | P1 | P2 | P3 |
|------|------|--------|----|----|----|----|
| App端UI与交互 | [tasks/01-app-ui.md](tasks/01-app-ui.md) | 40 | 12 | 14 | 10 | 4 |
| 网络层与数据层 | [tasks/02-network-data.md](tasks/02-network-data.md) | 10 | 4 | 4 | 2 | 0 |
| 后端API服务 | [tasks/03-backend-api.md](tasks/03-backend-api.md) | 20 | 8 | 8 | 4 | 0 |
| 后端核心服务 | [tasks/04-backend-services.md](tasks/04-backend-services.md) | 11 | 4 | 5 | 2 | 0 |
| 计费分账引擎 | [tasks/05-billing-engine.md](tasks/05-billing-engine.md) | 17 | 5 | 7 | 4 | 1 |
| AI合规引擎（比赛核心）⭐ | [tasks/06-ai-compliance.md](tasks/06-ai-compliance.md) | 30 | 12 | 10 | 5 | 3 |
| 运营管理后台 | [tasks/07-admin-ops.md](tasks/07-admin-ops.md) | 16 | 3 | 7 | 4 | 2 |
| 内容审核后台 | [tasks/08-admin-review.md](tasks/08-admin-review.md) | 10 | 4 | 4 | 2 | 0 |
| 合作方Portal | [tasks/09-partner-portal.md](tasks/09-partner-portal.md) | 11 | 4 | 4 | 2 | 1 |
| 反作弊与风控 | [tasks/10-anti-fraud.md](tasks/10-anti-fraud.md) | 10 | 3 | 4 | 2 | 1 |
| 数据埋点 | [tasks/11-analytics.md](tasks/11-analytics.md) | 12 | 3 | 5 | 3 | 1 |
| 基础设施 | [tasks/12-infrastructure.md](tasks/12-infrastructure.md) | 10 | 5 | 3 | 2 | 0 |
| **合计** | | **197** | **67** | **75** | **42** | **13** |

---

## 🚀 开发阶段建议

### Phase 1 — 基础骨架（第1-2周）
> 目标：App能跑起来，能看到短剧列表和播放视频

| 优先级 | 任务 |
|--------|------|
| P0 | INF-001 数据库设计 |
| P0 | INF-002 缓存层 Redis |
| P0 | INF-004 对象存储 |
| P0 | INF-005 CDN配置 |
| P0 | INF-010 API网关 |
| P0 | NET-001 网络请求框架 |
| P0 | NET-002 API接口管理 |
| P0 | NET-003 Token认证 |
| P0 | NET-006 本地数据库 |
| P0 | APP-001 TabBar |
| P0 | APP-002 短剧首页 |
| P0 | APP-011 播放器框架 |
| P0 | APP-014 HLS播放 |
| P0 | API-001 登录注册 |
| P0 | API-003 短剧列表 |
| P0 | API-004 短剧详情 |
| P0 | API-005 集数列表 |
| P0 | API-006 播放地址 |
| P0 | SVC-001 内容管理 |
| P0 | SVC-002 媒资管理 |
| P0 | SVC-003 播放服务 |
| P0 | SVC-004 用户服务 |

### Phase 2 — AI合规引擎（第2-4周）⭐ 比赛核心
> 目标：完整的AI审核链路，这是比赛得分关键

| 优先级 | 任务 |
|--------|------|
| P0 | AI-001 AI服务框架 |
| P0 | AI-002~005 OCR识别 |
| P0 | AI-006 资质字段提取 |
| P0 | AI-011~014 视频画面检测 |
| P0 | AI-015 敏感词检测 |
| P0 | AI-018 风险分引擎 |
| P0 | AI-020~022 备案号校验 |
| P0 | AI-023 审核流程引擎 |
| P1 | AI-007~010 交叉校验/预警/篡改检测 |
| P1 | AI-016~017 字幕审查/价值观检测 |
| P1 | AI-019 证据链 |
| P1 | AI-024 风险分级流转 |
| P1 | AI-025~026 AI生成摘要/海报 |

### Phase 3 — 付费与分账（第3-5周）
> 目标：打通付费链路和分账引擎

| 优先级 | 任务 |
|--------|------|
| P0 | APP-027~028 付费墙+IAP |
| P0 | BIL-001~004 计费事件+分账引擎 |
| P1 | BIL-005~007 IAA/IAP/会员分账规则 |
| P1 | BIL-012~014 结算/对账 |
| P1 | APP-021~026 广告系统 |
| P1 | API-012~015 广告+支付接口 |

### Phase 4 — 平台与运营（第4-6周）
> 目标：管理后台、合作方Portal、审核后台

| 优先级 | 任务 |
|--------|------|
| P0 | ADM-001~002 后台框架+权限 |
| P0 | REV-001~004 审核工作台 |
| P0 | PTR-001~003 合作方入驻 |
| P1 | ADM-003~012 运营管理页面 |
| P1 | PTR-005~008 内容上传+收益 |

### Phase 5 — 增长与风控（第5-7周）
> 目标：反作弊、埋点、优化

| 优先级 | 任务 |
|--------|------|
| P1 | EVT-001~012 埋点系统 |
| P1 | FRD-001~010 反作弊 |
| P2 | APP-033~037 互动增长 |
| P2 | ADM-013~016 数据看板 |

---

## 📋 任务状态标记

- `[ ]` 未开始
- `[~]` 进行中
- `[x]` 已完成
- `[!]` 阻塞

---

## 🏗 技术栈

| 层 | 技术 |
|----|------|
| iOS App | Objective-C, UIKit, AVFoundation, CoreData |
| 网络 | AFNetworking / NSURLSession |
| 播放器 | AVPlayer + 自定义控件, 乐播SDK(投屏) |
| 后端P |
| 管理后台 | React/Vue + Ant Design |(待定) | 接口先定义，语言后选 |
| AI服务 | 大模型API + OCR + 视频理解 + NL
| 基础设施 | MySQL/PostgreSQL, Redis, Kafka, OSS, CDN, ES |

---

## ⚠️ 关键风险

1. **Apple审核风险** — IAP必须走苹果支付，虚拟货币需符合苹果政策
2. **内容合规风险** — 短剧必须有备案号才能上架，AI审核是关键
3. **版权风险** — 必须建立完整的版权链路追踪
4. **分账精度** — 涉及真金白银，计算和对账必须精确
5. **性能风险** — 竖屏短剧场景对播放器性能要求高（快速滑动切集）
