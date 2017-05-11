# Sterowniki

Biorąc za punkt wyjścia sterownik urządzenia `/dev/hello` (patrz katalog `/usr/src/minix/drivers/examples/hello`), zaimplementuj sterownik urządzenia `/dev/helloN` działający zgodnie z poniższą specyfikacją.

### Opis wymagań - scenariusz

Urządzenie ma dysponować buforem o pojemności `DEVICE_SIZE` bajtów. Stała ta jest zdefiniowana w dostarczanym przez nas pliku nagłówkowym `helloN.h`.

Po uruchomieniu sterownika poleceniem 'service up ...' wszystkie elementy bufora mają zostać wypełnione kodem ASCII litery a.

Czytanie z urządzenia za pomocą funkcji `read` ma powodować odczytanie wskazanej liczby bajtów, począwszy od aktualnego wskaźnika położenia w pliku (patrz funkcja `lseek`). O ile w wyniku tej operacji nastąpiłoby przekroczenie pojemności urządzenia, liczba wczytanych bajtów ma zostać odpowiednio zredukowana.

Analogicznie ma działać operacja pisania do urządzenia za pomocą funkcji write. W buforze ma zostać zapisany wskazany ciąg bajtów, począwszy od aktualnego wskaźnika położenia w pliku, nie więcej jednak niż do końca bufora.

Ponadto urządzenie powinno zachowywać aktualny stan w przypadku przeprowadzenia jego aktualizacji poleceniem `service update`.

Sterownik będzie kompilowany za pomocą dostarczonego przez nas Makefile, analogicznego jak dla przykładowego sterownika hello. Plik z rozwiązaniem `helloN.c` oraz dostarczone przez nas pliki `helloN.h` i Makefile zostaną umieszczone w katalogu `/usr/src/minix/drivers/examples/helloN`, gdzie będą wykonywane polecenia:

    make clean
    make
    make install
    
    service up /service/helloN
    service update /service/helloN
    service down helloN

Testy będą polegały na wykonywaniu operacji `open`, `read`, `write`, `lseek` i `close` na urządzeniu `/dev/helloN`. Urządzenie to zostanie utworzone przez skrypt testujący, a w pliku `/etc/system.conf` zostanie dla niego utworzony analogiczny wpis jak dla urządzenia `/dev/hello`.
