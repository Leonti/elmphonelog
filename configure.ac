dnl This file is used by autoconf to produce ./configure

AC_PREREQ(2.61)
AC_INIT([elmphonelog], [0.0.1], [prishelec@gmail.com])
AC_CONFIG_SRCDIR([Makefile.am])
#AC_CONFIG_HEADERS(config.h)
AM_INIT_AUTOMAKE([foreign dist-bzip2])

AC_PROG_CC
AM_PROG_CC_C_O

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

ELM_REQUIRED=0.0.0
DBUS_REQUIRED=1.2
DBUSGLIB_REQUIRED=0.7
GLIB_REQUIRED=2.18.0
EVAS_REQUIRED=0.0.0
EINA_REQUIRED=0.0.0
EFLVALA_REQUIRED=0.0.0.0

PKG_CHECK_MODULES(DEPS,
  elementary >= $ELM_REQUIRED
  dbus-1 >= $DBUS_REQUIRED
  dbus-glib-1 >= $DBUSGLIB_REQUIRED
  glib-2.0 >= $GLIB_REQUIRED
  gobject-2.0 >= $GLIB_REQUIRED
  evas >= $EVAS_REQUIRED
  eina-0 >= $EINA_REQUIRED
  sqlite3 >= 0.0.0)

#PKG_CHECK_MODULES(SQLITE, sqlite3)
#AC_SUBST(SQLITE_CFLAGS)
#AC_SUBST(SQLITE_LIBS)

#set an explicit vapidir on compilation
AC_ARG_ENABLE([vapidir],
            [AS_HELP_STRING([--enable-vapidir=<dir>],[add custom <dir> as --vapidir] to valac)],
            [VAPI_DIR="--vapidir $enableval"],
            [VAPI_DIR=])
AC_SUBST([VAPI_DIR])

AC_SUBST(DEPS_CFLAGS)
AC_SUBST(DEPS_LIBS)

#DEPS2 are not needed for linking with the binary
#PKG_CHECK_MODULES(DEPS2,
#  eflvala-1.0 >= $EFLVALA_REQUIRED)
AC_SUBST(DEPS2_CFLAGS)
AC_SUBST(DEPS2_LIBS)

AC_CONFIG_FILES([ \
	Makefile \
	src/Makefile \
	data/Makefile \
	])

AC_OUTPUT
