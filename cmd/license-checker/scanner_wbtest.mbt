///|
/// 测试: read_license_string — 从 `moon.mod.json` 读取字符串形式的 license
/// Test: read_license_string — read license string from `moon.mod.json`
test "read_license_string" {
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file(
    "target/testdata/license_str.json", "{\"license\":\"MIT\"}",
  )
  inspect(
    read_license_from_moonmod("target/testdata/license_str.json") == Some("MIT"),
    content="true",
  )
}

///|
/// 测试: read_license_object — 从 `moon.mod.json` 读取对象形式的 license
/// Test: read_license_object — read license object from `moon.mod.json`
test "read_license_object" {
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file(
    "target/testdata/license_obj.json", "{\"license\": {\"type\": \"Apache-2.0\"}}",
  )
  inspect(
    read_license_from_moonmod("target/testdata/license_obj.json") ==
    Some("Apache-2.0"),
    content="true",
  )
}

///|
/// 测试: read_license_array — 从 `moon.mod.json` 中的数组读取第一个有效 license
/// Test: read_license_array — read first valid license from license array in `moon.mod.json`
test "read_license_array" {
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file(
    "target/testdata/license_arr.json", "{\"license\": [\"BSD-3-Clause\"]}",
  )
  inspect(
    read_license_from_moonmod("target/testdata/license_arr.json") ==
    Some("BSD-3-Clause"),
    content="true",
  )
}

///|
/// 测试: read_licenses_key — 处理旧版 `licenses` 键的情况
/// Test: read_licenses_key — handle legacy `licenses` key
test "read_licenses_key" {
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file(
    "target/testdata/license_licenses.json", "{\"licenses\": [{\"type\": \"GPL-3.0\"}]}",
  )
  inspect(
    read_license_from_moonmod("target/testdata/license_licenses.json") ==
    Some("GPL-3.0"),
    content="true",
  )
}

///|
/// 测试: read_license_missing — 当未提供 license 时返回 None
/// Test: read_license_missing — return None when license is missing
test "read_license_missing" {
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file("target/testdata/license_none.json", "{}")
  inspect(
    read_license_from_moonmod("target/testdata/license_none.json") == None,
    content="true",
  )
}

///|
/// 测试: build_report_integration — 从 packages JSON 构建报告并验证 license 字段
/// Test: build_report_integration — build report from packages JSON and verify license field
test "build_report_integration" {
  // prepare package + moon.mod.json
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  if !@fs.path_exists("target/testdata/foo") {
    @fs.create_dir("target/testdata/foo") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  if !@fs.path_exists("target/testdata/foo/bar") {
    @fs.create_dir("target/testdata/foo/bar") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file("target/testdata/foo/bar/bundle.mi", "")
  @fs.write_string_to_file(
    "target/testdata/foo/moon.mod.json", "{\"license\": \"MIT\"}",
  )
  @fs.write_string_to_file(
    "target/testdata/all_pkgs_small.json", "{ \"packages\": [ { \"root\": \"r\", \"rel\": \"rel\", \"artifact\": \"target/testdata/foo/bar/bundle.mi\" } ] }",
  )
  let report = build_report("target/testdata/all_pkgs_small.json")
  guard report is { "packages": Array(pkgs), .. }
  for p in pkgs {
    guard p is { "license": String(lic), .. }
    inspect(lic, content="MIT")
  }
}

///|
/// 测试: build_report_from_moonmods_integration — 模拟 `.mooncakes` 结构并扫描 moon.mod.json
/// Test: build_report_from_moonmods_integration — simulate `.mooncakes` structure and scan moon.mod.json
test "build_report_from_moonmods_integration" {
  if !@fs.path_exists("target/testdata") {
    @fs.create_dir("target/testdata") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  // create a simulated .mooncakes structure
  if !@fs.path_exists("target/testdata/.mooncakes") {
    @fs.create_dir("target/testdata/.mooncakes") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  if !@fs.path_exists("target/testdata/.mooncakes/foo") {
    @fs.create_dir("target/testdata/.mooncakes/foo") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  if !@fs.path_exists("target/testdata/.mooncakes/foo/bar") {
    @fs.create_dir("target/testdata/.mooncakes/foo/bar") catch {
      (_ : @fs.IOError) => panic()
    }
  }
  @fs.write_string_to_file(
    "target/testdata/.mooncakes/foo/bar/moon.mod.json", "{\"name\": \"foo/bar\", \"license\": \"BSD-3-Clause\"}",
  )
  let report = build_report_from_moonmods("target/testdata/.mooncakes")
  guard report is { "packages": Array(pkgs), .. }
  let mut found = false
  for p in pkgs {
    if p is { "root": String(r), "license": String(l), .. } {
      if r == "foo/bar" && l == "BSD-3-Clause" {
        found = true
      }
    }
  }
  inspect(found, content="true")
}
