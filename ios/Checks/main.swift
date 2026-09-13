import Foundation

// Quick sanity checks for Formatter and Config

// Check 1: Formatter returns input unchanged when formatOnSave is false
UserDefaults.standard.removeObject(forKey: "formatOnSave")
let noFormat = Formatter.format("{\"a\": 1}", type: .json)
assert(noFormat == "{\"a\": 1}", "Formatter should not modify when disabled")
print("✓ Formatter correctly returns input when formatOnSave is false")

// Check 2: When formatters aren't installed, formatter should return input unchanged (fallback)
UserDefaults.standard.set(true, forKey: "formatOnSave")
let fallback = Formatter.format("{\"a\": 1}", type: .json)
assert(fallback == "{\"a\": 1}", "Formatter should fallback to input when tool missing")
print("✓ Formatter correctly falls back when tool is not found")

// Check 3: Config.apply respects formatOnSave
let config = """
{"formatOnSave": false, "fontSize": 20}
"""
Config.apply(config)
assert(UserDefaults.standard.bool(forKey: "formatOnSave") == false, "Config should set formatOnSave to false")
print("✓ Config correctly applies formatOnSave setting")

// Check 4: Stats still works
let stats = Stats("hello\nworld\n")
assert(stats.summary.contains("2"), "Stats should count lines")
print("✓ Stats still works correctly")

print("\n✅ All checks passed")
