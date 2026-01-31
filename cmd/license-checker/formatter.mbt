///|
/// Formatter: format report as JSON or TXT and handle output
/// 格式化为 JSON 格式的报告
/// Format the report as JSON
///
/// # 参数
/// - `report`：包含报告数据的 JSON 对象。
///   - `report`: JSON object containing the report data.
///
/// # 返回值
/// - 返回格式化为 JSON 字符串的报告。
///   - Returns the report formatted as a JSON string.
pub fn format_json(report : Json) -> String {
  report.stringify(indent=2)
}

///|
/// 格式化为 TXT 格式的报告
/// Format the report as TXT
///
/// # 参数
/// - `report`：包含报告数据的 JSON 对象。
///   - `report`: JSON object containing the report data.
///
/// # 返回值
/// - 返回格式化为制表符分隔的 TXT 字符串的报告。
///   - Returns the report formatted as a tab-separated TXT string.
pub fn format_txt(report : Json) -> String {
  guard report is { "packages": Array(pkgs), .. }
  let lines = ["root\trel\tlicense\tmoonmod"]
  for p in pkgs {
    guard p
      is {
        "root": String(r),
        "rel": String(rel),
        "license": String(lic),
        "moonmod": moonv,
        ..
      }
    let moonpath = match moonv {
      String(s) => s
      _ => "-"
    }
    lines.push(r + "\t" + rel + "\t" + lic + "\t" + moonpath)
  }
  lines.join("\n")
}

///|
/// 输出报告到指定位置
/// Output the report to the specified location
///
/// # 参数
/// - `report`：包含报告数据的 JSON 对象。
///   - `report`: JSON object containing the report data.
/// - `fmt`：输出格式，支持 `json` 或 `txt`。
///   - `fmt`: Output format, supports `json` or `txt`.
/// - `outpath`：可选的输出文件路径。如果为 `None`，则输出到标准输出。
///   - `outpath`: Optional output file path. Outputs to standard output if `None`.
///
/// # 返回值
/// - 无返回值。
///   - No return value.
pub fn output(report : Json, fmt : String, outpath : String?) -> Unit {
  if fmt == "json" {
    let out = format_json(report)
    match outpath {
      Some(path) =>
        @fs.write_string_to_file(path, out) catch {
          (_ : @fs.IOError) => panic()
        }
      None => println(out)
    }
  } else {
    let txt = format_txt(report)
    match outpath {
      Some(path) =>
        @fs.write_string_to_file(path, txt) catch {
          (_ : @fs.IOError) => panic()
        }
      None => println(txt)
    }
  }
}
