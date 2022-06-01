# 
# https://stackoverflow.com/questions/6351609/cmake-linking-to-library-downloaded-from-externalproject-add
# https://gist.github.com/amir-saniyan/4339e6f3ef109c75eda8018f7d5192a7
# 
# 
# this way is possible to add prebuilt projects with find_package
# during configure time using ExternalProject_add
# 
# 
# this was created because I found impossible to use mmg2d with
# add_subdirectory and find_package(CONFIG). Could only be used
# as prebuilt library (as per its own docs, anyway). 
# 
# Install directory with external libraries without rebuilding
# them from source every time, in case you have to regenerate
# your project for dev testing over and over again while using
# the same libraries.  
# 
# Those supposedly should be in your /usr/local,
# but I found to be difficult to manage multiple version libs while
# using Brew et al, for instance. Thus this.
# 
# remember execute_process runs prior to build system generation
# 

# https://discourse.cmake.org/t/why-cmake-functions-cant-return-value/1710
# https://cmake.org/cmake/help/v3.0/module/CMakeParseArguments.html
# https://asitdhal.medium.com/cmake-functions-and-macros-22293041519f

# ----------------------------------------------------------------------------------------------------

function(trapper_add_package PACKAGE LOCATION HASHING)

    # 
    # cache
    # 
    
    # package download directory (mostly not needed, may be useful as downloaded packages cache)
    set(TRAPPER_DOWNLOAD_DIR "" CACHE PATH "Top level download cache dir. 
        Default to CMAKE_SOURCE_DIR/.cache")

    # package source directory (mostly not needed, set if you need to access sources directly)
    set(TRAPPER_SOURCE_DIR "" CACHE PATH "Top level source dir. 
        Defaults to CMAKE_SOURCE_DIR/external")

    # package binary directory (mostly not needed. Really)
    set(TRAPPER_BUILD_DIR "" CACHE PATH "Top level binary dir. 
        Defaults to CMAKE_BINARY_DIR")

    # package install directory
    set(TRAPPER_INSTALL_DIR "" CACHE PATH "Top level install dir. 
        Defaults to CMAKE_SOURCE_DIR/prebuilt")

    # option(TRAPPER_SKIP_OVERWRITE "Skip overwriting CMakeLists.txt and rebuilding every time" OFF)

    option(TRAPPER_SKIP_INSTALL_TAGS "Skip formatting install directory with tags" OFF)

    option(TRAPPER_SKIP_DEFAULTS "Skip enforcing Trapper defaults" OFF)

    option(TRAPPER_VERBOSE "Enable verbose output" OFF)                

    # 
    # parsing
    # 

    set(prefix "TRAPPER")
        
    set(flags    
        SKIP_DEFAULTS           # skip enforcing Trapper defaults
    
        HEADER_ONLY             # header-only package, skip build and skip install.
                                # you may want to use SOURCE_DIR for deploy
                                
        INSTALL_PREBUILT        # download and install an already built tool
    
        SKIP_OVERWRITE          # skip overwriting CMakeLists.txt and rebuilding every time. 
                                # supposedly you don't change variables between builds. One shot.
        SKIP_DOWNLOAD           # skip download step (already downloaded in the filesystem)
        SKIP_CONFIGURE          # skip configure step 
        SKIP_BUILD              # skip build step     
        SKIP_INSTALL            # skip install step   
        
        # SKIP_INSTALL_TAGS       # skip formatting install directory with tags

        SKIP_CACHE_FILTER       # skip package name cache filtering

        SKIP_UNPARSED_ARGS      # skip checking unparsed args

        VERBOSE                 # show configuration
        DEBUG                   # just for me
        )

    set(singleValues
        DOWNLOAD_DIR
        SOURCE_DIR
        BUILD_DIR
        INSTALL_DIR

        INSTALL_TAGS_SEPARATOR              # tag separator: default is "_" 
        )

    set(multiValues 
        INSTALL_TAGS                        # your own install tags: system_name, library version, etc.
        PACKAGE_OPTIONS                        # cmake tool options
        )

    include(CMakeParseArguments)

    cmake_parse_arguments(
                    ${prefix}
                    "${flags}"
                    "${singleValues}"
                    "${multiValues}"
                    ${ARGN})

    #
    # set managed config 
    #

    # TODO: default are directories filled with defaults
    # and everything to OFF (NAME THIS)
    # 
    if(NOT TRAPPER_SKIP_DEFAULTS)        
        set(TRAPPER_SKIP_INSTALL_TAGS ON)
        set(TRAPPER_SKIP_UNPARSED_ARGS ON)
        set(TRAPPER_SKIP_OVERWRITE ON)
        if(NOT TRAPPER_INSTALL_DIR)
            set(TRAPPER_INSTALL_DIR "${CMAKE_SOURCE_DIR}/prebuilt")
        endif()
    endif()
                
    # set minimal args
    set(TRAPPER_PACKAGE ${PACKAGE})
    set(TRAPPER_LOCATION ${LOCATION})
    set(TRAPPER_HASHING ${HASHING})

    if(TRAPPER_DEBUG)        
        message("---------------------------------------------------------")
        message(STATUS "TRAPPER ARGUMENTS LIST")
        message("---------------------------------------------------------")

        math(EXPR lastIndex "${ARGC}-1")
        foreach(index RANGE 0 ${lastIndex})
            message(STATUS "arg ${index}: ${ARGV${index}}")
        endforeach()
        message("---------------------------------------------------------")

        verbose()
    endif()

    #
    # check errors
    #

    # package name is required
    if(NOT TRAPPER_PACKAGE)
        message(FATAL_ERROR "Tool name is required")
    endif()

    # location is required
    if(NOT TRAPPER_LOCATION)
        message(FATAL_ERROR "Tool location is required")
    endif()

    # check for unparsed args    
    if(TRAPPER_UNPARSED_ARGUMENTS)
        if(TRAPPER_SKIP_UNPARSED_ARGS)
            message(WARNING "Trapper : Unparsed argument detected : ${TRAPPER_UNPARSED_ARGUMENTS}")        
        else()        
            message(FATAL_ERROR "Trapper : Unparsed argument detected : ${TRAPPER_UNPARSED_ARGUMENTS}")
        endif()   
    endif()

    # CHECK: here for the thirdparty error
    # set directories
    if(NOT TRAPPER_DOWNLOAD_DIR AND TRAPPER_SKIP_DEFAULTS)
        set(TRAPPER_DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/.cache")
    endif()

    if(NOT TRAPPER_SOURCE_DIR AND TRAPPER_SKIP_DEFAULTS)
        set(TRAPPER_SOURCE_DIR "${CMAKE_SOURCE_DIR}/external")
    endif()

    if(NOT TRAPPER_BUILD_DIR AND TRAPPER_SKIP_DEFAULTS)
        set(TRAPPER_BUILD_DIR "${CMAKE_BINARY_DIR}")
    endif()

    if(NOT TRAPPER_INSTALL_DIR AND TRAPPER_SKIP_DEFAULTS)
        set(TRAPPER_INSTALL_DIR "${CMAKE_SOURCE_DIR}/prebuilt")
    endif()
    
    # set tags separator
    if(NOT TRAPPER_INSTALL_TAGS_SEPARATOR)
        set(TRAPPER_INSTALL_TAGS_SEPARATOR "_")
    endif()

    # install dir is required
    if(NOT TRAPPER_INSTALL_DIR)
        message(FATAL_ERROR "Install dir is required")
    endif()

    #
    # check cache
    #

    # trapper package prefix options
    if(NOT TRAPPER_SKIP_CACHE_FILTER)
        get_prefixed_cachevars(${TRAPPER_PACKAGE})
    endif()

    # args
    list(APPEND TRAPPER_ARGS ${TRAPPER_PACKAGE_PREFIX_OPTIONS})
    list(APPEND TRAPPER_ARGS ${TRAPPER_PACKAGE_OPTIONS})
    if(TRAPPER_UNPARSED_ARGUMENTS AND TRAPPER_SKIP_UNPARSED_ARGS)
        list(APPEND TRAPPER_ARGS ${TRAPPER_UNPARSED_ARGUMENTS})
    endif()

    # 
    # check tags
    # 

    composite_installtags()

    # 
    # create dirs if missing
    # 

    if(TRAPPER_DOWNLOAD_DIR)
        createdir(${TRAPPER_DOWNLOAD_DIR} "download")
    endif()

    if(TRAPPER_SOURCE_DIR)
        createdir(${TRAPPER_SOURCE_DIR} "source")
    endif()

    if(TRAPPER_BUILD_DIR)
        createdir(${TRAPPER_BUILD_DIR} "build")
    endif()

    if(TRAPPER_INSTALL_DIR)
        createdir(${TRAPPER_INSTALL_DIR} "install")
    endif()
    
    # 
    # check build type
    # 

    get_buildtype()
    if(NOT DEFINED TRAPPER_CMAKE_BUILD_TYPE)
        message(STATUS "TRAPPER_CMAKE_BUILD_TYPE is undefined. Defaulting to Release")
        set(TRAPPER_CMAKE_BUILD_TYPE Release)
    endif()    

    # 
    # check steps
    # 

    if(TRAPPER_SKIP_DOWNLOAD)
        set(TRAPPER_DOWNLOAD_COMMAND "DOWNLOAD_COMMAND \"\"")
    else()
        if(IS_DIRECTORY ${TRAPPER_DOWNLOAD_DIR})
            set(TRAPPER_DOWNLOAD_DIR_COMMAND "DOWNLOAD_DIR \"${TRAPPER_DOWNLOAD_DIR}\"")
        endif()
    endif()
    
    if(TRAPPER_SKIP_CONFIGURE)
        set(source_cmd "CONFIGURE_COMMAND \"\"")
    else()
        if(IS_DIRECTORY ${TRAPPER_SOURCE_DIR})
            set(TRAPPER_SOURCE_DIR_COMMAND "SOURCE_DIR \"${TRAPPER_SOURCE_DIR}\"")
        endif()
    endif()

    if(TRAPPER_HEADER_ONLY)
        set(TRAPPER_SKIP_BUILD ON)
        set(TRAPPER_SKIP_INSTALL ON)
    endif()
    
    if(TRAPPER_SKIP_BUILD)
        set(TRAPPER_BUILD_COMMAND "BUILD_COMMAND \"\"")
    else()
        if(IS_DIRECTORY ${TRAPPER_BUILD_DIR})
            set(TRAPPER_BUILD_DIR_COMMAND "BINARY_DIR \"${TRAPPER_BUILD_DIR}\"")
        endif()            
    endif()
        
    # check install
    if(TRAPPER_SKIP_INSTALL)
        set(TRAPPER_INSTALL_COMMAND "INSTALL_COMMAND \"\"")
    else()
        if(IS_DIRECTORY ${TRAPPER_INSTALL_DIR})
            list(APPEND TRAPPER_ARGS "-D;CMAKE_INSTALL_PREFIX=${TRAPPER_INSTALL_DIR}")
        endif()
    endif()

    # check prebuilt
    if(TRAPPER_INSTALL_PREBUILT)
    
        # if prebuilt, skip building
        set(TRAPPER_CONFIGURE_COMMAND "CONFIGURE_COMMAND \"\"")           
        set(TRAPPER_BUILD_COMMAND "BUILD_COMMAND \"\"")
            
        # if prebuilt, just copy files from source dir
        set(TRAPPER_INSTALL_COMMAND "INSTALL_COMMAND \"${CMAKE_COMMAND}\" -E copy_directory <SOURCE_DIR> \"${TRAPPER_INSTALL_DIR}\"")

    endif()

    # 
    # check location and hash
    # 

    string(FIND ${TRAPPER_LOCATION} "tar" IS_TAR)
    string(FIND ${TRAPPER_LOCATION} "gz" IS_GZIP)
    string(FIND ${TRAPPER_LOCATION} "zip" IS_ZIP)
    if((IS_TAR GREATER_EQUAL 0) OR (IS_GZIP GREATER_EQUAL 0) OR (IS_ZIP GREATER_EQUAL 0))
        set(TRAPPER_LOCATION "URL \"${TRAPPER_LOCATION}\"")
        if(NOT TRAPPER_HASHING)
            set(TRAPPER_HASHING "")
        else()
            string(HEX ${TRAPPER_HASHING} hex_hashing)
            set(TRAPPER_HASHING "URL_MD5 ${hex_hashing}")
        endif()
    else()
        set(TRAPPER_LOCATION "GIT_REPOSITORY \"${TRAPPER_LOCATION}\"")
        set(TRAPPER_HASHING "GIT_TAG ${TRAPPER_HASHING}")
    endif()

    # NOTE: ExternalProject_Get_property(${target} SOURCE_DIR) doesn't work here

    # CMakeLists.txt
    set(CMAKELIST_CONTENT "
        cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

        project(build_external_project)

        include(ExternalProject)

        ExternalProject_add(
            ${TRAPPER_PACKAGE}
            ${TRAPPER_DOWNLOAD_DIR_COMMAND}
            ${TRAPPER_SOURCE_DIR_COMMAND}           
            ${TRAPPER_BUILD_DIR_COMMAND}
            ${TRAPPER_LOCATION}
            ${TRAPPER_HASHING}
            CMAKE_GENERATOR \"${CMAKE_GENERATOR}\"
            CMAKE_GENERATOR_PLATFORM \"${CMAKE_GENERATOR_PLATFORM}\"
            CMAKE_GENERATOR_TOOLSET \"${CMAKE_GENERATOR_TOOLSET}\"
            CMAKE_GENERATOR_INSTANCE \"${CMAKE_GENERATOR_INSTANCE}\"
            CMAKE_ARGS \"${TRAPPER_ARGS}\"
            ${TRAPPER_DOWNLOAD_COMMAND}
            ${TRAPPER_CONFIGURE_COMMAND}
            ${TRAPPER_BUILD_COMMAND}
            ${TRAPPER_INSTALL_COMMAND}
            )

        add_custom_target(build_external_project)
        
        add_dependencies(build_external_project ${TRAPPER_PACKAGE})
        
    ")

    if(TRAPPER_VERBOSE)
        verbose()
    endif()

    set(EXTERNALPROJECTS_TAG "ExternalProjects")    
    set(EXTERNALPROJECTS_DIR "${CMAKE_CURRENT_BINARY_DIR}/${EXTERNALPROJECTS_TAG}/${TRAPPER_PACKAGE}")
    set(EXTERNALPROJECTS_SCRIPT "${EXTERNALPROJECTS_DIR}/CMakeLists.txt")

    # check skip overwrite
    if(EXISTS ${EXTERNALPROJECTS_SCRIPT} AND TRAPPER_SKIP_OVERWRITE)
        return_values()
    endif()

    file(WRITE ${EXTERNALPROJECTS_SCRIPT} "${CMAKELIST_CONTENT}")
    
    set(EXTERNALPROJECTS_BUILD "${EXTERNALPROJECTS_DIR}/build")
    file(MAKE_DIRECTORY "${EXTERNALPROJECTS_DIR}" "${EXTERNALPROJECTS_BUILD}")

    # configure
    execute_process(COMMAND ${CMAKE_COMMAND}
        -G "${CMAKE_GENERATOR}"
        -A "${CMAKE_GENERATOR_PLATFORM}"
        -T "${CMAKE_GENERATOR_TOOLSET}"
        ..
        WORKING_DIRECTORY "${EXTERNALPROJECTS_BUILD}"
        RESULT_VARIABLE STATUS)

    if(STATUS AND NOT STATUS EQUAL 0)
        message(FATAL_ERROR "Execute process command failed with: ${STATUS}")
    endif()

    # build
    execute_process(COMMAND ${CMAKE_COMMAND}
        --build .
        --config ${TRAPPER_CMAKE_BUILD_TYPE}
        WORKING_DIRECTORY "${EXTERNALPROJECTS_BUILD}"
        RESULT_VARIABLE STATUS)

    if(STATUS AND NOT STATUS EQUAL 0)
        message(FATAL_ERROR "Execute process command failed with: ${STATUS}")
    endif()        

    # 
    # return values
    # 

    if(TRAPPER_DEBUG)
        verbose()
    endif()

    # report()

    return_values()

endfunction()

# ----------------------------------------------------------------------------------------------------

macro (composite_installtags)

    # check for directory overwriting
    if(TRAPPER_DOWNLOAD_DIR OR TRAPPER_SOURCE_DIR OR TRAPPER_BUILD_DIR)
        if(NOT TRAPPER_INSTALL_TAGS)
            message(STATUS "Trapper : added package tag name \"${TRAPPER_PACKAGE}\" to avoid package overwriting in working directories")
            list(APPEND TRAPPER_INSTALL_TAGS ${TRAPPER_PACKAGE})
        endif()

        list(JOIN TRAPPER_INSTALL_TAGS ${TRAPPER_INSTALL_TAGS_SEPARATOR} TRAPPER_COMP_INSTALL_TAGS)
    endif()
    
    # composite dirs
    if(TRAPPER_DOWNLOAD_DIR)
        set(TRAPPER_DOWNLOAD_DIR "${TRAPPER_DOWNLOAD_DIR}/${TRAPPER_COMP_INSTALL_TAGS}")
    endif()

    if(TRAPPER_SOURCE_DIR)
        set(TRAPPER_SOURCE_DIR "${TRAPPER_SOURCE_DIR}/${TRAPPER_COMP_INSTALL_TAGS}")
    endif()

    if(TRAPPER_BUILD_DIR)
        set(TRAPPER_BUILD_DIR "${TRAPPER_BUILD_DIR}/${TRAPPER_COMP_INSTALL_TAGS}")
    endif()

    if(TRAPPER_INSTALL_DIR)
        if(NOT TRAPPER_SKIP_INSTALL_TAGS)
            set(TRAPPER_INSTALL_DIR "${TRAPPER_INSTALL_DIR}/${TRAPPER_COMP_INSTALL_TAGS}")
        endif()
    endif()

endmacro()

# ----------------------------------------------------------------------------------------------------

function (createdir dir dirname)
    # check dir
    if(IS_ABSOLUTE ${dir})
        if(NOT EXISTS ${dir})
            message(STATUS "Trapper : created ${dirname} dir: ${dir}")
            file(MAKE_DIRECTORY ${dir})
        endif()
    endif()
endfunction()

# ----------------------------------------------------------------------------------------------------

# https://stackoverflow.com/questions/44006910/how-do-i-list-cmake-user-definable-variables
# https://stackoverflow.com/questions/32183975/how-to-print-all-the-properties-of-a-target-in-cmake

# returns: TRAPPER_PACKAGE_PREFIX_OPTIONS, TRAPPER_CMAKE_BUILD_TYPE
function(get_prefixed_cachevars tool_name)

    # add cache vars with tool_name inside
    get_directory_property(cache_vars CACHE_VARIABLES)
    if(TRAPPER_DEBUG)
        message("---------------------------------------------------------")
        message(STATUS "List of CACHE variables:")
        message(STATUS "${cache_vars}")
        message("---------------------------------------------------------")
    endif()

    set(PACKAGE_PREFIX_OPTIONS "")

    foreach(cache_var ${cache_vars})
        get_property(cache_value CACHE ${cache_var} PROPERTY VALUE)
        string(TOUPPER ${tool_name} toolnameup)
        string(TOLOWER ${tool_name} toolnamelw)
        
        set(added OFF)
        # add var if prefix is in name
        if(cache_var MATCHES "${toolnamelw}" OR cache_var MATCHES "${toolnameup}")
            list(APPEND PACKAGE_PREFIX_OPTIONS -D "${cache_var}=${cache_value}")
            set(added ON)
        endif()

        # add var if prefix is in value
        if(cache_value MATCHES "${toolnamelw}" OR cache_value MATCHES "${toolnameup}")
            list(APPEND PACKAGE_PREFIX_OPTIONS -D "${cache_var}=${cache_value}")
            set(added ON)
        endif()
        
        if(TRAPPER_DEBUG AND added)
            message(STATUS "adding to cache: ${cache_var} = ${cache_value}")                
        endif()            
    endforeach()

    # TODO:  also add filter by value
    # FIXME: this can be filtered out:
    # dlib_client_BINARY_DIR
    # dlib_client_IS_TOP_LEVEL
    # dlib_client_SOURCE_DIR

    set(TRAPPER_PACKAGE_PREFIX_OPTIONS ${PACKAGE_PREFIX_OPTIONS} PARENT_SCOPE)

endfunction()

# ----------------------------------------------------------------------------------------------------

function(get_buildtype)
    
    # get cmake build type
    get_directory_property(cache_vars CACHE_VARIABLES)
    get_property(cmbt CACHE "CMAKE_BUILD_TYPE" PROPERTY VALUE)
    set(TRAPPER_CMAKE_BUILD_TYPE ${cmbt} PARENT_SCOPE)

endfunction()

# ----------------------------------------------------------------------------------------------------

macro(verbose)

    message("---------------------------------------------------------")
    message(STATUS "TRAPPER CONFIGURATION")
    message("---------------------------------------------------------")
    
    message(STATUS "TRAPPER_PACKAGE                 : ${TRAPPER_PACKAGE}                ")
    message(STATUS "TRAPPER_LOCATION                : ${TRAPPER_LOCATION}               ")
    message(STATUS "TRAPPER_HASHING                 : ${TRAPPER_HASHING}                ")
    message(STATUS "TRAPPER_SKIP_OVERWRITE          : ${TRAPPER_SKIP_OVERWRITE}         ")
    message(STATUS "TRAPPER_SKIP_UNPARSED_ARGS      : ${TRAPPER_SKIP_UNPARSED_ARGS}     ")
    
    message(STATUS "TRAPPER_CMAKE_BUILD_TYPE        : ${TRAPPER_CMAKE_BUILD_TYPE}       ")
    
    message(STATUS "TRAPPER_SKIP_DOWNLOAD           : ${TRAPPER_SKIP_DOWNLOAD}          ")
    message(STATUS "TRAPPER_SKIP_CONFIGURE          : ${TRAPPER_SKIP_CONFIGURE}         ")
    message(STATUS "TRAPPER_SKIP_BUILD              : ${TRAPPER_SKIP_BUILD}             ")
    message(STATUS "TRAPPER_SKIP_INSTALL            : ${TRAPPER_SKIP_INSTALL}           ")
    
    message(STATUS "TRAPPER_SKIP_DEFAULTS           : ${TRAPPER_SKIP_DEFAULTS}          ")
    message(STATUS "TRAPPER_HEADER_ONLY             : ${TRAPPER_HEADER_ONLY}            ")
    message(STATUS "TRAPPER_INSTALL_PREBUILT        : ${TRAPPER_INSTALL_PREBUILT}       ")
    message(STATUS "TRAPPER_SKIP_INSTALL_TAGS       : ${TRAPPER_SKIP_INSTALL_TAGS}      ")

    message(STATUS "TRAPPER_SKIP_CACHE_FILTER       : ${TRAPPER_SKIP_CACHE_FILTER}      ")
    message(STATUS "TRAPPER_VERBOSE                 : ${TRAPPER_VERBOSE}                ")

    message("---------------------------------------------------------")
    message(STATUS "TRAPPER_OPTIONS_DIRS")
    message("---------------------------------------------------------")

    message(STATUS "TRAPPER_DOWNLOAD_DIR            : ${TRAPPER_DOWNLOAD_DIR}")
    message(STATUS "TRAPPER_SOURCE_DIR              : ${TRAPPER_SOURCE_DIR}")
    message(STATUS "TRAPPER_BUILD_DIR               : ${TRAPPER_BUILD_DIR}")
    message(STATUS "TRAPPER_INSTALL_DIR             : ${TRAPPER_INSTALL_DIR}")

    message("---------------------------------------------------------")
    message(STATUS "TRAPPER_INSTALL_TAGS")
    message("---------------------------------------------------------")

    foreach(tag ${TRAPPER_INSTALL_TAGS})
        message(STATUS "${tag}")
    endforeach()
    message(STATUS "TRAPPER_INSTALL_TAGS_SEPARATOR  : ${TRAPPER_INSTALL_TAGS_SEPARATOR} ")

    if(NOT TRAPPER_SKIP_CACHE_FILTER)

    message("---------------------------------------------------------")
    message(STATUS "TRAPPER_PACKAGE_PREFIX_OPTIONS")
    message("---------------------------------------------------------")

    foreach(option ${TRAPPER_PACKAGE_PREFIX_OPTIONS})
        if(NOT option MATCHES -D)
            message(STATUS "${option}")
        endif()
    endforeach()

    endif()

    message("---------------------------------------------------------")
    message(STATUS "TRAPPER_PACKAGE_OPTIONS")
    message("---------------------------------------------------------")

    set(added OFF)
    foreach(option ${TRAPPER_PACKAGE_OPTIONS})
        string(REPLACE -D "" optionr ${option})
        message(STATUS "${optionr} ")
        set(added ON)
    endforeach()

    if(added)
        message("---------------------------------------------------------")
    endif()

    if(TRAPPER_UNPARSED_ARGUMENTS AND TRAPPER_SKIP_UNPARSED_ARGS)
        message("---------------------------------------------------------")
        message(STATUS "TRAPPER_UNPARSED_ARGUMENTS")
        message("---------------------------------------------------------")
        
        foreach(unparg ${TRAPPER_UNPARSED_ARGUMENTS})
        message(STATUS "${unparg}")
        endforeach()       
    endif()

    if(TRAPPER_DEBUG)
        message("---------------------------------------------------------")
        message(STATUS "TRAPPER_ARGS")
        message("---------------------------------------------------------")
        message(STATUS "${TRAPPER_ARGS}")
        message("---------------------------------------------------------")
    endif()     

    message("---------------------------------------------------------")
    message("----------------- Start CMakeLists.txt ------------------")
    message("---------------------------------------------------------")
    message(${CMAKELIST_CONTENT})
    message("---------------------------------------------------------")
    message("------------------ End CMakeLists.txt -------------------")
    message("---------------------------------------------------------")

    # message("---------------------------------------------------------")

endmacro()

# ----------------------------------------------------------------------------------------------------

# macro(report)

#     if(NOT TRAPPER_DEBUG)            

#         # report
#         message("---------------------------------------------------------")
#         message(STATUS "TRAPPER_TOOL                    : ${TRAPPER_TOOL}")

#         message(STATUS "TRAPPER_DOWNLOAD_DIR            : ${TRAPPER_DOWNLOAD_DIR}")
#         message(STATUS "TRAPPER_SOURCE_DIR              : ${TRAPPER_SOURCE_DIR}")
#         message(STATUS "TRAPPER_BUILD_DIR               : ${TRAPPER_BUILD_DIR}")
#         message(STATUS "TRAPPER_INSTALL_DIR             : ${TRAPPER_INSTALL_DIR}")

#         message(STATUS "TRAPPER_SCRIPT                  : ${EXTERNALPROJECTS_SCRIPT}")
#         message("---------------------------------------------------------")
#         message(STATUS "TRAPPER_DOWNLOAD_DIR_COMMAND    : ${TRAPPER_DOWNLOAD_DIR_COMMAND}")
#         message(STATUS "TRAPPER_SOURCE_DIR_COMMAND      : ${TRAPPER_SOURCE_DIR_COMMAND}")
#         message(STATUS "TRAPPER_BUILD_DIR_COMMAND       : ${TRAPPER_BUILD_DIR_COMMAND}")
#         message("---------------------------------------------------------")

#         message(STATUS "TRAPPER_DOWNLOAD_COMMAND        : ${TRAPPER_DOWNLOAD_COMMAND}")
#         message(STATUS "TRAPPER_CONFIGURE_COMMAND       : ${TRAPPER_CONFIGURE_COMMAND}")
#         message(STATUS "TRAPPER_BUILD_COMMAND           : ${TRAPPER_BUILD_COMMAND}")
#         message(STATUS "TRAPPER_INSTALL_COMMAND         : ${TRAPPER_INSTALL_COMMAND}")
#         message("---------------------------------------------------------")

#     endif()

# endmacro()

# ----------------------------------------------------------------------------------------------------

macro(return_values)

    set(TRAPPER_PACKAGE ${TRAPPER_PACKAGE} PARENT_SCOPE)
    set(TRAPPER_DOWNLOAD_DIR ${TRAPPER_DOWNLOAD_DIR} PARENT_SCOPE)
    set(TRAPPER_SOURCE_DIR ${TRAPPER_SOURCE_DIR} PARENT_SCOPE)
    set(TRAPPER_BUILD_DIR ${TRAPPER_BUILD_DIR} PARENT_SCOPE)
    set(TRAPPER_INSTALL_DIR ${TRAPPER_INSTALL_DIR} PARENT_SCOPE)
    set(TRAPPER_SCRIPT ${EXTERNALPROJECTS_SCRIPT})

    return()

endmacro()

# ----------------------------------------------------------------------------------------------------

# FIXME:

# dlib md5 non funziona. provare una altra libreria in download 
# è il comando che è sbagliato, l'hash md5 è giusto
# non funziona nemmeno l'hash di un pacchetto prebuilt (embree p.es.)

# -----

# INSTALL_PREBUILT potrebbe essere eliminato da un controllo cmake sulla presenza del CMakeLists.txt

# -----

# viene creata una directory thirdparty/mmg anche se gli do una SOURCE_DIR differente

# Quando si clona libigl la directory thirdparty/mmg a root gli da fastidio:

# remote: Compressing objects: 100% (205/205), done.        
# remote: Total 38947 (delta 266), reused 313 (delta 185), pack-reused 38547        
# Receiving objects: 100% (38947/38947), 10.22 MiB | 6.06 MiB/s, done.
# Resolving deltas: 100% (24123/24123), done.
# HEAD is now at fe34fa73 Merge branch 'mmg_integration' into integration
# fatal: No url found for submodule path 'thirdparty/mmg' in .gitmodules
# CMake Error at .cache/libigl/libigl-download-prefix/tmp/libigl-download-gitclone.cmake:52 (message):
#   Failed to update submodules in:
#   '/Users/max/Developer/Stage/Workspace/AutoTools3D/dep/libigl'


# ninja: build stopped: subcommand failed.
# CMake Error at cmake/DownloadProject.cmake:179 (message):
#   Build step for libigl failed: 1
# Call Stack (most recent call first):
#   cmake/AutoTools3DDownloadExternal.cmake:14 (download_project)
#   cmake/AutoTools3DDownloadExternal.cmake:26 (kt_download_project_aux)
#   cmake/AutoTools3DDownloadExternal.cmake:59 (kt_download_project)
#   CMakeLists.txt:437 (kt_download_libigl)


# -- Configuring incomplete, errors occurred!

# Come se si aspettasse un submodule che non c'è


# TODO:

# config file per salvare le directory di build

# default params

# porta tutti i parametri a cmake options

# esempi mancanti (polyscope, imgui)

# cambia i nomi build to binary
# cambia i nomi tool to package

# NOTE:

# nessun install type "usr/local". si usano i normali apt-get e brew
# la install dir è necessaria. L'installazione in /usr/local non è consentita.
