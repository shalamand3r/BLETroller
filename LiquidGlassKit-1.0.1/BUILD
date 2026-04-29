load("@build_bazel_rules_apple//apple:resources.bzl", "apple_metal_library", "apple_resource_bundle")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "LiquidGlassKit",
    module_name = "LiquidGlassKit",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    data = [
        ":LiquidGlassKitShaderResources",
    ],
    deps = [],
    visibility = [
        "//visibility:public",
    ],
)

apple_metal_library(
    name = "LiquidGlassKitShaders",
    srcs = glob([
        "Sources/**/*.metal",
    ]),
    out = "default.metallib",
)

apple_resource_bundle(
    name = "LiquidGlassKitShaderResources",
    bundle_id = "com.DnV1eX.LiquidGlassKitShaders",
    infoplists = ["Info.plist"],
    resources = [":LiquidGlassKitShaders"],
)
