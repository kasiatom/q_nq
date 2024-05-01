## instalacja bedtools

```bash
conda install bedtools
```

## przygotowanie plików wynikowych z diffbind ( na przykładzie pliku q-vs-nq-diffbind.tsv):  
  1. wyodrębnienie linii gdzie NQ miały statystycznie wyższe wiązanie niż Q (FDR < 0.05 i Conc_NQ > Conc_Q) i zmiana formatu plików (wycięcie tylko kolumn z położeniem plików i FDR, zamiana początków pików gdy koordynaty start < 0 na 1, pozbycie się nagłówka, posortowanie)
  2.  wyodrębnienie linii gdzie Q miały statystycznie wyższe wiązanie niż NQ (FDR< 0.05 i Conc_Q > Conc_NQ) i zmiana formatu plików (wycięcie tylko kolumn z położeniem plików i FDR, zamiana początków pików gdy koordynaty start < 0 na 1, pozbycie się nagłówka, posortowanie)
```bash
 # 1
 tail -n +2 q-vs-nq-diffbind.tsv \
 | awk -F '\t' 'BEGIN {OFS="\t"} {if ($7 > $8 && $11 < 0.05) {print $1,$2,$3,$11 }}' \
 | sort -k1,1V -k2,2n \
 | sed 's/-[0-9]*\t/1\t/' > nq_q.tsv

 # 2
 tail -n +2 q-vs-nq-diffbind.tsv \
 | awk -F '\t' 'BEGIN {OFS="\t"} {if ($7 < $8 && $11 < 0.05) {print $1,$2,$3,$11 }}' \
 | sort -k1,1V -k2,2n \
 | sed 's/-[0-9]*\t/1\t/' > q_nq.tsv

 ```

 ## sprawdzenie, czy piki pokrywaja się z promotorami, 5'UTR, sekwencjami kodującymi genów (na przykładzie pliku q_nq.tsv - z poprzedniego kroku)  
 ```bash

 ## promotory
 bedtools intersect -wao -a q_nq.tsv -b promoters.tsv > q_nq_prom.tsv

 ## 5UTR
  bedtools intersect -wao -a q_nq.tsv -b 5utr.tsv  > q_nq_5utr.tsv

  ## sekwencje kodujące
  bedtools intersect -wao -a q_nq.tsv -b cds.tsv > q_nq_cds.tsv
  ```

  ## Uwagi
   1. Cieszylibyśmy się, gdyby wiekszość pików pokrywała się z promotorami i ewentualnie 5' UTR. Pokrycie CDS - też ok, bo do wolna chromatyna, nie miejsce wiązania czynników, więc jesli idzie transkrypcja, to i sekwencje kodująca chyba moze być odkryta.  
   2. Ostatnia kolumna wyniku mówi, ile nukleotydów piku i danego promotora/UTR/CDSu zachodziło na siebie, przedostatnia kolumna to nazwa genu, kolumna 4 to wartość FDR (z programu diffbind)  
   3. Dla listy uzyskanych genów można sprawdzić wzbogacenie GO (np. tutaj https://cbl-gorilla.cs.technion.ac.il/ - jako jedną listę genów posortowaną po rosnącym FDR)  
   4. Połozenie sekwencji kodującej - z pliku gtf z Ensembl (dla drożdży R64-1-1)  
   5. Połozenie 5' UTR - z SGD (plik `SGD_all_ORFs_5prime_UTRs.fsa.zip`) - jeśli kilka położeń początków UTR dla tego samego genu, to dalsze od kodonu start  
   6. Położenia promotorów z tej pracy: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6633255 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6633255/bin/supp_gr.245456.118_Supplemental_Data_S5_S8.xlsx, Data_S5, wyrzuciłam wpisy bez przypisanego genu)  

       


