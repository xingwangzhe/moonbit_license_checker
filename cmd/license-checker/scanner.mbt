///|
/// |
/// 检测指定路径中的 `moon.mod.json` 文件 / Detect the `moon.mod.json` file in the specified path
///
/// # 参数 / Parameters
/// - `start_path`：起始路径。
///   - `start_path`: The starting path.
///
/// # 返回值 / Returns
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
/// |
/// 从 `moon.mod.json` 文件中读取许可证信息 / Read license information from the `moon.mod.json` file
///
/// # 参数 / Parameters
/// - `path`：`moon.mod.json` 文件的路径。
///   - `path`: Path to the `moon.mod.json` file.
///
/// # 返回值 / Returns
/// - 如果找到许可证信息，返回许可证字符串；否则返回 `None`。
///   - Returns the license string if found; otherwise, returns `None`.
pub fn read_license_from_moonmod(path : String) -> String? {
  try {
    let content = @fs.read_file_to_string(path)
    let js = @json.parse(content) catch {
      (_ : @json.ParseError) => return None
    }

    // 1) license as string: { "license": "MIT" }
    if js is { "license": String(lic), .. } {
      let s = lic.trim().to_string()
      if s == "" {
        None
      } else {
        Some(s)
      }

      // 2) license as object: { "license": { "type": "Apache-2.0" } }
    } else if js is { "license": { "type": String(t), .. }, .. } {
      let s = t.trim().to_string()
      if s == "" {
        None
      } else {
        Some(s)
      }

      // 3) license as array: { "license": [ ... ] }
    } else if js is { "license": Array(arr), .. } {
      for item in arr {
        if item is String(s) {
          let s2 = s.trim().to_string()
          if s2 != "" {
            return Some(s2)
          }
        } else if item is { "type": String(t2), .. } {
          let s2 = t2.trim().to_string()
          if s2 != "" {
            return Some(s2)
          }
        }
      }
      None

      // 4) legacy 'licenses' array: { "licenses": [ {"type":"MIT"} ] }
    } else if js is { "licenses": Array(arr2), .. } {
      for item in arr2 {
        if item is { "type": String(t3), .. } {
          let s3 = t3.trim().to_string()
          if s3 != "" {
            return Some(s3)
          }
        }
      }
      None
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
  let mut unknown_count = 0
  for pkg in pkgs {
    if pkg
      is {
        "root": String(root_pkg),
        "rel": String(rel_pkg),
        "artifact": String(artifact),
        ..
      } {
      let moonmod = detect_moonmod(artifact)
      let mut license_opt : String? = None
      if moonmod is Some(p) {
        license_opt = read_license_from_moonmod(p)
      }
      if license_opt is None {
        unknown_count = unknown_count + 1
      }
      let entry : Json = {
        "root": root_pkg,
        "rel": rel_pkg,
        "artifact": artifact,
        "moonmod": if moonmod is Some(p) {
          p
        } else {
          null
        },
        "license": match license_opt {
          Some(l) => l
          None => null
        },
      }
      results.push(entry)
    } else {
      // skip
    }
  }
  {
    "packages": results,
    "summary": { "total": results.length(), "unknown_license": unknown_count },
  }
}

///|
/// 递归收集指定目录下的 `moon.mod.json` 文件
/// Recursively collect `moon.mod.json` files under a directory.
pub fn collect_moonmod_files(start_dir : String) -> Array[String] {
  let res = Array::new()
  if !@fs.path_exists(start_dir) {
    return res
  }
  let stack = Array::new()
  stack.push(start_dir)
  while stack.length() > 0 {
    // pop last
    let idx = stack.length() - 1
    let dir = stack[idx]
    let _ = stack.remove(idx)
    let entries = @fs.read_dir(dir) catch { (_ : @fs.IOError) => Array::new() }
    for e in entries {
      let child = @path.Path::join(@path.Path(dir), @path.Path(e)).0
      let mpath = @path.Path::join(
          @path.Path(child),
          @path.Path("moon.mod.json"),
        ).0
      if @fs.path_exists(mpath) {
        res.push(mpath)
      }
      let isdir = @fs.is_dir(child) catch { (_ : @fs.IOError) => false }
      if isdir {
        stack.push(child)
      }
    }
  }
  res
}

///|
/// 通过扫描根目录下的 `moon.mod.json` 文件来构建许可证报告。
/// 这用于检查 `.mooncakes` 或项目树中的本地依赖。
/// Build a license report by scanning `moon.mod.json` files under a root directory.
/// This is used to inspect local dependencies in `.mooncakes` or the project tree.
pub fn build_report_from_moonmods(root_dir : String) -> Json {
  let files = collect_moonmod_files(root_dir)
  let results = Array::new()
  let mut unknown_count = 0
  for f in files {
    let dir_str = @path.Path::dirname(@path.Path(f)).0
    // read package name if present
    let name = {
      let txt = @fs.read_file_to_string(f) catch { (_ : @fs.IOError) => "" }
      let js = @json.parse(txt) catch { (_ : @json.ParseError) => null }
      if js is { "name": String(n), .. } {
        n
      } else {
        ""
      }
    }
    let root_name = if name != "" { name } else { dir_str }
    let license_opt = read_license_from_moonmod(f)
    if license_opt is None {
      unknown_count = unknown_count + 1
    }
    let entry : Json = {
      "root": root_name,
      "rel": "",
      "artifact": dir_str,
      "moonmod": f,
      "license": match license_opt {
        Some(l) => l
        None => null
      },
    }
    results.push(entry)
  }
  {
    "packages": results,
    "summary": { "total": results.length(), "unknown_license": unknown_count },
  }
}
