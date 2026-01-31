///|
/// 检测指定路径中的 `moon.mod.json` 文件
/// Detect the `moon.mod.json` file in the specified path
///
/// # 参数
/// - `start_path`：起始路径。
///   - `start_path`: The starting path.
///
/// # 返回值
/// - 如果找到 `moon.mod.json` 文件，返回其路径；否则返回 `None`。
///   - Returns the path to the `moon.mod.json` file if found; otherwise, returns `None`.
pub fn detect_moonmod(start_path : String) -> String? {
  let start_dir = @path.Path::dirname(@path.Path(start_path))
  loop start_dir {
    d => {
      let candidate_path = @path.Path::join(d, @path.Path("moon.mod.json")).0
      if @fs.path_exists(candidate_path) {
        return Some(candidate_path)
      }
      let parent = @path.Path::dirname(d)
      if parent == d {
        break
      }
      continue parent
    }
  }
  None
}

///|
/// 从 `moon.mod.json` 文件中读取许可证信息
/// Read license information from the `moon.mod.json` file
///
/// # 参数
/// - `path`：`moon.mod.json` 文件的路径。
///   - `path`: Path to the `moon.mod.json` file.
///
/// # 返回值
/// - 如果找到许可证信息，返回许可证字符串；否则返回 `None`。
///   - Returns the license string if found; otherwise, returns `None`.
pub fn read_license_from_moonmod(path : String) -> String? {
  try {
    let content = @fs.read_file_to_string(path)
    let js = @json.parse(content) catch {
      (_ : @json.ParseError) => return None
    }
    if js is { "license": String(lic), .. } {
      Some(lic)
    } else {
      None
    }
  } catch {
    (_ : @fs.IOError) => None
  }
}

///|
/// 构建包含所有包的许可证报告
/// Build a license report for all packages
///
/// # 参数
/// - `input_path`：包含包信息的输入文件路径。
///   - `input_path`: Path to the input file containing package information.
///
/// # 返回值
/// - 返回包含所有包许可证信息的 JSON 对象。
///   - Returns a JSON object containing license information for all packages.
pub fn build_report(input_path : String) -> Json {
  let text = @fs.read_file_to_string(input_path) catch {
    (_ : @fs.IOError) => panic()
  }
  let root = @json.parse(text) catch { (_ : @json.ParseError) => panic() }
  guard root is { "packages": Array(pkgs), .. }
  let results = Array::new()
  for pkg in pkgs {
    if pkg
      is {
        "root": String(root_pkg),
        "rel": String(rel_pkg),
        "artifact": String(artifact),
        ..
      } {
      let moonmod = detect_moonmod(artifact)
      let license = if moonmod is Some(p) {
        match read_license_from_moonmod(p) {
          Some(l) => l
          None => "UNKNOWN"
        }
      } else {
        "UNKNOWN"
      }
      let moonmod_val : String = if moonmod is Some(p) { p } else { "" }
      let entry : Json = {
        "root": root_pkg,
        "rel": rel_pkg,
        "artifact": artifact,
        "moonmod": moonmod_val,
        "license": license,
      }
      results.push(entry)
    } else {
      // skip
    }
  }
  { "packages": results }
}
