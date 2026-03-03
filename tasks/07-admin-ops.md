# 07 — 运营管理后台 Web端

> React + Ant Design Pro | 共 16 个任务

---

## 1. 后台框架与权限

### ADM-001 后台项目脚手架搭建
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: 无
- **描述**: 基于 Ant Design Pro 搭建运营管理后台项目，配置路由、全局布局（侧边栏+顶部导航+内容区）、国际化基础、主题色、环境变量管理（dev/staging/prod）。集成 ESLint + Prettier + Husky 代码规范。
- **技术要点**: 
  - 使用 `create-umi` 初始化 Ant Design Pro V5 项目
  - 配置 `config/routes.ts` 统一管理路由
  - 封装 `request.ts` 统一请求层（拦截器、token注入、错误处理）
  - 全局 Layout 支持面包屑、页签缓存（keep-alive）
  - 配置 `proxy.ts` 开发环境代理后端 API
- **涉及文件**: 
  - `admin-web/config/config.ts` (新建)
  - `admin-web/config/routes.ts` (新建)
  - `admin-web/config/proxy.ts` (新建)
  - `admin-web/src/app.tsx` (新建)
  - `admin-web/src/utils/request.ts` (新建)
  - `admin-web/package.json` (新建)
- **验收标准**:
  - [ ] 项目可正常启动并展示全局布局
  - [ ] 侧边栏菜单可收缩/展开
  - [ ] 面包屑导航根据路由自动生成
  - [ ] 请求封装支持 token 自动注入与刷新
  - [ ] ESLint + Prettier 校验通过

---

### ADM-002 管理员登录与RBAC权限
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: ADM-001
- **描述**: 实现管理员账号登录（用户名+密码），JWT Token 认证，基于角色的权限控制（RBAC）。角色包括：超级管理员、运营、编辑、审核员、财务、只读。支持菜单级+按钮级权限控制。
- **技术要点**: 
  - 登录页：用户名+密码+图形验证码
  - JWT 双 Token 机制（access_token 30min + refresh_token 7d）
  - 后端 `admin_users` 表 + `roles` 表 + `permissions` 表 + `role_permissions` 关联表
  - 前端通过 `useAccess()` Hook 控制菜单/按钮可见性
  - 路由守卫：未登录跳转登录页，无权限展示403页面
- **涉及文件**: 
  - `admin-web/src/pages/Login/index.tsx` (新建)
  - `admin-web/src/models/user.ts` (新建)
  - `admin-web/src/access.ts` (新建)
  - `admin-web/src/utils/authority.ts` (新建)
  - `server/controllers/admin_auth_controller.go` (新建)
  - `server/models/admin_user.go` (新建)
  - `server/models/role.go` (新建)
  - `server/middleware/admin_jwt.go` (新建)
- **验收标准**:
  - [ ] 管理员可通过用户名密码登录后台
  - [ ] 登录失败5次锁定账号30分钟
  - [ ] 不同角色看到不同的菜单项
  - [ ] 无权限的按钮自动隐藏或置灰
  - [ ] Token 过期后自动刷新，刷新失败跳转登录
  - [ ] 操作日志记录登录/登出行为

---

### ADM-003 管理员账号管理
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: ADM-002
- **描述**: 超级管理员可管理后台账号：新增/编辑/禁用管理员、分配角色、重置密码。展示管理员列表（分页+搜索），支持批量操作。
- **技术要点**: 
  - ProTable 列表展示：账号、姓名、角色、状态、最后登录时间
  - 新增/编辑弹窗：表单校验、角色多选
  - 禁用操作二次确认
  - 重置密码发送临时密码到管理员邮箱
  - 操作审计日志记录
- **涉及文件**: 
  - `admin-web/src/pages/System/AdminList/index.tsx` (新建)
  - `admin-web/src/pages/System/AdminList/components/AdminForm.tsx` (新建)
  - `admin-web/src/services/admin.ts` (新建)
  - `server/controllers/admin_manage_controller.go` (新建)
- **验收标准**:
  - [ ] 管理员列表支持分页、按姓名/角色搜索
  - [ ] 新增管理员并分配角色后可正常登录
  - [ ] 禁用管理员后该账号无法登录
  - [ ] 仅超级管理员可见此页面
  - [ ] 所有操作记录审计日志

---

## 2. 剧集内容管理

### ADM-004 剧集列表与管理
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: ADM-001
- **描述**: 运营后台剧集管理核心页面。展示所有剧集列表（支持多维度筛选），可查看详情、上架/下架、编辑信息、设置收费策略。列表需展示关键运营指标（播放量、付费转化率、评分）。
- **技术要点**: 
  - ProTable 高级筛选：状态（待审核/已上架/已下架/审核拒绝）、分类、上传方、时间范围
  - 批量操作：批量上架/下架/调整分类
  - 行内快捷操作：一键上架、置顶、推荐
  - 列表支持自定义列配置（运营可选择展示哪些列）
  - 数据导出 Excel
- **涉及文件**: 
  - `admin-web/src/pages/Drama/DramaList/index.tsx` (新建)
  - `admin-web/src/pages/Drama/DramaList/components/FilterPanel.tsx` (新建)
  - `admin-web/src/pages/Drama/DramaList/components/BatchActions.tsx` (新建)
  - `admin-web/src/services/drama.ts` (新建)
  - `server/controllers/admin_drama_controller.go` (新建)
- **验收标准**:
  - [ ] 剧集列表支持多维度筛选和搜索
  - [ ] 单个/批量上架、下架操作正常
  - [ ] 列表展示播放量、付费转化率等运营指标
  - [ ] 支持导出 Excel
  - [ ] 操作后列表实时更新

---

### ADM-005 剧集详情与编辑
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: ADM-004
- **描述**: 剧集详情页：基本信息（标题、封面、简介、分类标签）、分集列表（可排序）、收费设置（免费集数、单集价格、会员免费）、运营数据看板（播放趋势、付费数据、用户画像摘要）。
- **技术要点**: 
  - 详情页分Tab展示：基本信息 / 分集管理 / 收费设置 / 数据看板
  - 基本信息编辑：封面上传（裁剪）、富文本简介、标签多选
  - 分集列表：拖拽排序、单集上下架、替换视频
  - 收费设置：免费集数、单集价格、VIP免费开关、限时免费活动
  - 数据看板用 ECharts 图表展示趋势
- **涉及文件**: 
  - `admin-web/src/pages/Drama/DramaDetail/index.tsx` (新建)
  - `admin-web/src/pages/Drama/DramaDetail/components/BasicInfoTab.tsx` (新建)
  - `admin-web/src/pages/Drama/DramaDetail/components/EpisodeTab.tsx` (新建)
  - `admin-web/src/pages/Drama/DramaDetail/components/PricingTab.tsx` (新建)
  - `admin-web/src/pages/Drama/DramaDetail/components/DataTab.tsx` (新建)
- **验收标准**:
  - [ ] 详情页正确展示剧集所有信息
  - [ ] 编辑基本信息后保存成功
  - [ ] 分集可拖拽排序，排序结果持久化
  - [ ] 收费设置修改后前端（App端）立即生效
  - [ ] 数据看板图表正常渲染

---

### ADM-006 分类与标签管理
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: ADM-001
- **描述**: 管理短剧分类体系（一级分类+二级分类）和标签体系（内容标签、风格标签、受众标签）。支持分类的增删改排序、标签的增删改合并。
- **技术要点**: 
  - 分类管理：树形结构展示，拖拽排序，支持图标设置
  - 标签管理：标签分组、标签合并（合并同义标签）、标签热度统计
  - 分类/标签关联剧集数量统计
  - 删除分类前检查是否有关联剧集，有则提示迁移
- **涉及文件**: 
  - `admin-web/src/pages/Drama/CategoryManage/index.tsx` (新建)
  - `admin-web/src/pages/Drama/TagManage/index.tsx` (新建)
  - `admin-web/src/services/category.ts` (新建)
  - `server/controllers/admin_category_controller.go` (新建)
- **验收标准**:
  - [ ] 分类树形结构展示正确，支持拖拽排序
  - [ ] 新增/编辑/删除分类操作正常
  - [ ] 标签支持分组管理和合并
  - [ ] 删除有关联内容的分类时弹出迁移提示
  - [ ] 分类/标签修改后 App 端同步更新

---

## 3. 运营配置

### ADM-007 Banner与推荐位管理
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: ADM-004
- **描述**: 管理 App 端各推荐位内容：首页 Banner 轮播、热门推荐位、编辑精选位、专题位等。支持定时上下线、素材预览、ABTest分组配置。
- **技术要点**: 
  - 推荐位类型：Banner、横滑推荐、榜单、专题
  - 每个推荐位可配置多条内容，支持拖拽排序
  - 定时上下线：设置开始时间和结束时间，后端定时任务执行
  - 素材上传：支持图片+视频封面预览
  - ABTest：同一推荐位配置多个分组，按比例分流
- **涉及文件**: 
  - `admin-web/src/pages/Operation/BannerManage/index.tsx` (新建)
  - `admin-web/src/pages/Operation/RecommendManage/index.tsx` (新建)
  - `admin-web/src/pages/Operation/components/PositionEditor.tsx` (新建)
  - `admin-web/src/services/operation.ts` (新建)
  - `server/controllers/admin_recommend_controller.go` (新建)
- **验收标准**:
  - [ ] Banner 列表展示，支持拖拽排序
  - [ ] 上传 Banner 素材并预览效果
  - [ ] 定时上下线功能正常执行
  - [ ] ABTest 分组配置后按比例分流
  - [ ] App 端推荐位内容与后台配置一致

---

### ADM-008 热搜与排行榜配置
- **优先级**: P2
- **预估工时**: 1.5天
- **依赖**: ADM-004
- **描述**: 配置热搜榜数据来源（自动热度算法+运营人工干预），管理各类排行榜（飙升榜、热播榜、好评榜、新剧榜）的生成规则和人工调整。
- **技术要点**: 
  - 热搜管理：自动热搜词（基于搜索量）+ 运营置顶词 + 屏蔽词
  - 排行榜规则配置：权重公式可调（播放量×a + 付费量×b + 评分×c）
  - 人工干预：置顶/置底/移除某部剧
  - 榜单定时更新频率可配置（每小时/每天）
  - 预览功能：修改规则后预览榜单变化
- **涉及文件**: 
  - `admin-web/src/pages/Operation/HotSearch/index.tsx` (新建)
  - `admin-web/src/pages/Operation/Ranking/index.tsx` (新建)
  - `admin-web/src/pages/Operation/Ranking/components/RuleEditor.tsx` (新建)
  - `server/controllers/admin_ranking_controller.go` (新建)
  - `server/services/ranking_service.go` (修改)
- **验收标准**:
  - [ ] 热搜词列表展示自动+人工置顶词
  - [ ] 可添加/删除置顶热搜词和屏蔽词
  - [ ] 排行榜权重公式可调整
  - [ ] 榜单预览功能正常
  - [ ] 修改后在下次更新周期生效

---

### ADM-009 Push推送管理
- **优先级**: P2
- **预估工时**: 2天
- **依赖**: ADM-001
- **描述**: 管理 App 端推送通知：创建推送任务（立即/定时）、选择推送人群（全量/标签/自定义用户ID列表）、推送内容编辑（标题+内容+跳转链接）、推送记录与效果统计。
- **技术要点**: 
  - 推送创建：标题、内容、图片、跳转DeepLink
  - 人群选择：全量推送、按标签（活跃度/付费等级/偏好分类）、导入用户列表
  - 定时推送：设定推送时间，后端调度执行
  - 对接 APNs（iOS推送）
  - 效果统计：送达率、点击率、跳转转化率
- **涉及文件**: 
  - `admin-web/src/pages/Operation/PushManage/index.tsx` (新建)
  - `admin-web/src/pages/Operation/PushManage/components/PushForm.tsx` (新建)
  - `admin-web/src/pages/Operation/PushManage/components/AudienceSelector.tsx` (新建)
  - `admin-web/src/services/push.ts` (新建)
  - `server/controllers/admin_push_controller.go` (新建)
  - `server/services/push_service.go` (新建)
- **验收标准**:
  - [ ] 创建推送任务并立即/定时发送
  - [ ] 人群选择功能正确（全量/标签/自定义）
  - [ ] 推送记录列表展示历史任务
  - [ ] 效果统计数据准确（送达率、点击率）
  - [ ] 支持取消未发送的定时推送

---

### ADM-010 活动与优惠券管理
- **优先级**: P2
- **预估工时**: 2.5天
- **依赖**: ADM-004
- **描述**: 管理平台营销活动和优惠券体系。活动类型：限时免费、折扣、拉新奖励、签到送币。优惠券：创建/发放/核销/统计。
- **技术要点**: 
  - 活动管理：创建活动（名称、类型、时间、规则、关联剧集）、活动上下线
  - 限时免费：选择剧集+时间段，到期自动恢复收费
  - 优惠券：面额、有效期、使用条件、发放渠道（系统发放/手动发放/活动领取）
  - 优惠券核销统计：发放量、领取量、使用量、核销率
  - 活动效果看板：参与人数、拉新数、付费转化
- **涉及文件**: 
  - `admin-web/src/pages/Marketing/ActivityManage/index.tsx` (新建)
  - `admin-web/src/pages/Marketing/ActivityManage/components/ActivityForm.tsx` (新建)
  - `admin-web/src/pages/Marketing/CouponManage/index.tsx` (新建)
  - `admin-web/src/pages/Marketing/CouponManage/components/CouponForm.tsx` (新建)
  - `admin-web/src/services/marketing.ts` (新建)
  - `server/controllers/admin_marketing_controller.go` (新建)
  - `server/models/activity.go` (新建)
  - `server/models/coupon.go` (新建)
- **验收标准**:
  - [ ] 创建限时免费活动并在 App 端生效
  - [ ] 优惠券创建、发放、核销流程完整
  - [ ] 活动到期后自动下线
  - [ ] 优惠券统计数据准确
  - [ ] 活动效果看板图表正常

---

## 4. 财务与分账

### ADM-011 分账规则配置
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: ADM-002
- **描述**: 配置红果式分账规则：平台分成比例、合作方分成比例（可按合作方/剧集/等级差异化配置）、结算周期、最低结算金额。支持规则版本管理和生效时间控制。
- **技术要点**: 
  - 默认分账规则：平台 X% + 合作方 Y%（X+Y=100）
  - 差异化规则：按合作方等级（S/A/B/C）、按剧集类型、按合作协议
  - 规则优先级：剧集级 > 合作方级 > 默认级
  - 规则版本管理：新规则设定生效时间，不影响历史结算
  - 结算周期：月结/双周结可配置
- **涉及文件**: 
  - `admin-web/src/pages/Finance/ShareRule/index.tsx` (新建)
  - `admin-web/src/pages/Finance/ShareRule/components/RuleForm.tsx` (新建)
  - `admin-web/src/services/finance.ts` (新建)
  - `server/controllers/admin_finance_controller.go` (新建)
  - `server/models/share_rule.go` (新建)
- **验收标准**:
  - [ ] 默认分账比例可配置
  - [ ] 支持按合作方/剧集设置差异化比例
  - [ ] 规则版本管理正常，新规则按时间生效
  - [ ] 结算周期可配置
  - [ ] 规则变更记录审计日志

---

### ADM-012 分账账单与结算
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: ADM-011
- **描述**: 分账账单管理：自动生成分账账单（按结算周期）、账单明细（每部剧每天的收入和分成）、账单审核流程（财务审核→主管审批→执行打款）、打款状态跟踪。
- **技术要点**: 
  - 账单自动生成：定时任务按周期汇总收入，计算各方分成
  - 账单明细：合作方、剧集、日期、总收入、平台分成、合作方分成
  - 审核流程：待审核→财务确认→主管审批→待打款→已打款
  - 打款对接：导出银行打款文件 / 对接第三方支付（预留）
  - 对账功能：账单金额与支付流水核对
- **涉及文件**: 
  - `admin-web/src/pages/Finance/BillManage/index.tsx` (新建)
  - `admin-web/src/pages/Finance/BillManage/components/BillDetail.tsx` (新建)
  - `admin-web/src/pages/Finance/BillManage/components/AuditFlow.tsx` (新建)
  - `admin-web/src/services/bill.ts` (新建)
  - `server/controllers/admin_bill_controller.go` (新建)
  - `server/services/bill_service.go` (新建)
  - `server/jobs/bill_generate_job.go` (新建)
- **验收标准**:
  - [ ] 账单按结算周期自动生成
  - [ ] 账单明细数据准确（精确到分）
  - [ ] 审核流程流转正常
  - [ ] 打款文件可导出
  - [ ] 对账功能可检测差异

---

### ADM-013 收入数据看板
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: ADM-012
- **描述**: 财务数据总览看板：总收入趋势、各合作方收入排名、各剧集收入排名、付费用户统计、ARPU/ARPPU指标。支持时间范围筛选和数据导出。
- **技术要点**: 
  - 顶部指标卡：今日收入、本月收入、环比/同比增长
  - 折线图：收入趋势（日/周/月粒度切换）
  - 柱状图：TOP20 合作方收入排名、TOP20 剧集收入排名
  - 饼图：收入来源构成（单集付费/VIP/广告）
  - 数据聚合从 ClickHouse 或预计算表查询，避免实时计算
- **涉及文件**: 
  - `admin-web/src/pages/Finance/Dashboard/index.tsx` (新建)
  - `admin-web/src/pages/Finance/Dashboard/components/IncomeChart.tsx` (新建)
  - `admin-web/src/pages/Finance/Dashboard/components/RankingTable.tsx` (新建)
  - `admin-web/src/pages/Finance/Dashboard/components/MetricCards.tsx` (新建)
  - `server/controllers/admin_finance_dashboard_controller.go` (新建)
- **验收标准**:
  - [ ] 指标卡数据实时准确
  - [ ] 收入趋势图支持日/周/月粒度切换
  - [ ] 排名数据与实际账单一致
  - [ ] 时间范围筛选功能正常
  - [ ] 数据可导出 Excel

---

## 5. 用户管理

### ADM-014 用户列表与管理
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: ADM-001
- **描述**: App 端用户管理：用户列表（搜索/筛选/分页）、用户详情（基本信息、观看记录、付费记录、设备信息）、用户操作（封禁/解封、VIP调整、虚拟币调整）。
- **技术要点**: 
  - ProTable 列表：用户ID、昵称、手机号（脱敏）、注册时间、VIP状态、累计付费
  - 筛选条件：注册时间、VIP状态、付费等级、活跃度
  - 用户详情页：基本信息Tab + 观看记录Tab + 付费记录Tab + 设备信息Tab
  - 操作记录：所有对用户的操作都记录审计日志
  - 敏感操作（封禁、调整VIP/币）需要二次确认+原因填写
- **涉及文件**: 
  - `admin-web/src/pages/User/UserList/index.tsx` (新建)
  - `admin-web/src/pages/User/UserDetail/index.tsx` (新建)
  - `admin-web/src/pages/User/UserDetail/components/WatchHistory.tsx` (新建)
  - `admin-web/src/pages/User/UserDetail/components/PaymentHistory.tsx` (新建)
  - `admin-web/src/services/user.ts` (新建)
  - `server/controllers/admin_user_controller.go` (新建)
- **验收标准**:
  - [ ] 用户列表支持多维度搜索和筛选
  - [ ] 手机号等敏感信息脱敏展示
  - [ ] 用户详情页信息完整
  - [ ] 封禁/解封操作正常，封禁用户无法使用App
  - [ ] 所有操作记录审计日志

---

### ADM-015 用户反馈与投诉
- **优先级**: P2
- **预估工时**: 1.5天
- **依赖**: ADM-014
- **描述**: 管理用户反馈和投诉工单：工单列表（按类型/状态筛选）、工单详情（用户信息+反馈内容+截图）、处理流程（分配→处理→回复→关闭）、处理时效统计。
- **技术要点**: 
  - 工单类型：Bug反馈、内容投诉、付费问题、建议、其他
  - 工单状态：待分配→处理中→待回复→已回复→已关闭
  - 工单分配：手动分配给处理人 / 自动按类型分配
  - 回复功能：文字回复，可插入模板话术
  - 时效统计：平均响应时间、平均处理时间、超时工单数
- **涉及文件**: 
  - `admin-web/src/pages/User/Feedback/index.tsx` (新建)
  - `admin-web/src/pages/User/Feedback/components/FeedbackDetail.tsx` (新建)
  - `admin-web/src/pages/User/Feedback/components/ReplyEditor.tsx` (新建)
  - `admin-web/src/services/feedback.ts` (新建)
  - `server/controllers/admin_feedback_controller.go` (新建)
- **验收标准**:
  - [ ] 工单列表支持按类型/状态/时间筛选
  - [ ] 工单分配和流转正常
  - [ ] 回复内容可使用模板话术
  - [ ] 处理时效统计数据准确
  - [ ] 超时工单自动标红告警

---

## 6. 系统设置

### ADM-016 系统配置与操作日志
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: ADM-002
- **描述**: 系统全局配置管理（App版本控制、强制更新开关、维护模式开关、全局公告）和操作审计日志（所有管理员操作的查询与追溯）。
- **技术要点**: 
  - 配置管理：Key-Value配置项，支持JSON类型，修改即时生效
  - 常用配置：App最低版本、强制更新开关、维护模式、全局公告内容
  - 配置修改历史：谁在什么时间改了什么
  - 操作日志：记录所有管理员的增删改操作
  - 日志查询：按操作人、操作类型、时间范围、资源类型筛选
  - 日志保留策略：90天内明细，90天以上聚合
- **涉及文件**: 
  - `admin-web/src/pages/System/Config/index.tsx` (新建)
  - `admin-web/src/pages/System/AuditLog/index.tsx` (新建)
  - `admin-web/src/services/system.ts` (新建)
  - `server/controllers/admin_config_controller.go` (新建)
  - `server/controllers/admin_audit_controller.go` (新建)
  - `server/models/audit_log.go` (新建)
  - `server/middleware/audit_middleware.go` (新建)
- **验收标准**:
  - [ ] 全局配置可在线修改并即时生效
  - [ ] 配置修改历史可追溯
  - [ ] 操作日志记录所有管理员操作
  - [ ] 日志支持多维度查询
  - [ ] 强制更新/维护模式开关正常工作
  - [ ] 日志数据90天后自动聚合归档
