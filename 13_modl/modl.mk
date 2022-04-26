SHELL := /bin/bash

DIR=${CONFIG_DIR}
ifeq ($(DIR),)
	DIR=.
endif

default: train plots eval

plots: $(DIR)/34_reco_valid.png $(DIR)/33_reco_valid_one.png
eval: $(DIR)/23_eval_one.log $(DIR)/24_eval.log
train: $(DIR)/11_weights.hdr

$(DIR)/23_eval_one.log: |$(DIR)/10_weights_one.hdr
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	weights=10_weights_one;										\
	source $(REPO)/00_data/02_dataset_description/00_parse_arguments.sh;				\
	bart version>23_eval_one.log;									\
	bart reconet --network=modl --eval -I$$ITERATIONS1  $${BART_GPU=} $${NORMALIZE=} $$network_opts $$eval_files>>23_eval_one.log;

$(DIR)/24_eval.log: |$(DIR)/11_weights.hdr
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	weights=11_weights;										\
	source $(REPO)/00_data/02_dataset_description/00_parse_arguments.sh;				\
	bart version>24_eval.log;									\
	bart reconet --network=modl --eval -I$$ITERATIONS2  $${BART_GPU=} $${NORMALIZE=} $$network_opts $$eval_files>>24_eval.log;

$(DIR)/34_reco_valid.hdr: |$(DIR)/11_weights.hdr
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	weights=11_weights;										\
	apply_out=34_reco_valid;									\
	apply_trj=$${valid_trj:=};									\
	apply_pat=$${valid_pat:=};									\
	apply_ksp=$$valid_ksp;										\
	apply_col=$$valid_col;										\
	if [ $$(bart show -d 4 $$apply_col) -gt 1 ]; then 						\
		TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`;				\
		trap 'rm -rf "$$TDIR"' EXIT;								\
		apply_out=$$TDIR/img;									\
	fi;												\
	source $(REPO)/00_data/02_dataset_description/00_parse_arguments.sh;				\
	bart reconet --network=modl --apply -I$$ITERATIONS2  $${BART_GPU=} $${NORMALIZE=} $$network_opts $$apply_files;\
	if [ $$(bart show -d 4 $$apply_col) -gt 1 ]; then 						\
		bart fmac -s $$(bart bitmask 4) $$TDIR/img $$apply_col $$TDIR/cim;			\
		bart rss $$(bart bitmask 3) $$TDIR/cim 34_reco_valid;					\
	fi

$(DIR)/33_reco_valid_one.hdr: |$(DIR)/10_weights_one.hdr
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	weights=10_weights_one;										\
	apply_out=33_reco_valid_one;									\
	apply_trj=$${valid_trj:=};									\
	apply_pat=$${valid_pat:=};									\
	apply_ksp=$$valid_ksp;										\
	apply_col=$$valid_col;										\
	if [ $$(bart show -d 4 $$apply_col) -gt 1 ]; then 						\
		TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`;				\
		trap 'rm -rf "$$TDIR"' EXIT;								\
		apply_out=$$TDIR/img;									\
	fi;												\
	source $(REPO)/00_data/02_dataset_description/00_parse_arguments.sh;				\
	bart reconet --network=modl --apply -I$$ITERATIONS1  $${BART_GPU=} $${NORMALIZE=} $$network_opts $$apply_files;\
	if [ $$(bart show -d 4 $$apply_col) -gt 1 ]; then 						\
		bart fmac -s $$(bart bitmask 4) $$TDIR/img $$apply_col $$TDIR/cim;			\
		bart rss $$(bart bitmask 3) $$TDIR/cim 33_reco_valid_one;				\
	fi


$(DIR)/33_reco_valid_one.png: |$(DIR)/33_reco_valid_one.hdr $(REPO)/02_scripts/21_plot_diff.py
	set -eu; cd $(DIR);										\
	source 00_config.sh;										\
	python $(REPO)/02_scripts/21_plot_diff.py 33_reco_valid_one $$valid_ref 33_reco_valid_one.png

$(DIR)/34_reco_valid.png: |$(DIR)/34_reco_valid.hdr $(REPO)/02_scripts/21_plot_diff.py
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	python $(REPO)/02_scripts/21_plot_diff.py 34_reco_valid $$valid_ref 34_reco_valid.png


$(DIR)/11_weights.hdr: |$(DIR)/10_weights_one.hdr
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	weights=11_weights;										\
	source $(REPO)/00_data/02_dataset_description/00_parse_arguments.sh;				\
	bart version>>03_log.log;									\
	bart reconet --network=modl --train -I$$ITERATIONS2  $${BART_GPU=} $${NORMALIZE=} -l10_weights_one -Texport-history=06_history -Tepochs=$$EPOCHS2 $$network_opts $$train_opts $$valid_files $$train_files>>03_log.log

$(DIR)/10_weights_one.hdr:
	set -eux; cd $(DIR);										\
	source 00_config.sh;										\
	weights=10_weights_one;										\
	source $(REPO)/00_data/02_dataset_description/00_parse_arguments.sh;				\
	bart version>03_log.log;									\
	bart reconet --network=modl --train -I$$ITERATIONS1  $${BART_GPU=} $${NORMALIZE=} -Texport-history=05_history_one -Tepochs=$$EPOCHS1 $$network_opts $$train_opts $$valid_files $$train_files>>03_log.log
