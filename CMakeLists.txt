cmake_minimum_required (VERSION 2.8.12)

project(ctracer)

# Create a sources variable with a link to all cpp files to compile
#set(SOURCES
#    src/main.c
#    src/vec3.c
#    src/ray.c
#    src/material.c
#    src/sphere.c
#    src/hitable_list.c
#    src/camera.c
#    src/common.c
#)

file(GLOB_RECURSE src_files source/*.cpp source/*.h)
list(FILTER src_files EXCLUDE REGEX ".*BuildSingleSphere\\.cpp")
list(FILTER src_files EXCLUDE REGEX ".*BuildBBCoverPic\\.cpp")
list(FILTER src_files EXCLUDE REGEX ".*BuildMultipleObjects\\.cpp")

#
#-I /opt/local/Library/Frameworks/wxWidgets.framework/Versions/wxWidgets/3.1/lib/wx/include/osx_cocoa-unicode-3.1
#-I /opt/local/Library/Frameworks/wxWidgets.framework/Versions/wxWidgets/3.1/include/wx-3.1 
#-D_FILE_OFFSET_BITS=64 -DWXUSINGDLL -D__WXMAC__ -D__WXOSX__ -D__WXOSX_COCOA__
#
SET(wxWidgets_USE_LIBS)
find_package(wxWidgets REQUIRED gl core base OPTIONAL_COMPONENTS net)
include(${wxWidgets_USE_FILE})

find_package(SDL2 REQUIRED)
# and for each of your dependent executable/library targets:

#-L/opt/local/Library/Frameworks/wxWidgets.framework/Versions/wxWidgets/3.1/lib
#-framework IOKit 
#-framework Carbon 
#-framework Cocoa 
#-framework QuartzCore 
#-framework AudioToolbox 
#-framework System 
#-framework OpenGL 
#-lwx_osx_cocoau_xrc-3.1 
#-lwx_osx_cocoau_html-3.1 
#-lwx_osx_cocoau_core-3.1 
#-lwx_baseu_xml-3.1 
#-lwx_baseu_net-3.1 
#-lwx_baseu-3.1

#add_executable(${PROJECT_NAME} src/main.c src/vec3.c src/ray.c src/material.c src/sphere.c src/hitable_list.c src/camera.c src/common.c)
add_executable(${PROJECT_NAME}  ${src_files} )
target_include_directories(${PROJECT_NAME} PUBLIC source/Utilities/)
target_include_directories(${PROJECT_NAME} PUBLIC source/World/)
target_include_directories(${PROJECT_NAME} PUBLIC source/Tracers/)
target_include_directories(${PROJECT_NAME} PUBLIC source/GeometricObjects/)
target_include_directories(${PROJECT_NAME} PUBLIC source/UserInterface)
target_include_directories(${PROJECT_NAME} PUBLIC source/build)
target_include_directories(${PROJECT_NAME} PUBLIC /opt/local/include/)
target_link_libraries(${PROJECT_NAME} ${wxWidgets_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${SDL2_LIBRARIES})
target_link_libraries(${PROJECT_NAME} m)
