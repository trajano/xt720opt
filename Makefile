dist : Makefile update.sh
	mkdir -p dist
	find . -type f | grep -v "^./.git" | grep -v "^./dist" | grep -v "^./tools" | grep -v '~$$' | grep -v Makefile | zip -@ -9 dist/xt720opt.zip
	adb push dist/xt720opt.zip /sdcard/

clean :
	tools/sh_b.rb update.sh
	tools/sh_b.rb pkg/system/etc/install-recovery.sh
