#***************************************************************************
#                                  _   _ ____  _
#  Project                     ___| | | |  _ \| |
#                             / __| | | | |_) | |
#                            | (__| |_| |  _ <| |___
#                             \___|\___/|_| \_\_____|
#
# Copyright (C) Daniel Stenberg, <daniel@haxx.se>, et al.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at https://curl.se/docs/copyright.html.
#
# You may opt to use, copy, modify, merge, publish, distribute and/or sell
# copies of the Software, and permit persons to whom the Software is
# furnished to do so, under the terms of the COPYING file.
#
# This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
# KIND, either express or implied.
#
# SPDX-License-Identifier: curl
#
###########################################################################
# Find the libssh library
#
# Input variables:
#
# LIBSSH_INCLUDE_DIR   The libssh include directory
# LIBSSH_LIBRARY       Path to libssh library
#
# Result variables:
#
# LIBSSH_FOUND         System has libssh
# LIBSSH_INCLUDE_DIRS  The libssh include directories
# LIBSSH_LIBRARIES     The libssh library names
# LIBSSH_VERSION       Version of libssh

if(CURL_USE_PKGCONFIG AND
   NOT DEFINED LIBSSH_INCLUDE_DIR AND
   NOT DEFINED LIBSSH_LIBRARY)
  find_package(PkgConfig QUIET)
  pkg_check_modules(LIBSSH "libssh")
endif()

if(LIBSSH_FOUND)
  if(NOT DEFINED LIBSSH_LINK_LIBRARIES)
    set(LIBSSH_LINK_LIBRARIES ${LIBSSH_LIBRARIES})  # Workaround for some systems (seen on Old Linux CI)
  endif()
  set(LIBSSH_LIBRARIES ${LIBSSH_LINK_LIBRARIES})
  message(STATUS "Found Libssh (via pkg-config): ${LIBSSH_INCLUDE_DIRS} (Found version \"${LIBSSH_VERSION}\")")
else()
  find_path(LIBSSH_INCLUDE_DIR NAMES "libssh/libssh.h")
  find_library(LIBSSH_LIBRARY NAMES "ssh" "libssh")

  if(LIBSSH_INCLUDE_DIR AND EXISTS "${LIBSSH_INCLUDE_DIR}/libssh/libssh_version.h")
    set(_version_regex1 "#[\t ]*define[\t ]+LIBSSH_VERSION_MAJOR[\t ]+([0-9]+).*")
    set(_version_regex2 "#[\t ]*define[\t ]+LIBSSH_VERSION_MINOR[\t ]+([0-9]+).*")
    set(_version_regex3 "#[\t ]*define[\t ]+LIBSSH_VERSION_MICRO[\t ]+([0-9]+).*")
    file(STRINGS "${LIBSSH_INCLUDE_DIR}/libssh/libssh_version.h" _version_str1 REGEX "${_version_regex1}")
    file(STRINGS "${LIBSSH_INCLUDE_DIR}/libssh/libssh_version.h" _version_str2 REGEX "${_version_regex2}")
    file(STRINGS "${LIBSSH_INCLUDE_DIR}/libssh/libssh_version.h" _version_str3 REGEX "${_version_regex3}")
    string(REGEX REPLACE "${_version_regex1}" "\\1" _version_str1 "${_version_str1}")
    string(REGEX REPLACE "${_version_regex2}" "\\1" _version_str2 "${_version_str2}")
    string(REGEX REPLACE "${_version_regex3}" "\\1" _version_str3 "${_version_str3}")
    set(LIBSSH_VERSION "${_version_str1}.${_version_str2}.${_version_str3}")
    unset(_version_regex1)
    unset(_version_regex2)
    unset(_version_regex3)
    unset(_version_str1)
    unset(_version_str2)
    unset(_version_str3)
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Libssh
    REQUIRED_VARS
      LIBSSH_INCLUDE_DIR
      LIBSSH_LIBRARY
    VERSION_VAR
      LIBSSH_VERSION
  )

  if(LIBSSH_FOUND)
    set(LIBSSH_INCLUDE_DIRS ${LIBSSH_INCLUDE_DIR})
    set(LIBSSH_LIBRARIES    ${LIBSSH_LIBRARY})
  endif()

  mark_as_advanced(LIBSSH_INCLUDE_DIR LIBSSH_LIBRARY)
endif()
