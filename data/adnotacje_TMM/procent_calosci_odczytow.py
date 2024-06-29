# sprawdzenie otwartości chromatyny w grupach q i nq

import pandas as pd

# wybranie pliku
plik = input("Podaj nazwę pliku: ")

# wczytanie pliku
dane = pd.read_csv(plik, sep="\t", header=None)

suma = len(dane)
nq = dane[3] > 0
q = dane[3] < 0
suma_nq = len(dane[nq])
suma_q = len(dane[q])

print(f'W pliku znajduje się {suma} odczytów')
print(f'W pliku znajduje się {suma_nq} odczytów w grupie nq')
print(f'W pliku znajduje się {suma_q} odczytów w grupie q')
print(f'nq stanowią {suma_nq/suma*100}% a q stanowią {suma_q/suma*100}% wszystkich danych')