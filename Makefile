all:

setup:
	for i in mode-*/config.d; do \
	 echo $${i}; \
	 [[ -d $${i} ]] || continue; \
	 (cd $${i}; cat ./_base.*.sh > base.sh); \
	done
	git diff
