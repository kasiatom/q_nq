import pandas as pd

plik = input ("Podaj nazwę pliku: ")
dane = pd.read_csv(plik, sep='\t', header = None)
geny = dane.iloc[:,10]
nazwa = plik.split('.')[0]
geny.to_csv(f"{nazwa}_geny.tsv", sep='\t', header = None, index = False)