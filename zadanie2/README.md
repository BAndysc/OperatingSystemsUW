# Semafor

Zaimplementuj w asemblerze x86-64 rozwiązanie (z drobnymi modyfikacjami) zadania o producencie i konsumencie z buforem cyklicznym omawianego na ćwiczeniach z PW. Wszystkie implementowane procedury powinny przestrzegać konwencji wołania funkcji w języku C. Rozwiązanie powinno składać się z dwóch plików.

Plik dijkstra_semaphore.asm ma zawierać implementację semafora według klasycznej definicji Dijkstry. Semafor S jest zmienną typu int32_t i można na nim wykonywać dwie operacje: proberen(&S) i verhogen(&S). Plik ten ma udostępniać te operacje jako dwie funkcje, które mają w C sygnatury:

    void proberen(int32_t *);
    void verhogen(int32_t *);

Wskazówka: użyj instrukcji xadd.

Plik producer_consumer.asm ma udostępniać trzy funkcje:

    int init(size_t N);
    void producer(void);
    void consumer(void);

Funkcja init alokuje bufor cykliczny dla N porcji danych typu int64_t oraz inicjuje semafory. Zwraca:
 * 0, gdy sukces;
 * -1, gdy N > 2^{31} - 1;
 * -2, gdy N = 0;
 * -3, gdy alokacja pamięci się nie powiodła.

Wskazówka: przy porównywaniu liczb ze znakiem korzysta się z instrukcji je, jg, jge, jl, jle, jne, jng, jnge, jnl, jnle, a przy porównywaniu liczb bez znaku – je, ja, jae, jb, jbe, jne, jna, jnae, jnb, jnbe.

Wskazówka: o alokowaniu pamięci w programie asemblerowym można poczytać tu http://x86asm.net/articles/memory-allocation-in-linux. Program będzie linkowany ze standardową biblioteką języka C.

Wskazówka: zmienne globalne inicjowane w trakcie wykonywania programu umieszcza się w sekcji .bss.

Funkcja producer realizuje protokół producenta. Aby wyprodukować porcję danych P, woła funkcję produce(&P) o sygnaturze

    int produce(int64_t *);

Funkcja produce zwraca 1, gdy wyprodukowała porcję danych, a 0, gdy nie wyprodukowała danych i wtedy funkcja producer powinna się zakończyć.

Funkcja consumer realizuje protokół konsumenta. Aby skonsumować porcję danych P, woła funkcję consume(P) o sygnaturze

    int consume(int64_t);

Funkcja consume zwraca 1, gdy oczekuje kolejnych danych, a 0, gdy otrzymana porcja danych jest ostatnią oczekiwaną i wtedy funkcja consumer powinna się zakończyć.

Wskazówka: w asemblerze identyfikatory wołanych funkcji, które są zaimplementowane w innych jednostkach translacji, należy zadeklarować jako extern.
