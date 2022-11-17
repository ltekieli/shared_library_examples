#!/bin/bash

set -x

SCRIPT_DIR=$(readlink -f "$(dirname "$0")")

CC=/usr/bin/g++

rm -rf "${SCRIPT_DIR}/build"
mkdir -p "${SCRIPT_DIR}/build/"{f1,f2}

#
# -fPIC tells the compiler to generate position independent code
#
"${CC}" -fPIC -c "${SCRIPT_DIR}/f2/f2.cpp" -o "${SCRIPT_DIR}/build/f2/f2.o"

#
# f1.cpp depends on f2/f2.h so the top directory is added to searched include paths
#
"${CC}" -fPIC -I "${SCRIPT_DIR}" -c "${SCRIPT_DIR}/f1/f1.cpp" -o "${SCRIPT_DIR}/build/f1/f1.o"

#
# -soname sets the SONAME inside the ELF file, that's the name that dynamic linker searches for
#
"${CC}" -fPIC -shared -Wl,-soname,libf2.so.0 \
    "${SCRIPT_DIR}/build/f2/f2.o" \
    -o "${SCRIPT_DIR}/build/f2/libf2.so.0.1"

#
# libf2.so.0 is the SONAME symlink for libf2.so.0.1
#
ln -s libf2.so.0.1 "${SCRIPT_DIR}/build/f2/libf2.so.0"

#
# libf2.so is the linker name for libf2.so.0.1, which is used by linker when passed -lf2
#
ln -s libf2.so.0.1 "${SCRIPT_DIR}/build/f2/libf2.so"

#
# -rpath tells where to find the dependencies of f1
# Specifying libf2.so.0.1 can be replaced with -L/path/to/dir/with/libf2.so -lf2
#
"${CC}" -fPIC -shared -Wl,-soname,libf1.so.0 -Wl,-rpath,\$ORIGIN/../f2 \
    "${SCRIPT_DIR}/build/f1/f1.o" "${SCRIPT_DIR}/build/f2/libf2.so.0.1" \
    -o "${SCRIPT_DIR}/build/f1/libf1.so.0.1"

ln -s libf1.so.0.1 "${SCRIPT_DIR}/build/f1/libf1.so.0"
ln -s libf1.so.0.1 "${SCRIPT_DIR}/build/f1/libf1.so"

#
# -rpath-link will be used before -rpath coming from libf1.so
#
"${CC}" -Wl,-rpath,\$ORIGIN/f1 -Wl,-rpath-link,\$ORIGIN/../f2 \
    "${SCRIPT_DIR}/main.cpp" "${SCRIPT_DIR}/build/f1/libf1.so.0.1" \
    -o "${SCRIPT_DIR}/build/main"
