## instalacja bedtools

```bash
conda install bedtools
```

## przygotowanie plików wynikowych z diffbind ( na przykładzie pliku q-vs-nq-diffbind.tsv):  
  1. wycięcie tylko kolumn z położeniem plików, fold i FDR, zamiana początków pików gdy koordynaty start < 0 na 1, pozbycie się nagłówka, posortowanie)
  
```bash
 # 1
 ## chr, start, end, fold, FDR
 # fold dodatni oznacza że wiązanie z nq jest większe niż z q
 # ujemny fold - odwrotnie
 tail -n +2 q-vs-nq-diffbind_TMM.tsv | awk -F '\t' 'BEGIN {OFS="\t"} {if ($1 != "seqnames") {print $1,$2,$3,$9,$11 }}' | sort -k1,1V -k2,2n | sed 's/-[0-9]*\t/1\t/' > nq_q.tsv

 
 ```

 ## sprawdzenie, czy piki pokrywaja się z promotorami, 5'UTR, sekwencjami kodującymi genów (na przykładzie pliku q_nq.tsv - z poprzedniego kroku)  
 ```bash

 ## promotory
 bedtools intersect -wao -a nq_q.tsv -b promoters.tsv > nq_q_prom.tsv

 ## 5UTR
  bedtools intersect -wao -a nq_q.tsv -b 5utr.tsv  > nq_q_5utr.tsv

  ## sekwencje kodujące
  bedtools intersect -wao -a nq_q.tsv -b cds.tsv > nq_q_cds.tsv
  ```

  ## Uwagi
   1. Cieszylibyśmy się, gdyby wiekszość pików pokrywała się z promotorami i ewentualnie 5' UTR. Pokrycie CDS - też ok, bo do wolna chromatyna, nie miejsce wiązania czynników, więc jesli idzie transkrypcja, to i sekwencje kodująca chyba moze być odkryta.  
   2. Ostatnia kolumna wyniku mówi, ile nukleotydów piku i danego promotora/UTR/CDSu zachodziło na siebie, przedostatnia kolumna to nazwa genu, kolumna 4 to wartość FDR (z programu diffbind)  
   3. Dla listy uzyskanych genów można sprawdzić wzbogacenie GO (np. tutaj https://cbl-gorilla.cs.technion.ac.il/ - jako jedną listę genów posortowaną po rosnącym FDR)  
   4. Położenie sekwencji kodującej - wzięłam z pliku gtf z Ensembl (dla drożdży R64-1-1)  
   5. Położenie 5' UTR - wzięłam z SGD (plik `SGD_all_ORFs_5prime_UTRs.fsa.zip`) - jeśli kilka położeń początków UTR dla tego samego genu, to dalsze od kodonu start  
   6. Położenia promotorów z tej pracy: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6633255 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6633255/bin/supp_gr.245456.118_Supplemental_Data_S5_S8.xlsx, Data_S5, wyrzuciłam wpisy bez przypisanego genu)  

       


