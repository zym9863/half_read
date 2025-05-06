# 半阅 (Half Read)

[English](README_EN.md) | 简体中文

一个基于Flutter开发的文本摘要应用，使用Gemini API进行文本摘要生成。

## 功能特点

- **文本摘要生成**：输入文本，快速生成简洁的摘要
- **可调节的推理深度**：支持低/中/高三种推理深度，根据需求调整摘要质量
- **分屏阅读模式**：支持原文和摘要并排显示的分屏模式
- **深色/浅色主题**：自动适应系统主题设置
- **API密钥管理**：安全存储Gemini API密钥

## 技术实现

- 使用**Provider**进行状态管理
- 通过**HTTP**请求与Gemini API通信
- 使用**SharedPreferences**存储API密钥
- 采用**Material Design 3**设计语言
- 支持中文界面

## 项目结构

```
lib/
├── models/         # 数据模型
├── providers/      # 状态管理
├── screens/        # 界面
├── services/       # API服务
├── widgets/        # UI组件
└── main.dart       # 应用入口
```

## API集成

应用使用Gemini API (gemini-2.5-flash-preview-04-17) 进行文本摘要生成，通过以下端点：
```
https://zym9863-gemini.deno.dev/v1/chat/completions
```

## 使用方法

1. 启动应用后，首次使用需要设置Gemini API密钥
2. 在输入框中输入需要摘要的文本
3. 选择合适的推理深度（低/中/高）
4. 点击"生成摘要"按钮
5. 查看生成的摘要结果
6. 可以使用分屏模式同时查看原文和摘要

## 开发环境

- Flutter 3.x
- Dart 3.x
- 支持Android、iOS、Web和桌面平台
