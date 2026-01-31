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
/// # 返回值 / Returns
/// 无返回值 / No return value
fn main {
  let args = @env.args()
  let mut input_opt : String? = None
  let mut fmt : String = "json"
  let mut outpath : String? = None

  // Parse arguments robustly: flags may appear anywhere. The first non-flag
  // argument is treated as input path. Unknown extra args are considered an error.
  loop 1 {
    i => {
      if i >= args.length() {
        break
      }
      let a = args[i]
      if a == "--format" && i + 1 < args.length() {
        let val = args[i + 1]
        if val != "json" && val != "txt" {
          println(
            "Error: unsupported format '" + val + "'. Supported: json, txt",
          )
          println(
            "Usage: license-checker [input] --format [json|txt] --output [path]",
          )
          panic()
        }
        fmt = val
        continue i + 2
      } else if a == "--output" && i + 1 < args.length() {
        outpath = Some(args[i + 1])
        continue i + 2
        // treat first non-flag arg as input path
      } else if input_opt is None {
        input_opt = Some(a)
        continue i + 1
      } else {
        println("Error: unknown argument: " + a)
        println(
          "Usage: license-checker [input] --format [json|txt] --output [path]",
        )
        panic()
      }
    }
  }
  let report = match input_opt {
    Some(p) =>
      if @fs.path_exists(p) {
        // try treat as packages JSON
        let text = @fs.read_file_to_string(p) catch { (_ : @fs.IOError) => "" }
        let parsed = @json.parse(text) catch { (_ : @json.ParseError) => null }
        if parsed is { "packages": Array(_), .. } {
          build_report(p)
        } else {
          // not packages JSON, treat as directory to scan
          build_report_from_moonmods(p)
        }
      } else {
        // treat as directory even if not exists (will result empty report)
        build_report_from_moonmods(p)
      }
    None =>
      if @fs.path_exists(".mooncakes") {
        build_report_from_moonmods(".mooncakes")
      } else {
        build_report_from_moonmods(".")
      }
  }
  output(report, fmt, outpath)
}
