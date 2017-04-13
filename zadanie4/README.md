# Wywołania systemowe

Zadanie polega na dodaniu nowego wywołania systemowego

    int myps(int uid);

do serwera PM (Process Manager).

### Opis wymagań - scenariusz

Funkcja `myps(uid)` wypisuje na standardowe wyjście
 * pid
 * ppid (parent pid)
 * uid

wszystkich procesów należących do użytkownika o podanym uid. Jeśli jako uid podajemy 0, to funkcja wypisuje informacje dotyczące procesów użytkownika wołającego funkcję. W ten sposób zwykły użytkownik nie będzie mógł obejrzeć procesów należących do użytkownika root(uid=0).

> Wskazówka: serwer PM przechowuje informacje o procesach w tablicy `mproc` zadeklarowanej w pliku `mproc.h`.

Funkcja `myps()` przekazuje w wyniku 0, jeśli nie wystąpił błąd. W przypadku błędu funkcja zwraca -1. Sytuacji, w której wywołamy funkcję, podając uid nieistniejącego użytkownika, nie traktujemy jako błąd. Przy takim wywołaniu nie powinny zostać wypisane żadne procesy.

W rozwiązaniu na końcu każdego dodanego lub zmienionego wiersza w istniejących plikach źródłowych należy dodać komentarz

    /* SO-TASK-4 */

lub

    # SO-TASK-4

zależnie od typu pliku.

Rozwiązanie powinno zawierać skrypt `myps.sh`, który uruchomiony na MINIX-ie skompiluje i zainstaluje wszystkie potrzebne pliki, zakładając, że wszystkie pliki źródłowe rozwiązania zostały umieszczone we wspólnym katalogu lub jegopodkatalogach. Przykładowo, kopiujemy rekurencyjnie wszystkie pliki z hosta z katalogu zadanie4 i jego podkatalogów do katalogu `/root/zadanie4` na MINIX-ie, logujemy się na MINIX-ie, wchodzimy do katalogu `/root/zadanie4` i uruchamiamy skrypt `myps.sh`.

Proszę przetestować swoje rozwiązanie dla różnych parametrów i różnych użytkowników. Poprawność wywołania można sprawdzić, porównując swoje wyniki z wynikiem polecenia

    $ ps lx