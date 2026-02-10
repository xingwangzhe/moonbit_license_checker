---
moonbit:
  import: []
---

# xingwangzhe/license_checker

## 项目简介

`license_checker` 是一个基于 MoonBit 的工具，用于自动检测并生成项目中所有包的许可证（License）报告。支持多种输出格式和灵活的配置选项。

## Project Introduction

`license_checker` is a MoonBit-based tool to automatically detect and generate license reports for all packages in a project. It supports multiple output formats and flexible configuration options.

## 功能 / Features

- **自动检测** / **Auto Detection**: 自动检测项目中的 `moon.mod.json` 文件并提取许可证信息
- **多格式输出** / **Multiple Output Formats**: 支持 JSON 和 TXT 两种报告格式，可输出到文件或标准输出
- **原生二进制** / **Native Binaries**: 提供多平台预编译二进制包（Linux、macOS、Windows）
- **灵活部署** / **Flexible Deployment**: 支持作为依赖库或全局 CLI 工具安装

## 安装 / Installation

### 方式 1: 全局 CLI 工具 / Method 1: Global CLI Tool

```bash
moon install xingwangzhe/license_checker/cmd/license-checker
```

安装后，确保 `~/.moon/bin` 在 `PATH` 中，然后运行：

```bash
license-checker.exe --format json --output licenses.json [input-path]
```

### 方式 2: 作为项目依赖 / Method 2: As Project Dependency

```bash
moon add xingwangzhe/license_checker
```

然后在代码中导入：

```moonbit
import "xingwangzhe/license_checker"
```

### 方式 3: 预编译二进制 / Method 3: Prebuilt Binaries

从 [GitHub Releases](https://github.com/xingwangzhe/moonbit_license_checker/releases) 下载对应平台的二进制文件。

## 使用方法 / Usage

### 开发模式 / Development Mode

从源代码构建并运行：

```bash
moon build
moon run ./cmd/license-checker -- --format json --output licenses.json [input-path | packages.json]
```

### 原生二进制模式 / Native Binary Mode

构建原生发布版本：

```bash
moon build --target native --release
./target/native/release/build/cmd/license-checker/license-checker.exe \
  --format json --output licenses.json [input-path | packages.json]
```

### 命令行参数 / Command Line Arguments

- `--format <format>`: 输出格式，支持 `json` 或 `txt`（默认: `json`）
- `--output <path>`: 输出文件路径（可选；不指定则输出到标准输出）
- `<input>`: 输入路径或 packages.json 文件（可选；默认扫描 `.mooncakes` 或当前目录 `.`）

### 示例 / Examples

```bash
# 生成 JSON 报告到文件
license-checker.exe --format json --output licenses.json

# 生成 TXT 报告到标准输出
license-checker.exe --format txt

# 扫描指定目录
license-checker.exe --format json .mooncakes

# 从 packages.json 读取包信息
license-checker.exe --format json target/wasm-gc/release/check/all_pkgs.json
```

## 输出格式 / Output Format

### JSON 格式 / JSON Format

```json
{
  "packages": [
    {
      "root": "package-name",
      "rel": "path/to/package",
      "artifact": "/abs/path",
      "moonmod": "path/to/moon.mod.json",
      "license": "MIT"
    }
  ],
  "summary": {
    "total": 10,
    "unknown_license": 2
  }
}
```

### TXT 格式 / TXT Format

```
rootrellicensemoonmod
pkg-aMITpath/to/moon.mod.json
pkg-bUNKNOWN-
```

## 版本历史 / Version History

| 版本 / Version | 日期 / Date | 说明 / Description |
|---|---|---|
| 0.2.1 | 2026-02-10 | 更新到 MoonBit 0.8.0、迁移到新包配置格式 moon.pkg、支持原生二进制分发 |
| 0.1.3 | 2026-01-XX | 初始发布版本 |
| 0.1.0 | 2025-XX-XX | 原始实验版本 |

## 更新日志 / Changelog

### v0.2.1

- ✨ 更新为 MoonBit 0.8.0 兼容版本
- 🔧 迁移 `moon.pkg.json` 到新的 `moon.pkg` DSL 配置格式
- 📦 支持原生二进制构建与分发（`moon build --target native --release`）
- 📝 完善文档与使用说明

### v0.1.3

- 🐛 修复许可证解析的边界情况
- 📚 改进错误提示信息

### v0.1.0

- ✅ 初始功能完成：自动检测 `moon.mod.json`、JSON/TXT 输出、灵活参数解析

## 许可证 / License

本项目基于 MIT 许可证发布。

Licensed under MIT License.

## 贡献 / Contributing

欢迎提交 Issue 和 Pull Request！

Contributions are welcome! Please feel free to submit issues and pull requests.

---

**维护者** / **Maintainer**: xingwangzhe  
**仓库** / **Repository**: https://github.com/xingwangzhe/moonbit_license_checker  
**依赖** / **Dependencies**: moonbitlang/x >= 0.4.38
