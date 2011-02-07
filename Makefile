dist : format Makefile update.sh install-update.sh
	mkdir -p dist
	[ -e dist/xt720opt.zip ] && rm dist/xt720opt.zip
	find . -type f | grep -v "^./.git" | grep -v "^./dist" | grep -v "^./tools" | grep -v '~$$' | grep -v Makefile | zip -@ -9 dist/xt720opt.zip
	adb push dist/xt720opt.zip /sdcard/

format :
	tools/sh_b.rb update.sh
	tools/sh_b.rb install-update.sh
	tools/sh_b.rb pkgexec/system/etc/install-recovery.sh
