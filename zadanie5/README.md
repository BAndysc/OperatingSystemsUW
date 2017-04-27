# Algorytmy szeregowania

Algorytm szeregowania MINIX-a faworyzuje procesy nastawione na wejście-wyjście (np. programy interakcyjne). Priorytet procesów obliczeniowych jest szybko obniżany, przez co system nie traci responsywności nawet wtedy, gdy dużo obliczeń odbywa się w tle. Jednak jeśli w systemie działa wiele procesów, które intensywnie korzystają z wejścia-wyjścia (np. wykonują operacje na dużej liczbie plików), to responsywność systemu obniża się.

#### Przykład

Wykonajmy pierwszy test na nieobciążonym systemie:

    # time grep size_t /usr/src/minix/servers/*/*c > /dev/null
       0.06 real       0.01 user       0.05 sys

Teraz obciążymy system 4 procesami:

    # grep -Rs size_t /usr/ > /dev/null &
    # grep -Rs size_t /usr/ > /dev/null &
    # grep -Rs size_t /usr/ > /dev/null &
    # grep -Rs size_t /usr/ > /dev/null &

I zobaczymy jak wpływa to na wynik:

    # time grep size_t /usr/src/minix/servers/*/*c > /dev/null
       0.41 real       0.01 user       0.06 sys

Widzimy wyraźne spowolnienie. Zauważmy, że czas `user`, czyli czas, jaki proces spędził na obliczeniach, jest bliski zeru. Oznacza to, że gdy program `grep` dostał już dane z dysku, to pozostałą pracę wykonał bardzo szybko.

Czas `sys` równy 0,05 s reprezentuje czas odczytu danych z dysku. Jest on najkosztowniejszą częścią wykonania polecenia. Całość zajęła jednak 0,41 s. Dlaczego `user + sys != real`? Ponieważ równocześnie wykonywało się kilka innych intensywnych procesów i przez część czasu obserwowany proces czekał.


### Opis wymagań - scenariusz

Celem zadania jest zaimplementowanie eksperymentalnej strategii szeregowania, która bierze pod uwagę nie tylko to, ile pracy wykonuje sam proces, ale również to, jak wpływa on na działanie innych procesów. 

Należy zmodyfikować domyślny serwer `sched` w taki sposób, aby ograniczał wykonywanie procesów zużywających dużo czasu systemowego. Nie wystarczy jednak obniżyć priorytet takich procesów, ponieważ przez większość czasu nie ma ich w kolejce procesów gotowych (są zablokowane na operacjach wejścia-wyjścia), ale należy dawać takim procesom mniej kwantów czasu.

Serwer powinien dla każdego procesu przechowywać pulę żetonów. Gdy proces wyczerpie kwant czasu, należy obliczyć czas systemowy zużyty od ostatniego sprawdzenia i odjąć jego wartość z puli żetonów. Może ona wtedy stać się ujemna. Nowy kwant serwer przydziela tylko wtedy, gdy pula jest dodatnia.

Przez żeton będziemy rozumieli jednostkę, w której naliczany jest czas systemowy. Dla każdego procesu jądro przechowuje wykorzystany czas systemowy na zmiennej `clock_t p_sys_time`.

Uzyskanie dobrej responsywności systemu będzie zależało od polityki uzupełniania puli żetonów przypisanych procesom. Nowy proces dostaje `MAX_TOKENS` żetonów w momencie uruchomienia (przykładowa wartość to 6, co jest odpowiednikiem 0,1 s czasu systemu), co da mu przewagę nad procesami działającymi od dawna. Chcemy ograniczyć ilość żetonów, jakie może zgromadzić każdy proces, aby zgromadzoną pulą nie był w stanie zdominować innych procesów. Za górne ograniczenie przyjmujemy również `MAX_TOKENS`.

Przydzielanie żetonów odbywa się zgodnie z poniższymi regułami:

  * Uzupełnianie robimy w momencie przydziału kwantu (w funkcji `do_noquantum()`) i co 5 s (w funkcji  `balance_queues()`).
  * Uzupełniamy żetony kolejnych procesów, zaczynając od procesu następnego względem tego, na którym ostatnio skończyliśmy.
  * Uzupełniamy pule procesu co najwyżej do maksymalnej wartości.
  * Kończymy, gdy wrócimy do procesu, od którego zaczęliśmy lub gdy wyczerpiemy nowe żetony.
  * Liczba nowych żetonów to czas jak minął od ostatniego uzupełnienia pomnożony przez stałą `SCHED_FACTOR` mniejszą od 1 (przykładowa wartość to 0,5).


Mnożenie nowych żetonów przez stałą jest potrzebne, aby w systemie nie było zbyt dużo żetonów. Gdyby żetonów było za dużo, to nowy proces musiałby czekać, pomimo że na starcie dostaje maksymalną pulę. Redukcja liczby przyznawanych żetonów rozwiązuje ten problem kosztem zmniejszenia przepustowości całego systemu. W rozwiązaniu produkcyjnym należałoby precyzyjnie dobrać lub dynamicznie zarządzać wartością `SCHED_FACTOR`.


#### Wskazówki

  * Przy obliczeniu czasu systemowego wykorzystanego przez proces a także czasu, jaki minął od czasu ostatniego sprawdzania, pomocna jest funkcja `sys_times()`.
  * Nie trzeba pisać nowego serwera. Wystarczy zmodyfikować domyślny serwer `sched`.
  * Wartości opisanych stałych są przykładowe. Zachęcamy do własnych eksperymentów.
  * Aby nowy algorytm szeregowania zaczął działać, należy wykonać `make; make install` w katalogu `/usr/src/minix/servers/sched`. Następnie trzeba zbudować nowy obraz jądra, czyli wykonać `make do-hdboot` w katalogu `/usr/src/releasetools` i zrestartować system. Gdyby obraz nie chciał się załadować (`kernel panic`), należy wybrać opcję 6 przy starcie systemu, która załaduje oryginalne jądro.
  * Przykładowy skrypt testujący `test0.sh` wykonuje testy podobne do opisanych wyżej. Należy go uruchomić na niezmienionym jądrze oraz na jądrze z nową implementacją algorytmu szeregowania.