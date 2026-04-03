# VSCode 适配器

本适配器提供 VSCode 扩展，用于浏览和查看 PRD 生成器技能库。

## 安装方式

### 方式一：复制扩展目录
```bash
cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator
```

### 方式二：打包为 .vsix 并安装
```bash
cd adapters/vscode
npm install -g @vscode/vsce
vsce package
code --install-extension prompt-lab-prd-generator-1.0.0.vsix
```

### 方式三：使用 Makefile
```bash
make install-vscode
```

## 使用方法

1. 安装扩展后，重新加载 VSCode 窗口
2. 按 `Ctrl+Shift+P`（或 `Cmd+Shift+P`）打开命令面板
3. 输入 `显示 PRD 生成器技能库` 并选择
4. 从列表中选择要查看的技能

## 工作原理

本扩展为**内容展示型**，用于在 VSCode 中快速查阅技能文档。
由于 VSCode 原生不支持 Claude Code 风格的 skill 系统，
本适配器通过 WebView 命令面板提供技能浏览功能。

## 技能展示

扩展会读取 `skills/` 目录下的所有技能文件夹，
提取每个技能的 SKILL.md 文件并以 Markdown 预览方式展示。
