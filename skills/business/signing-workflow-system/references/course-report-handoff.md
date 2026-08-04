# Course Report Handoff — 小ice → 小p

How 小ice prepares content for 小p to write course reports for 深圳技术大学《项目与劳动实践III》.

## Report Template Structure (深圳技术大学)

The template (docx format) contains:

**Cover page fields:**
- 课程名称 / 课程编号 / 任课教师
- 学生：冯冰莹 学号：_____
- 班级 / 报告地点 / 报告时间 / 提交时间
- 分数（留空由教师填写）

**Report sections (in the single table):**

| Section | Description |
|---------|-------------|
| 一、报告内容 | 项目主体，含6个子节 |
| ├ 项目背景与意义，需求分析与项目内容 | Why this project, what problem it solves |
| ├ 项目相关概念与技术 | Technologies, tools, frameworks used |
| ├ 项目系统与功能设计 | System architecture, functional modules |
| ├ 项目关键技术与实现 | Core implementation details, key code/solutions |
| ├ 项目部署与测试 | Deployment environment, test results |
| └ 参考文献 | References |
| 二、总结与感悟 | Personal gains, problems encountered, reflections |
| 指导教师批阅意见 | Teacher's remarks (留空) |
| 课程报告成绩评定 | Score (留空) |
| 课程总成绩评定 | Final grade (留空) |

## 6-Category Knowledge Export Format

When 小ice exports system knowledge for 小p to write reports, use this structure:

1. **技术栈** — Table: Layer | Specific Technology (model, framework, rendering tools, push channels, environment)
2. **系统目录树** — File tree + one-line description per component
3. **完整客户案例** — Complete execution record: phase-by-phase with actual file outputs
4. **关键实现片段** — Code/config snippets: HTML template core, cronjob config, interaction patterns
5. **部署环境** — OS, Hermes setup, provider endpoints, rendering toolchain
6. **困难与学习点** — Problems encountered and solutions, formatted as table

## docx Template Extraction Workflow

When the report template is provided as a .docx file:

```bash
# 1. Install dependency (uses hermes-agent venv via uv)
uv pip install python-docx

# 2. Write extraction script to /tmp/ (avoid heredoc quoting issues in inline python3 -c)
cat > /tmp/read_docx.py << 'PYEOF'
import docx
doc = docx.Document('/path/to/template.docx')
# Print all paragraphs with style names
for i, para in enumerate(doc.paragraphs):
    text = para.text.strip()
    if text:
        print(f'[{para.style.name}] {text}')
# Print all tables
for t_idx, table in enumerate(doc.tables):
    print(f'\nTable {t_idx+1}:')
    for r_idx, row in enumerate(table.rows):
        cells = [c.text.strip() for c in row.cells]
        print(f'  Row {r_idx}: {cells}')
PYEOF

# 3. Execute with uv's python (not system python)
$(uv python find) /tmp/read_docx.py
```

**Pitfalls to avoid:**
- `pip install python-docx` fails with `externally-managed-environment` on Debian/Ubuntu — must use `uv pip install`
- `python3 -c "..."` with long scripts fails on quoting/escaping issues — write script to file instead
- System `python3` doesn't see uv-installed packages — use `$(uv python find)` or `uv run python3`

## Session Data (Append-Only Log)

### 2026-06-20: First Knowledge Export

**Context:** 大ice asked 小ice to analyze the 深圳技术大学 report template and share system information with 小p for report writing.

**Template extracted:** 深圳技术大学《项目与劳动实践III》course report (docx, 38269 bytes)
- Single-table format with report sections in Row 0, teacher remarks in Row 1
- No heading styles used — all paragraphs are [Normal]
- Cover page has embedded table with field labels

**Client case exported:** 洪女士 & 张先生
- 友邦 AIA 环宇盈活储蓄保险计划 | USD 150,000 | 5 Pay
- 签约日期: 2026-06-24, 永明签单中心, 海港城港威大厦5座12楼
- VIP 跨境, 需粤语交流
- 所有阶段已完成 (presign/insign/postsign all ✅)
- 0项差异, 无变更

**System architecture exported:**
- 5 core skill files (presign-agent, insign-agent, postsign-agent, image-designer, main orchestrator)
- 3 triggers (工单确认→行程, T-1提醒, 签单日收集)
- 4 phases (签单前/中/后/循环)
- 15 reference files documenting lessons learned
- 2 production clients (杨洪伟 ✅ completed, 陈太 presign-only) + 1 test client (王永生 ✅)

---

### 2026-06-20: Detailed Data Export (大ice要求充实报告至6000-8000字)

**Context:** 大ice对初版报告满意但要求"更详细一些"。大ice→小p→小ice逐条索要补充数据，5大类（数字/过程/案例/技术/收获）。

**时间线（实测数据）：**

| 事件 | 日期 | 备注 |
|------|------|------|
| 立项&SOUL.md定型 | 约2026-05-15 | 小ice身份+业务流程定型 |
| 首单跑通（杨洪伟） | 2026-05-17→05-18 | 全流程首次验证 |
| 次单（李女士、张小姐） | 2026-05-28→05-29 | 新增海报推送能力 |
| VIP演示（洪女士、张先生） | 2026-06-15 | USD 150K, 项目展示标杆 |

**客户统计（去重实测）：**
- 累计处理：5组（杨洪伟、陈太、王永生、李女士-张小姐、洪女士-张先生）
- 活跃：2组 | 归档：3组 | 全部为储蓄分红险

**三次关键迭代（v1→v2→v3）：**

| 版本 | 时间 | 核心变更 | 踩坑 |
|------|------|----------|------|
| v1 最小可行 | 5/17 | 手动行程文字→截图转发，无海报无推送 | — |
| v2 海报+推送 | 5/28 | itinerary.png生成，WeCom推送 | 一次推两张图、暴露技术路径、A4尺寸、wkhtmltoimage卡死 |
| v3 事件驱动 | 6/15 | 3触发器固化(cronjob)、视觉检查、华文行楷字体、VIP标签 | MEDIA被后续文字淹没、测试忘记恢复cronjob |

**两个标杆案例：**
- **案例A 洪女士-张先生**：VIP跨境，USD 150K 5 Pay，友邦环宇盈活，永明签单中心，4方联系人（用车/陪同/对接），粤语需求
- **案例B 王永生**：差异自动检出3项（↑保额10W→15W/+早期保障/预缴2年），手工对比需15-30分钟，系统数秒出报告

**技术架构（三段流水线）：**
```
工单确认 ──→ presign-agent ──→ 行程+海报+提醒
（T-1天）──→ CRON提醒 → 推送顾问  
签单日   ──→ insign-agent ──→ 解析差异 → 顾问确认
          ──→ postsign-agent → 逐项填缴费 → 缴费海报 → 归档
```

**系统规模：**
- 核心 SKILL.md × 1（545行，25KB）
- 子agent详细设计 × 4 | 参考文档 × 12 | HTML模板 × 2
- 触发工作流 × 3 | 客户索引系统（活跃+归档）

**海报生成核心流程：**
```
HTML模板 → 变量替换（客户名/金额/日期/地点/联系人/VIP标识）
         → Hermes内置browser截图 → 视觉检查（无遮挡、标题净空）
         → 单张PNG推送 → 顾问确认
尺寸：1080×1920 手机竖屏
字体：华文行楷（STXingkai）书法字体
```

**推送控制铁律（踩坑沉淀）：**
```yaml
single_pull: true          # 一次只推一张图
no_technical_path: true    # 不显示文件路径
media_first: true          # MEDIA: 语法独占首行
test_recover: true         # 测试完立刻恢复 cronjob
no_duplicate: true         # 每条提醒只推一次
```

**踩坑完整列表（过程记录→成文用）：**

| 领域 | 问题 | 解决 |
|------|------|------|
| 推送 | 一次推两张海报 | 改为单次单张原则 |
| 推送 | 消息暴露技术路径 | 黑箱化：只说"已保存" |
| 推送 | 测试后忘记恢复cronjob | 加即时恢复检查点 |
| 推送 | MEDIA被后续文字淹没 | MEDIA独占首行+不超过一行说明 |
| 海报 | wkhtmltoimage卡死(Chromium下载) | 改用Hermes内置browser截图 |
| 海报 | 生成后图片尺寸A4(792x1131) | 改为手机竖屏1080×1920 |
| 海报 | 标题区被VIP标签遮挡 | 加视觉检查：标题区域保持净空 |
| 海报 | 背景图img标签class丢失 | 正则匹配完整标签含class属性 |
| 流程 | 一次性列出所有待填字段 | 改为逐项引导（一项一问） |
| 平台 | WeCom不支持流式/edit_message | 改为分步推送，每步完成后即推短消息 |
