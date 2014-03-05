all:

build: setup deploy

deploy:
	for i in mode-*/; do \
	 echo $${i}; \
	 [[ -d $${i} ]] || continue; \
	 cp -p common.d/Vagrantfile $${i}/; \
	 cp -p common.d/failover-test.sh $${i}/; \
	 cp -p common.d/node*.sh $${i}/config.d/; \
	 cp -p common.d/_base.common.sh $${i}/config.d/; \
	done
setup:
	for i in mode-*/config.d; do \
	 echo $${i}; \
	 [[ -d $${i} ]] || continue; \
	 (cd $${i}; cat ./_base.*.sh > base.sh); \
	done
	git diff
