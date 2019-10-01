# Aegisub-Conan-CMake
CMake including files to resolve dependencies of Aegisub using Conan.

## Usage
To use this file, simply set CMake varible `DEPENDENCIES_CMAKE_FILE` to the path of the `dependencies_conan.cmake` in this repository.

```shell
cmake .. -DDEPENDENCIES_CMAKE_FILE="D:/repos/Aegisub-Conan-CMake/dependencies_conan.cmake"
```

Replace `D:/repos/Aegisub-Conan-CMake/dependencies_conan.cmake` to the path on your computer.

Remember to clear CMake cache before running.