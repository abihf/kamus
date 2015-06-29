
bin_PROGRAMS = kamus

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	$(KAMUS_CFLAGS)


kamus_SOURCES = \
	app.vala \
	window.vala \
	dictionary.vala \
	config.vapi 

kamus_VALAFLAGS = \
	--gresources=resources.xml \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--target-glib=2.38
	
GRESDEPS = $(srcdir)/$1 $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(srcdir) $(srcdir)/$1)
resource_deps = $(call GRESDEPS,resources.xml)
resources.c: $(resource_deps)
	$(GLIB_COMPILE_RESOURCES) $(srcdir)/resources.xml --target=$@ --generate-source --sourcedir=$(srcdir)


kamus_LDADD = $(KAMUS_LIBS) resources.o


CLEANFILES = *.c *.stamp
EXTRA_DIST = $(resources_deps)



# VALAC = valac
