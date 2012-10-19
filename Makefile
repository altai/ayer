all:

install:
	install -m755 ayer* hoy* /usr/bin
	cp -r lib /usr/lib/ayer

uninstall:
	rm -rf /usr/bin/{ayer,hoy}*
	rm -rf /usr/lib/ayer
