import pandas as pd
plik = input ("Podaj nazwę pliku: ")
dane = pd.read_csv(plik, sep='\t', header = None)
posortowane = dane.sort_values(by=3)
nazwa = plik.split('.')[0]
print(nazwa)
posortowane.to_csv(f"{nazwa}_sorted.tsv", sep='\t', header = None, index = False)