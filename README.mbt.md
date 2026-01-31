# xingwangzhe/license_checker

## 项目简介 / Project Introduction

`license_checker` 是一个基于 MoonBit 的工具，用于检查和生成项目中所有包的许可证报告。

`license_checker` is a MoonBit-based tool for checking and generating license reports for all packages in a project.

## 功能 / Features

- 自动检测项目中的 `moon.mod.json` 文件。
- 提取包的许可证信息。
- 支持 JSON 和 TXT 格式的报告输出。
- 可选输出到文件或直接打印到控制台。

- Automatically detects `moon.mod.json` files in the project.
- Extracts license information for packages.
- Supports report output in JSON and TXT formats.
- Optionally outputs to a file or prints directly to the console.

## 使用方法 / Usage

1. 构建项目：
   ```bash
   moon build
   ```

2. 运行工具：
   ```bash
   moon run license_checker -- [输入文件路径] --format [json|txt] --output [输出文件路径]
   ```
   示例：
   ```bash
   moon run license_checker -- target/wasm-gc/release/check/all_pkgs.json --format json --output licenses.json
   ```

1. Build the project:
   ```bash
   moon build
   ```

2. Run the tool:
   ```bash
   moon run license_checker -- [input file path] --format [json|txt] --output [output file path]
   ```
   Example:
   ```bash
   moon run license_checker -- target/wasm-gc/release/check/all_pkgs.json --format json --output licenses.json
   ```

## 许可证 / License

该项目基于 MIT 许可证发布。

This project is licensed under the MIT License.