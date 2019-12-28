target_link_libraries(test-aegisub
    PRIVATE
    CONAN_PKG::libiconv
    CONAN_PKG::boost
    CONAN_PKG::icu
    CONAN_PKG::GTest
    )
