bin_PROGRAMS = elmphonelog

BUILT_SOURCES = .vala.stamp

NULL = 

elmphonelog_VALASOURCES = \
	abstract.vala \
	contact.vala \
	addcontact.vala \
	fileselector.vala \
	freesmartphone-gsm.vala \
	elmphonelog.vala \
	$(NULL)

elmphonelog_LDADD = \
	$(DEPS_LIBS) \
	$(THREAD_LIBS) \
	$(NULL)
#	-lsqlite3

elmphonelog_SOURCES = \
	$(elmphonelog_VALASOURCES:.vala=.c) \
	$(elmphonelog_VALASOURCES:.vala=.h) \
	$(NULL)


.vala.stamp: $(elmphonelog_VALASOURCES)
	$(VALAC) -c @VAPI_DIR@ \
	            --pkg dbus-glib-1 \
	            --pkg elm \
	            --pkg evas \
	            --pkg eina \
	            --pkg ecore \
		    --pkg sqlite3 \
	            --save-temps \
                    --basedir $(top_srcdir) \
	            $^
	touch $@

CLEANFILES = \
	*.c \
	*.h \
	.vala.stamp \
	$(NULL)

MAINTAINERCLEANFILES = Makefile.in