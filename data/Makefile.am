include $(top_srcdir)/Makefile.decl

filesdir = /usr/share/elmphonelog/icons

files_DATA = \
all.png \
in.png \
out.png \
missed.png \
info.png \
add_info.png \
photo.png \
$(NULL)

desktopdir   = $(datadir)/applications
desktop_DATA = elmphonelog.desktop

appicondir = $(datadir)/pixmaps
dist_appicon_DATA = elmphonelog.png

EXTRA_DIST += $(files_DATA)

CLEANFILES = Makefile

MAINTAINERCLEANFILES = Makefile.in
