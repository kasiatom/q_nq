import pandas as pd

# wybranie pliku
plik = input("Podaj nazwę pliku: ")

# wczytanie pliku
dane = pd.read_csv(plik, sep="\t", header=None)

suma = len(dane)

puste_dane = dane[dane[5] == '.']
suma_pustych = len(puste_dane)

suma_adnotacji = suma - suma_pustych

print(f'W pliku znajduje się {suma} odczytów')
print(f'W pliku znajduje się {suma_pustych} pustych adnotacji')
print(f'procent dopasowanych adnotacji to {suma_adnotacji/suma*100}%')
