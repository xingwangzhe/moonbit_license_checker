///|
/// 主函数：协调扫描器和格式化器的执行
/// Main function: Orchestrates the scanner and formatter execution
///
/// # 参数
/// - 无直接参数，但从命令行接收以下参数：
///   - `--format <格式>`：指定输出格式（默认为 `json`）。
///   - `--output <路径>`：指定输出文件路径（可选）。
///   - `<输入文件路径>`：指定输入文件路径（默认为 `target/wasm-gc/release/check/all_pkgs.json`）。
///
/// # 功能
/// 1. 解析命令行参数，获取输入文件路径、输出格式和输出路径。
/// 2. 调用 `build_report` 函数生成报告。
/// 3. 调用 `output` 函数根据指定格式输出报告。
///
/// # Returns
/// 无返回值
fn main {
  let args = @env.args()
  let mut input : String = if args.length() > 1 {
    args[1]
  } else {
    "target/wasm-gc/release/check/all_pkgs.json"
  }
  let mut fmt : String = "json"
  let mut outpath : String? = None

  // parse flags starting from position 2
  loop 2 {
    i => {
      if i >= args.length() {
        break
      }
      if args[i] == "--format" && i + 1 < args.length() {
        fmt = args[i + 1]
        continue i + 2
      } else if args[i] == "--output" && i + 1 < args.length() {
        outpath = Some(args[i + 1])
        continue i + 2
      } else {
        // treat first extra arg as input if not already provided
        if i == 2 && input == "target/wasm-gc/release/check/all_pkgs.json" {
          input = args[i]
        }
        continue i + 1
      }
    }
  }
  let report = build_report(input)
  output(report, fmt, outpath)
}
