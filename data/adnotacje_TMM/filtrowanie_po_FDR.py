import pandas as pd
# znalezienie pliku
plik = input ("Podaj nazwę pliku: ")
# wczytanie pliku   
dane = pd.read_csv(plik, sep='\t', header = None)
print(dane[4])
# zmiana formatu danych w kolumnie 5 na 10 miejsc po przecinku
#dane[4] = dane[4].apply(lambda x: '{:.10f}'.format(x))
# filtrowanie danych po wartościach mniejszych od 0.05
pofiltrowane = dane[dane[4] < 0.05]
# zapisanie pliku z filtrowanymi danymi
nazwa = plik.split('.')[0]
pofiltrowane.to_csv(f"{nazwa}_filtered.tsv", sep='\t', header = None, index = False)
        