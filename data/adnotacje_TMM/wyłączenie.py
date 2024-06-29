cos = input ('wybierz plik:')
plik = open(cos, "r")
linie = plik.readlines()

linie_z_genami = [line for line in linie if not line.startswith('.')]

nazwa = cos.split('_')[0:2]

sciezka_do_pliku = input('Podaj nazwę pliku: ')

with open(sciezka_do_pliku, 'w') as plik:
    plik.writelines(linie_z_genami)