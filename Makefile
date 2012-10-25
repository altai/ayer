all:

install:
	install -m755 ayer* hoy* /usr/bin
	mkdir -p /usr/lib/ayer
	install -m644 lib/* /usr/lib/ayer

uninstall:
	rm -rf /usr/bin/{ayer,hoy}*
	rm -rf /usr/lib/ayer
