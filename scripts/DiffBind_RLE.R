require(DiffBind)
require(readr)
require(profileplyr)

setwd("/home/kasia.tomala/diff-bind-results")
# for i in  q_nq/data/wyniki_HMMRATAC_l4u25c1.2/*accessible_regions.gappedPeak;do name=$(basename $i); cut -f1-4,13 $i | tail -n +2 | sed 's/0$/20/'> peaks/"$name";done

## porównanie szczepów ze wprowadzonymi mutacjami - podzielonymi na cztery grupy: 
## SPS (mutacje w SSY1, SSY5 lub PTR3 - te geny działaja w jednym szlaku), mutacje w nich pobudzają ten szlak, pomimo, że wygladają na unieczynniajace (usunięta domena regulacyjna, czy cos takiego)
## WHI
## SIR (SIR2, SIR3, SIR4) - to są białka wyciszające chromatynę, ich mutacje (jesli dezaktywujące) powinny prowadzić do wiekszej dostepności chromatyny
## WT (t02 i BY) - kontrole
## proszę zauważyć, że te grupy są bardzo niejednorodne - różne geny i rózne w nich mutacje  - to do dyskusji na podstawie heatmapy
## wczytanie danych - w pliku mut.tsv sa podane ścieżki do pików bam oraz tych gappedPeak (po modyfikacji - jak powyżej), 
mut_RLE  <- dba(sampleSheet="mut.tsv", filter = -1, bLowerScoreBetter = FALSE, peakFormat="bed")

## znalezienie wspólnych pikow (gappedPeaks) i policzenie dla nich pokrycia (z plików BAM)
mut_RLE <-dba.count (mut_RLE)

## normalizacja zliczeń - podzielenie przez ogólną liczbę odczytów - prosze doczytać, zrobiłam w opcji domyślnej
mut_RLE <- dba.normalize(mut_RLE, method=DBA_DESEQ2, normalize=DBA_NORM_NATIVE, BACKGROUND=TRUE)
mut_TMM <- dba.normalize(mut, method=DBA_EDGER, normalize=DBA_NORM_NATIVE, BACKGROUND=TRUE)

## rysunek pokazujący, czy próbki sa podobne - to jeszcze nie jest wynik analizy, prosze zobaczyć, że dwie kontrole mocno róźnią sie od siebie
pdf("mut_RLE_plot.pdf")
plot(mut_RLE)
dev.off()
mut_norm_RLE <- dba.normalize(mut_RLE, method=DBA_DESEQ2, bRetrieve=TRUE)
mut_norm_TMM <- dba.normalize(mut, method=edgeR, bRetrieve=TRUE)


## analiza: ustawienie kontrastów i samo wyszukanie peaków rózniących się stopniem dostępności
mut_contrast_RLE <- dba.contrast(mut_RLE, categories = DBA_CONDITION, minMembers=2, reorderMeta=list(Condition="WT"))
mut_analysis_RLE <- dba.analyze(mut_contrast_RLE)
contrasts_RLE <-dba.show(mut_analysis_RLE, bContrasts=TRUE)


## dane dla poszczególnych porównań (numer kontrastu mówi, co ze sobą porównujemy, żeby sie dowiedzieć, które porównanie ma jaki numer trzeba podejrzeć zmienną contrasts)
## zapisuje całe dane, także te nieistotne statystycznie (th - to poziom FDR -tu 1)
mut.wt_sir_RLE <- dba.report(mut_analysis_RLE, contrast = 5, th=1) 
mut.wt_whi_RLE <- dba.report(mut_analysis_RLE, contrast = 6, th=1)
mut.wt_sps_RLE <- dba.report(mut_analysis_RLE, contrast = 3, th=1 )
mut.sir_sps_RLE <-dba.report(mut_analysis_RLE, contrast = 1, th=1) # tutaj było ec_analysis, ale chyba powinno być mut_analysis
## nic istotnego nie wyszło w porównaniach wt vs inne grupy - może to byc wina niejednorodności kontroli
## niewiele wyszło dla WHI vs SPS i WHI vs SIR => pominiemy te porównania
## dość dobrze wyszło porównani SIR i SPS => to Pan może przedyskutować

## write to files
out.wt_sir <- as.data.frame(mut.wt_sir_RLE)
out.wt_whi <- as.data.frame(mut.wt_whi_RLE)
out.wt_sps <- as.data.frame(mut.wt_sps_RLE)
out.sir_sps <- as.data.frame(mut.sir_sps_RLE)

write_tsv(out.wt_sir, "wt-vs-sir-diffbind_RLE.tsv")
write_tsv(out.wt_whi, "wt-vs-whi-diffbind_RLE.tsv")
write_tsv(out.wt_sps, "wt-vs-sps-diffbind_RLE.tsv")
write_tsv(out.sir_sps, "sir-vs-sps-diffbind_RLE.tsv")

## narysowanie heatmapy, tylko dla SIR vs SPS - prosze popatrzeć, że nie jest źle - ssy, ptr wyglądają inaczej niż sir 
hmap <- colorRampPalette(c("red", "black", "green"))(n = 13)
pdf("sir-sps-heatmap_RLE.pdf")
dba.plotHeatmap(mut_analysis_RLE, contrast=1, correlations=FALSE, scale="row", colScheme = hmap)
dev.off()

## narysowanie wykreu "profiles", tylko dla SIR vs SPS
#profiles_mut <- dba.plotProfile(mut_analysis)
#pdf("sir-sps-profiles.pdf")
#dba.plotProfile(profiles_mut, contrast = 1)
#dev.off()


## szczepy po ewolucji - z wieloma mutacjami 
## wczytuje dane, tym razem z pliku ec.tsv
## będziemy porównywać trzy grupy:
## WT - to samo, co powyżej
## szczepy Q (selekcjonowane w kierunku tworzenia komórek Q - wytrzymałych na długie głodzenie, ale wolno powracających do wzrostu)
## szczepy NQ (selekcjonowane w kierunku tworzenia komórek NQ - gorzej znoszących głodzenie, ale za to szybko powracających do wzrostu)
ec_RLE  <- dba(sampleSheet="ec.tsv", filter = -1, bLowerScoreBetter = FALSE, peakFormat="bed")

## zliczenia dla pików
ec_RLE <-dba.count(ec_RLE)

## normalizacja
ec_RLE <- dba.normalize(ec_RLE, method=DBA_DESEQ2, normalize=DBA_NORM_NATIVE, BACKGROUND=TRUE)

## podobieństwo próbek - tu wygląda, że NQ i Q grupują sie trochę - to dobrze
pdf("ec_RLE_plot.pdf")
plot(ec_RLE)
dev.off()
ec_norm_RLE <- dba.normalize(ec_RLE, method=DBA_DESEQ2, bRetrieve=TRUE)

## kontrasty i analiza
ec_RLE_contrast<- dba.contrast(ec_RLE, categories = DBA_CONDITION, minMembers=2, reorderMeta=list(Condition="WT"))
ec_RLE_analysis <- dba.analyze(ec_RLE_contrast)
contrasts.ec <-dba.show(ec_RLE_analysis, bContrasts=TRUE)

## wyniki dla poszczególnych porównań, WT vs obie linie mniej pików niż dla porównani Q vc NQ
ec.wt_q_RLE <- dba.report(ec_RLE_analysis, contrast = 3, th =1)
ec.wt_nq_RLE <- dba.report(ec_RLE_analysis, contrast = 2, th =1 )
ec.q_nq_RLE <- dba.report(ec_RLE_analysis, contrast = 1, th =1)

out.wt_q <- as.data.frame(ec.wt_q_RLE)
out.wt_nq <- as.data.frame(ec.wt_nq_RLE)
out.q_nq <- as.data.frame(ec.q_nq_RLE)

write_tsv(out.wt_q, "wt-vs-q-diffbind_RLE.tsv")
write_tsv(out.wt_nq, "wt-vs-nq-diffbind_RLE.tsv")
write_tsv(out.q_nq, "q-vs-nq-diffbind_RLE.tsv")

## heatmapy - tym razem dla wszystkich porównań
pdf("wt-q-heatmap_RLE.pdf")
dba.plotHeatmap(ec_RLE_analysis, contrast=3, correlations=FALSE, scale="row", colScheme = hmap)
dev.off()

pdf("wt-nq-heatmap_RLE.pdf")
dba.plotHeatmap(ec_RLE_analysis, contrast=2, correlations=FALSE, scale="row", colScheme = hmap)
dev.off()

pdf("q-nq-heatmap_RLE.pdf")
dba.plotHeatmap(ec_RLE_analysis, contrast=1, correlations=FALSE, scale="row", colScheme = hmap)
dev.off()