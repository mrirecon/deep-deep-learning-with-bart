
.PHONY: default clean data_modl data_varnet

PLOTS=
PLOTS+= Figure_04a/figure_04a_varnet
PLOTS+= Figure_04b/figure_04b_modl
PLOTS+= Figure_05/figure_05_softsense
PLOTS+= Figure_06/figure_06_noncart
PLOTS+= Figure_07/figure_07_timing
PLOTS+= Figure_08/figure_08_tensorflow

default: $(PLOTS:=.png) $(PLOTS:=.pdf)
clean:
	rm -f $(PLOTS:=.png)
	rm -f $(PLOTS:=.pdf)
	rm -f Figure*/reco*
	rm -f Sup_Figure_01/sup_figure_01.png
	rm -f Sup_Figure_01/sup_figure_01.pdf

allclean: clean
	rm -f Figure_*/measures/measure
	rm -f Sup_Figure_01/history*

.SECONDARY:Figure_04a/reco Figure_04b/reco Figure_05/reco Figure_06/reco Figure_08/reco

# Renaming figures in directories

Figure_04a/figure_04a_varnet.%:Figure_04a/figure.%
	mv $< $@

Figure_04b/figure_04b_modl.%:Figure_04b/figure.%
	mv $< $@

Figure_05/figure_05_softsense.%:Figure_05/figure.%
	mv $< $@

Figure_06/figure_06_noncart.%:Figure_06/figure.%
	mv $< $@

Figure_07/figure_07_timing.%:Figure_07/figure.%
	mv $< $@

Figure_08/figure_08_tensorflow.%:Figure_08/figure.%
	mv $< $@


# Generic Pipeline:
#	Call 00_run.sh to do reconstruction
#	Call 01_plot.sh to create figure

Figure_%/reco:Figure_%/00_run.sh
	cd $(@D); bash 00_run.sh
	touch $@

Figure_%/figure.pdf:Figure_%/reco Figure_%/01_plot.py
	cd $(@D); python3 01_plot.py $(@F)

Figure_%/figure.png:Figure_%/reco Figure_%/01_plot.py
	cd $(@D); python3 01_plot.py $(@F)

# Create measures (PSNR/SSIM)

Figure_%/measures/measure:
	mkdir -p Figure_$*/measures
	bash Figure_$*/00_create_measure.sh
	touch Figure_$*/measures/measure

# Additional dependencies for Fig 04a/04b/05/06
Figure_04a/reco: Figure_04a/measures/measure
Figure_04b/reco: Figure_04b/measures/measure
Figure_05/reco: Figure_05/measures/measure
Figure_06/reco: Figure_06/measures/measure

#Supplementary Figure
Sup_Figure_01/history_bart_eval.hdr:
	bash Sup_Figure_01/00_eval_bart.sh

Sup_Figure_01/history_tf_eval.hdr:
	bash Sup_Figure_01/00_eval_tf.sh

Sup_Figure_01/sup_figure_01.%: Sup_Figure_01/01_plot.py | Sup_Figure_01/history_tf_eval.hdr Sup_Figure_01/history_bart_eval.hdr
	python3 Sup_Figure_01/01_plot.py $@