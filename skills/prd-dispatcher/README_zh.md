# PRD Dispatcher

PRD 生成顶层调度器。捕获所有 PRD 生成请求，分析复杂度，确认路由方案，再委托给对应 Skill 执行。

## 激活方式

说出以下任一指令即可激活调度器：
- `"帮我生成一个XXX的PRD"`
- `"帮我生成PRD"`
- `"生成PRD"`
- `"帮我写PRD"`
- `"写一个PRD"`

## 工作流程

```
用户输入 → 调度器（分析）→ 用户确认路由 → 对应 Skill 执行
```

1. **接收**：原样保存用户的原始需求
2. **分析**：判断为简单型 / 已有PRD / 复杂型 / 不确定型
3. **确认**：向用户展示分析结果和推荐路由方案
4. **委托**：根据用户确认调用对应 Skill

## 路由指南

| 类型 | 判断条件 | 推荐路由 |
|------|---------|---------|
| 简单型 | < 100字，单一功能，常见平台 | prd-autofill |
| 已有PRD型 | 用户提供了文本或文件路径 | prd-deep-expand |
| 复杂型 | > 200字，多功能，特殊平台 | prd-conversational |
| 不确定型 | 描述模糊，需求不明确 | prd-conversational |

## 技能一览

| 技能 | 触发 | 核心价值 |
|------|------|---------|
| prd-dispatcher | PRD 请求（通用） | 顶层入口，路由决策 |
| prd-autofill | 简单型 | 一句话进，详细 PRD 出 |
| prd-conversational | 复杂/模糊型 | 15问对话，精准澄清 |
| prd-deep-expand | 已有草稿 | 六维度深度扩展 |
| prd-orchestrator | 串联执行 | 方案 A→B→C 串联 |

## 示例

用户: `"帮我生成一个三国斗地主的PRD"`

调度器分析：
- 类型：复杂型（多功能：卡牌系统、AI、像素美术、游戏规则）
- 检测到功能：5+
- 平台：Web（从像素游戏推断）

调度器确认：
```
推荐：prd-conversational（复杂型）
原因：多功能像素卡牌游戏需要充分的需求澄清。

选项：
A) prd-autofill    - 快速，全自动
B) prd-conversational - 精准，引导式
C) prd-deep-expand   - 已有草稿时使用

请选择：[推荐 B]
```

用户确认 B 后：
```
正在调用 prd-conversational 进行需求澄清...
[移交给 prd-conversational skill]
```
