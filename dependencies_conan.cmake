message(STATUS "Aegisub Build: Changing unit test dependency management to Conan...")
set(DEPENDENCIES_CMAKE_FILE_TEST ${CMAKE_CURRENT_LIST_DIR}/dependencies_tests_conan.cmake)

# this must be before the conan
if(APPLE) # sooooooooo APPLE
    find_package(Iconv REQUIRED)
    target_link_libraries(libaegisub ${Iconv_LIBRARIES}) # LINK ONLY
endif()

message(STATUS "Aegisub Build: Loading dependencies using Conan...")
include(${CMAKE_CURRENT_LIST_DIR}/conan.cmake)

conan_check(REQUIRED)

conan_add_remote(NAME bincrafters URL "https://api.bintray.com/conan/bincrafters/public-conan")
conan_add_remote(NAME charliejiang URL "https://api.bintray.com/conan/charliejiang/conan")
conan_add_remote(NAME h4m5ter URL "https://api.bintray.com/conan/h4m5ter/conan")

set(AEGISUB_CONAN_DEPS
    "libpng/1.6.37"
    "zlib/1.2.11"
    "libass/0.14.0@charliejiang/stable"
    "boost/1.71.0@charliejiang/stable"
    "icu/64.2@bincrafters/stable"
    "wxwidgets/3.1.3@bincrafters/stable" # TODO : Wait for bincrafter guys to merge https://github.com/bincrafters/conan-wxwidgets/pull/16
    "luajit/2.0.5@charliejiang/stable"
    "luabins/0.3@h4m5ter/stable"
    "libiconv/1.15"
    "expat/2.2.8"
    "freetype/2.10.1"
    "nlohmann_json/3.7.3"
    )
set(LIBAEGISUB_CONAN_IMPORT_TARGETS
    CONAN_PKG::libiconv
    CONAN_PKG::boost
    CONAN_PKG::icu
    CONAN_PKG::wxwidgets
    CONAN_PKG::luajit
    CONAN_PKG::nlohmann_json)
set(AEGISUB_CONAN_IMPORT_TARGETS
    CONAN_PKG::libiconv
    CONAN_PKG::boost
    CONAN_PKG::icu
    CONAN_PKG::libass
    CONAN_PKG::wxwidgets
    CONAN_PKG::luajit
    CONAN_PKG::luabins
    CONAN_PKG::nlohmann_json)

set(ICU_OPTIONS icu:data_packaging=static)

set(BOOST_OPTIONS boost:use_icu=True)
set(BOOST_LIBS math wave container contract exception graph iostreams locale log
            program_options random regex mpi serialization
            coroutine fiber context timer thread chrono date_time
            atomic filesystem system graph_parallel python
            stacktrace test type_erasure)
set(BOOST_EXCLUDE_LIBS ${BOOST_LIBS})
set(BOOST_USING_LIBS chrono filesystem locale regex system thread)
list(REMOVE_ITEM BOOST_EXCLUDE_LIBS ${BOOST_USING_LIBS})
foreach(BOOST_EXCLUDE_LIB IN LISTS BOOST_EXCLUDE_LIBS)
    list(APPEND BOOST_OPTIONS "boost:without_${BOOST_EXCLUDE_LIB}=True")
endforeach()

set(wxWidgets_OPTIONS
    wxwidgets:stc=True
    wxwidgets:richtext=True
    wxwidgets:sockets=True # this sucks
    wxwidgets:xml=True
    wxwidgets:html=True
    wxwidgets:xrc=True
    wxwidgets:aui=True

    wxwidgets:jpeg=off
    wxwidgets:tiff=off
    wxwidgets:secretstore=False
    wxwidgets:mediactrl=False
    wxwidgets:propgrid=False
    wxwidgets:debugreport=False
    wxwidgets:ribbon=False
    wxwidgets:webview=False
    wxwidgets:custom_disables="wxUSE_SOUND"
    )
if(LINUX)
    list(APPEND wxWidgets_OPTIONS wxwidgets:cairo=False)
endif()

set(AEGISUB_CONAN_OPTIONS
    ${ICU_OPTIONS} ${BOOST_OPTIONS} ${wxWidgets_OPTIONS}
    luajit:lua52_compat=True)

if(WITH_FONTCONFIG)
    list(APPEND AEGISUB_CONAN_DEPS fontconfig/2.13.91@conan/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::fontconfig)
endif()

if(WITH_FFMS2)
    list(APPEND AEGISUB_CONAN_DEPS ffms2-core/2.31@charliejiang/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::ffms2-core)

    set(FFMS2_OPTIONS
        "ffmpeg:extra_config_flags=--enable-gpl --enable-runtime-cpudetect --enable-small"
        ffmpeg:zlib=True
        ffmpeg:freetype=True
        ffmpeg:postproc=False
        ffmpeg:bzlib=False
        ffmpeg:lzma=False
        ffmpeg:openjpeg=False
        ffmpeg:openh264=False
        ffmpeg:opus=False
        ffmpeg:vorbis=False
        ffmpeg:zmq=False
        ffmpeg:sdl2=False
        ffmpeg:x264=False
        ffmpeg:x265=False
        ffmpeg:vpx=False
        ffmpeg:mp3lame=False
        ffmpeg:fdk_aac=False
        ffmpeg:webp=False
        ffmpeg:mp3lame=False
        ffmpeg:openssl=False)
    if(WIN32)
        list(APPEND FFMS2_OPTIONS ffmpeg:qsv=False)
    elseif(APPLE)
        list(APPEND FFMS2_OPTIONS
            ffmpeg:appkit=False
            ffmpeg:avfoundation=False
            ffmpeg:coreimage=False
            ffmpeg:audiotoolbox=False
            ffmpeg:videotoolbox=False
            ffmpeg:securetransport=False)
    elseif(LINUX)
        list(APPEND FFMS2_OPTIONS ffmpeg:vaapi=False
            ffmpeg:vdpau=False
            ffmpeg:xcb=False
            ffmpeg:alsa=False
            ffmpeg:vaapi=False
            ffmpeg:pulse=False)
    endif()
    list(APPEND AEGISUB_CONAN_OPTIONS ${FFMS2_OPTIONS})
endif()

if(WITH_FFTW3)
    list(APPEND AEGISUB_CONAN_DEPS fftw/3.3.8@bincrafters/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::fftw)
endif()

if(WITH_ALSA)
    list(APPEND AEGISUB_CONAN_DEPS libalsa/1.1.9@conan/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::libalsa)
endif()

if(WITH_OPENAL)
    list(APPEND AEGISUB_CONAN_DEPS openal/1.19.0@bincrafters/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::openal)
endif()

if(WITH_HUNSPELL)
    list(APPEND AEGISUB_CONAN_DEPS libhunspell/1.7.0@charliejiang/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::libhunspell)
    target_compile_definitions(Aegisub PRIVATE "HUNSPELL_HAS_STRING_API")
endif()

if(WITH_UCHARDET)
    list(APPEND AEGISUB_CONAN_DEPS uchardet/0.0.6@charliejiang/stable)
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::uchardet)
endif()

if(WITH_PORTAUDIO)
    list(APPEND AEGISUB_CONAN_DEPS "portaudio/v190600.20161030@bincrafters/stable")
    list(APPEND AEGISUB_CONAN_IMPORT_TARGETS CONAN_PKG::portaudio)
endif()

if(WITH_TEST)
    list(APPEND AEGISUB_CONAN_DEPS "gtest/1.8.1")
endif()

message(STATUS "Aegisub Build: Settings collected, executing Conan...")

set(CONAN_IMPORTS
   "bin, *.dll -> ."
   "lib, *.dylib -> ."
   "lib, *.so* -> ."
)

conan_cmake_run(REQUIRES ${AEGISUB_CONAN_DEPS}
                OPTIONS ${AEGISUB_CONAN_OPTIONS}
                IMPORTS ${CONAN_IMPORTS}
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing)

target_link_libraries(Aegisub ${AEGISUB_CONAN_IMPORT_TARGETS})
target_link_libraries(libaegisub ${LIBAEGISUB_CONAN_IMPORT_TARGETS})


##############################################
# LEGACY find_package stuff
##############################################

message(STATUS "Aegisub Build: Loading remaining dependencies using find_package()...")

find_package(OpenGL REQUIRED)
target_include_directories(Aegisub PRIVATE ${OPENGL_INCLUDE_DIR})
target_link_libraries(Aegisub ${OPENGL_LIBRARIES})

if(WITH_AVISYNTH)
    find_package(AviSynth)
    if(NOT AviSynth_FOUND)
        set(WITH_AVISYNTH OFF CACHE BOOL "Enable AviSynth support" FORCE)
    endif()
endif()
if(WITH_AVISYNTH)
    target_compile_definitions(Aegisub PRIVATE "WITH_AVISYNTH" "AVS_LINKAGE_DLLIMPORT")
    target_include_directories(Aegisub PRIVATE ${AviSynth_INCLUDE_DIRS})
    target_link_libraries(Aegisub Vfw32 ${AviSynth_LIBRARIES})
endif()

if(WITH_LIBPULSE)
    find_package(PulseAudio)
    if(NOT PULSEAUDIO_FOUND)
        set(WITH_LIBPULSE OFF CACHE BOOL "Enable PulseAudio support" FORCE)
    endif()
endif()
if(WITH_LIBPULSE)
    target_include_directories(Aegisub PRIVATE ${PULSEAUDIO_INCLUDE_DIR})
    target_link_libraries(Aegisub ${PULSEAUDIO_LIBRARY})
endif()

if(WITH_OSS)
    find_package(OSS)
    if(NOT OSS_FOUND)
        set(WITH_OSS OFF CACHE BOOL "Enable OSS support" FORCE)
    endif()
endif()
if(WITH_OSS)
    target_include_directories(Aegisub PRIVATE ${OSS_INCLUDE_DIRS})
endif()

message(STATUS "Aegisub Build: Dependencies resolved.")
