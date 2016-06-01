IF (WIN32)
   SET(APR_NAME libapr-1)
   SET(APRUTIL_NAME libaprutil-1)
ELSE (WIN32)
   SET(APR_NAME apr-1)
   SET(APRUTIL_NAME aprutil-1)
ENDIF (WIN32)


FIND_PATH (APACHE_INCLUDES_DIR 
   NAMES
      apr.h
      apu.h
      httpd.h
   PATHS 
      /usr/local/apache/include
      /usr/local/apache2/include
      /usr/local/include/httpd
      /usr/include/httpd
      /usr/local/include/apr-1
      /usr/local/include/apr-1.0
      /usr/include/apr-1
      /usr/include/apr-1.0
)

FIND_PATH (APACHE_LIBRARIES_DIR 
   NAMES 
      ${APR_NAME}
      ${APRUTIL_NAME}
   PATHS 
      /usr/local/apache/lib
      /usr/local/apache2/lib
      /usr/local/lib
      /usr/lib
)



# APR first.
FIND_PATH (APR_INCLUDE_DIR 
   NAMES 
      apr.h
   PATHS 
      ${APACHE_INCLUDES_DIR}
      /usr/local/apache/include
      /usr/local/apache2/include
      /usr/local/include/apr-1
      /usr/local/include/apr-1.0
      /usr/include/apr-1
      /usr/include/apr-1.0
)
FIND_LIBRARY (APR_LIBRARY 
   NAMES 
      ${APR_NAME}
   PATHS 
      ${APACHE_LIBRARIES_DIR}
      /usr/local/apache/lib
      /usr/local/apache2/lib
      /usr/local/lib
      /usr/lib
)
IF (APR_INCLUDE_DIR AND APR_LIBRARY)
   SET (APR_FOUND TRUE)
   MESSAGE (STATUS "Found Apache Portable Runtime: ${APR_INCLUDE_DIR}, ${APR_LIBRARY}")
ELSE (APR_INCLUDE_DIR AND APR_LIBRARY)
   SET (APR_FOUND FALSE)
   MESSAGE (STATUS "Can't find Apache Portable Runtime")
ENDIF (APR_INCLUDE_DIR AND APR_LIBRARY)



# Next,  APRUTIL.
FIND_PATH (APRUTIL_INCLUDE_DIR 
   NAMES 
      apu.h
   PATHS
      ${APACHE_INCLUDES_DIR}
      /usr/local/apache/include
      /usr/local/apache2/include
      /usr/local/include/apr-1
      /usr/local/include/apr-1.0
      /usr/include/apr-1
      /usr/include/apr-1.0
)
FIND_LIBRARY (APRUTIL_LIBRARY 
   NAMES 
      ${APRUTIL_NAME}
   PATHS 
      ${APACHE_LIBRARIES_DIR}
      /usr/local/apache/lib
      /usr/local/apache2/lib 
      /usr/local/lib
      /usr/lib 
)
IF (APRUTIL_INCLUDE_DIR AND APRUTIL_LIBRARY)
   SET(APRUTIL_FOUND TRUE)
   MESSAGE (STATUS "Found Apache Portable Runtime Utils: ${APRUTIL_INCLUDE_DIR}, ${APRUTIL_LIBRARY}")
ELSE (APRUTIL_INCLUDE_DIR AND APRUTIL_LIBRARY)
   SET(APRUTIL_FOUND FALSE)
   MESSAGE (STATUS "Can't find Apache Portable Runtime Utils")
ENDIF (APRUTIL_INCLUDE_DIR AND APRUTIL_LIBRARY)



# Next,  HTTPD.
FIND_PATH (HTTPD_INCLUDE_DIR 
   NAMES 
      httpd.h
   PATHS
      ${APACHE_INCLUDES_DIR}
      /usr/local/apache/include
      /usr/local/apache2/include
      /usr/local/include/httpd
      /usr/include/httpd
)

# Next, bin directory
FIND_PATH (HTTPD_BIN
   NAMES
      apachectl
   PATHS
      /usr/local/apache/bin
      /usr/local/apache2/bin
      /usr/local/httpd/bin
      /etc/httpd/bin
)

#Next, module directory
FIND_PATH (HTTPD_MODULES
   NAMES
      libphp5.so
      mod_suphp.so
      mod_disable_suexec.so
   PATHS
      /usr/local/apache/modules
      /usr/local/apache2/modules
      /usr/local/httpd/modules
      /etc/httpd/modules
)

FIND_PROGRAM(APACHECTL NAMES apachectl)
IF (APACHECTL)
    EXECUTE_PROCESS(COMMAND ${APACHECTL} -v OUTPUT_VARIABLE vers)
    STRING(SUBSTRING "${vers}" 23 3 vrvar)
    MESSAGE(STATUS "Version ${vrvar}...")
    IF ("${vrvar}" STREQUAL "2.0")
	SET(APACHE_2_0 TRUE)
	MESSAGE(STATUS "apache 2.0 detected...")
    ELSE ("${vrvar}" STREQUAL "2.0")
	SET(APACHE_2_2 TRUE)
	MESSAGE(STATUS "apache 2.2 detected...")
    ENDIF ("${vrvar}" STREQUAL "2.0")
ELSE (APACHECTL)
    SET(APACHE_2_2 TRUE)
    MESSAGE(STATUS "Default apache 2.2 detected...")
ENDIF (APACHECTL)

IF (HTTPD_BIN AND HTTPD_MODULES)
   SET(HTTPD_BIN_FOUND TRUE)
   MESSAGE (STATUS "Found Apache Bin Directory: ${HTTPD_BIN}, ${HTTPD_MODULES}")
ELSE (HTTPD_BIN AND HTTPD_MODULES)
   SET(HTTPD_BIN_FOUND FALSE)
   MESSAGE (STATUS "Not Found Apache Bin Directory: ${HTTPD_BIN}, ${HTTPD_MODULES}")
ENDIF(HTTPD_BIN AND HTTPD_MODULES)

IF (WIN32)
    FIND_LIBRARY (HTTPD_LIBRARY 
       NAMES 
          libhttpd
       PATHS 
          ${APACHE_LIBRARIES_DIR} 
    )
    IF (HTTPD_INCLUDE_DIR AND HTTPD_LIBRARY)
       SET (APACHE2_FOUND TRUE)
       MESSAGE (STATUS "Found Apache2: ${HTTPD_INCLUDE_DIR}, ${HTTPD_LIBRARY}")
    ELSE (HTTPD_INCLUDE_DIR AND HTTPD_LIBRARY)
       SET (APACHE2_FOUND FALSE)
       MESSAGE (STATUS "Can't find Apache2")
    ENDIF (HTTPD_INCLUDE_DIR AND HTTPD_LIBRARY)

ELSE (WIN32)

    IF (HTTPD_INCLUDE_DIR)
       SET (APACHE2_FOUND TRUE)
       MESSAGE (STATUS "Found Apache2: ${HTTPD_INCLUDE_DIR}")
    ELSE (HTTPD_INCLUDE_DIR)
       SET (APACHE2_FOUND FALSE)
       MESSAGE (STATUS "Can't find Apache2")
    ENDIF (HTTPD_INCLUDE_DIR)

ENDIF (WIN32)


FIND_PROGRAM(ISDAEMONINST NAMES daemon_sucgid PATHS /usr/local/sbin /usr/sbin)
IF (ISDAEMONINST)
    MESSAGE(STATUS "Daemon already installed...")
ELSE (ISDAEMONINST)
    MESSAGE(STATUS "Daemon and module will be install...")
ENDIF (ISDAEMONINST)

IF ("${APACHE_USER}" STREQUAL "")
EXECUTE_PROCESS(COMMAND cat /etc/passwd COMMAND grep apache OUTPUT_VARIABLE nm)
IF ("${nm}" STREQUAL "")
    SET(APACHE_USER nobody)
    MESSAGE(STATUS "User nobody detected...")
ELSE ("${nm}" STREQUAL "")
    SET(APACHE_USER apache)
    MESSAGE(STATUS "User apache detected...")
ENDIF ("${nm}" STREQUAL "")
ENDIF ("${APACHE_USER}" STREQUAL "")
