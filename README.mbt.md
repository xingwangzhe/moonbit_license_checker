# xingwangzhe/license_checker

## 项目简介
`license_checker` 是一个基于 MoonBit 的工具，用于检测并生成项目中所有包的许可证报告。

## Project Introduction
`license_checker` is a MoonBit-based tool to detect and generate license reports for all packages in a project.

## 功能
- 自动检测项目中的 `moon.mod.json` 文件并提取许可证信息。
- 支持 `json` 和 `txt` 两种报告格式，并可输出到文件或打印到标准输出（stdout）。

## Features
- Automatically detects `moon.mod.json` files and extracts license information.
- Supports `json` and `txt` report formats; outputs to file or stdout.

## 使用方法
1) 构建项目：
```bash
moon build
```

2) 运行工具：

- 开发 / 即时运行（推荐在开发时使用）：
```bash
moon run ./cmd/license-checker -- --format json --output licenses.json [输入路径或 packages.json]
```

- 构建并运行本地二进制（发布 / 离线使用）：
```bash
moon build --target native
./target/native/release/build/cmd/license-checker/license-checker.exe --format json --output licenses.json [输入路径或 packages.json]
```

说明：
- 参数顺序不限；第一个非 flag 参数被视为输入路径（可为 packages JSON 文件或目录）。
- 若未提供输入，则优先扫描项目根目录下的 `.mooncakes`，否则扫描当前目录 `.`。
- 仅支持 `json` 或 `txt`，传入其它值会打印错误并退出。

Usage
1) Build the project:
```bash
moon build
```

2) Run the tool:

- Development / quick run (recommended for development):
```bash
moon run ./cmd/license-checker -- --format json --output licenses.json [input path or packages.json]
```

- Build and run native binary (for release / offline):
```bash
moon build --target native
./target/native/release/build/cmd/license-checker/license-checker.exe --format json --output licenses.json [input path or packages.json]
```

Notes
- The first non-flag argument is treated as the input path (either a packages JSON or a directory).
- If no input is provided, the tool prefers scanning `.mooncakes` in the project root; otherwise it scans `.`.
- The JSON report includes a `summary` field: `{ total, unknown_license }` for quick stats.
- When `moon.mod.json` is missing or license cannot be parsed, the `moonmod` or `license` fields become `null` in JSON; TXT output uses `UNKNOWN` or `-` as placeholders.

## 许可证
该项目基于 MIT 许可证发布。

## License
This project is licensed under the MIT License.