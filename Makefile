all:

install:
	install -m755 ayer* hoy* $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/usr/lib/ayer
	install -m644 lib/* $(DESTDIR)/usr/lib/ayer

uninstall:
	rm -rf $(DESTDIR)/usr/bin/{ayer,hoy}* $(DESTDIR)/usr/lib/ayer
