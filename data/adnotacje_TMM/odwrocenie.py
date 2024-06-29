import pandas as pd

plik = input ("Podaj nazwę pliku: ")

dane = pd.read_csv(plik, sep='\t', header = None)

nazwa = plik.split('_')[2]

ala = dane.iloc[:,0] = dane.iloc[:,0][::-1].reset_index(drop=True)
ala.to_csv(f"nq_q_{nazwa}_geny.tsv", sep='\t', header = None, index = False)
