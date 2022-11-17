cc_library(
    name = "f1_base",
    srcs = ["f1/f1.cpp"],
    hdrs = ["f1/f1.h"],

    # cc_shared_library does not respect implementation deps at all
    # Bazel version: 5.3.2
    implementation_deps = [":f2_base"],
)

cc_shared_library(
    name = "f1",
    dynamic_deps = [":f2"],
    roots = [":f1_base"],
)

cc_library(
    name = "f2_base",
    srcs = ["f2/f2.cpp"],
    hdrs = ["f2/f2.h"],
)

cc_shared_library(
    name = "f2",
    roots = [":f2_base"],
)

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    dynamic_deps = [":f1"],
    deps = ["f1_base"],
)
