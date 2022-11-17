# Creating shared libraries in Bazel, CMake and manually

## Building manually
```
./build.sh
```

### Examining results
```
$ tree build/
build/
├── f1
│   ├── f1.o
│   ├── libf1.so -> libf1.so.0.1
│   ├── libf1.so.0 -> libf1.so.0.1
│   └── libf1.so.0.1
├── f2
│   ├── f2.o
│   ├── libf2.so -> libf2.so.0.1
│   ├── libf2.so.0 -> libf2.so.0.1
│   └── libf2.so.0.1
└── main
```

```
$ readelf -d ./build/main | grep -e NEEDED -e RUNPATH
 0x0000000000000001 (NEEDED)             Shared library: [libf1.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN/f1]
```
```
$ readelf -d ./build/f1/libf1.so | grep -e NEEDED -e RUNPATH -e SONAME
 0x0000000000000001 (NEEDED)             Shared library: [libf2.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000e (SONAME)             Library soname: [libf1.so.0]
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN/../f2]
```
```
$ readelf -d ./build/f2/libf2.so | grep -e NEEDED -e RUNPATH -e SONAME
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000e (SONAME)             Library soname: [libf2.so.0]
```

## Building with Bazel
```
bazel build //...
```

### Examining results
```
$ tree bazel-bin/
bazel-bin/
├── f1
│   ├── libf1_base.a
│   ├── libf1_base.a-2.params
│   ├── libf1_base.so
│   ├── libf1_base.so-2.params
│   ├── libf1.so
│   ├── libf1.so-2.params
│   └── _objs
│       └── f1_base
│           ├── f1.pic.d
│           └── f1.pic.o
├── f2
│   ├── libf2_base.a
│   ├── libf2_base.a-2.params
│   ├── libf2_base.so
│   ├── libf2_base.so-2.params
│   ├── libf2.so
│   ├── libf2.so-2.params
│   └── _objs
│       └── f2_base
│           ├── f2.pic.d
│           └── f2.pic.o
├── main
├── main-2.params
├── main.runfiles
│   ├── __main__
│   │   ├── f1
│   │   │   └── libf1.so -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/f1/libf1.so
│   │   ├── f2
│   │   │   └── libf2.so -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/f2/libf2.so
│   │   ├── main -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/main
│   │   └── _solib_k8
│   │       ├── libf1_Slibf1.so -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/_solib_k8/libf1_Slibf1.so
│   │       └── libf2_Slibf2.so -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/_solib_k8/libf2_Slibf2.so
│   └── MANIFEST
├── main.runfiles_manifest
├── _objs
│   └── main
│       ├── main.pic.d
│       └── main.pic.o
└── _solib_k8
    ├── libf1_Slibf1.so -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/f1/libf1.so
    └── libf2_Slibf2.so -> /home/lukasz/.cache/bazel/_bazel_lukasz/32cb9f8448eba7fef30c411907a335d5/execroot/__main__/bazel-out/k8-fastbuild/bin/f2/libf2.so
```

```
$ readelf -d bazel-bin/main | grep -e NEEDED -e RUNPATH
 0x0000000000000001 (NEEDED)             Shared library: [libf2_Slibf2.so]
 0x0000000000000001 (NEEDED)             Shared library: [libf1_Slibf1.so]
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN/_solib_k8/]
```

```
$ readelf -d bazel-bin/f1/libf1.so | grep -e NEEDED -e RUNPATH -e SONAME
 0x0000000000000001 (NEEDED)             Shared library: [libf2_Slibf2.so]
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN/../_solib_k8/]
```

```
$ readelf -d bazel-bin/f2/libf2.so | grep -e NEEDED -e RUNPATH -e SONAME
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
```

## Building with CMake
```
cmake -B build-cmake . -GNinja -DBUILD_SHARED_LIBS=ON
cmake --build build-cmake
```

### Examining results
```
$ tree build-cmake/
build-cmake/
├── build.ninja
├── CMakeCache.txt
├── CMakeFiles
│   ├── 3.22.1
│   │   ├── CMakeCCompiler.cmake
│   │   ├── CMakeCXXCompiler.cmake
│   │   ├── CMakeDetermineCompilerABI_C.bin
│   │   ├── CMakeDetermineCompilerABI_CXX.bin
│   │   ├── CMakeSystem.cmake
│   │   ├── CompilerIdC
│   │   │   ├── a.out
│   │   │   ├── CMakeCCompilerId.c
│   │   │   └── tmp
│   │   └── CompilerIdCXX
│   │       ├── a.out
│   │       ├── CMakeCXXCompilerId.cpp
│   │       └── tmp
│   ├── cmake.check_cache
│   ├── CMakeOutput.log
│   ├── CMakeTmp
│   ├── f1.dir
│   │   └── f1
│   │       └── f1.cpp.o
│   ├── f2.dir
│   │   └── f2
│   │       └── f2.cpp.o
│   ├── main.dir
│   │   └── main.cpp.o
│   ├── rules.ninja
│   └── TargetDirectories.txt
├── cmake_install.cmake
├── libf1.so -> libf1.so.0
├── libf1.so.0 -> libf1.so.0.1
├── libf1.so.0.1
├── libf2.so -> libf2.so.0
├── libf2.so.0 -> libf2.so.0.1
├── libf2.so.0.1
└── main
```

```
$ readelf -d build-cmake/main | grep -e NEEDED -e RUNPATH
 0x0000000000000001 (NEEDED)             Shared library: [libf1.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [/home/lukasz/workspace/shared_library_examples/build-cmake]
```

```
$ readelf -d build-cmake/libf1.so | grep -e NEEDED -e RUNPATH -e SONAME
 0x0000000000000001 (NEEDED)             Shared library: [libf2.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000e (SONAME)             Library soname: [libf1.so.0]
 0x000000000000001d (RUNPATH)            Library runpath: [/home/lukasz/workspace/shared_library_examples/build-cmake]
```

```
$ readelf -d build-cmake/libf2.so | grep -e NEEDED -e RUNPATH -e SONAME
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000e (SONAME)             Library soname: [libf2.so.0]
```