# Show stack

Zaimplementuj funkcję o sygnaturze

    void stack_show();

Zadaniem tej funkcji jest przeanalizowanie stosu i wypisanie szesnastkowo adresów funkcji, które zostały wywołane. Adresy należy wypisywać w kolejności odwrotnej do kolejności wołania funkcji. Przykładowy wydruk

    00000000004006f0
    00000000004007b0
    0000000000400830
    00000000004007b0

oznacza, że funkcja main wywołała funkcję o adresie 00000000004007b0. Ta funkcja wywołała funkcję o adresie 0000000000400830. Następnie ponownie została wywołana funkcja o adresie 00000000004007b0 i ta funkcja wywołała funkcję stack_show, która ma adres 00000000004006f0.

Zakładamy, że wołania funkcji odbywają się za pomocą instrukcji call rel32, gdzie rel32 jest 32-bitowym względnym adresem wołanej funkcji. Bezwzględny adres wołanej funkcji to suma adresu powrotu (adresu następnej instrukcji po instrukcji call) i rozszerzonego do 64 bitów ze znakiem adresu względnego. Kod maszynowy tej wersji instrukcji call składa się z opkodu e8 i czterobajtowego adresu względnego.

### Dodatkowe wyjaśnienia (7 marca 2017)

 * Nie wolno korzystać z funkcji backtrace() lub tp.
 * Nie wolno korzystać z __builtin_return_address(), __builtin_frame_address() lub tp.
 * Wszystkie wywołania odbywają się za pomocą instrukcji call o opkodzie e8.
 * Nie będzie żadnych trików, w których wywołujemy bibliotekę i ta biblioteka woła naszą funkcję lub tp.
 * Adres końca stosu można dostać za pomocą zmiennej:

    extern void *__libc_stack_end;

 * Analizowany kod wykonywalny jest ograniczony zmiennymi zadeklarowanymi w skrypcie linkera:

    // Pierwszy bajt, gdzie może znajdować się kod wykonywalny.
    extern uint8_t __executable_start;

    // Pierwszy bajt, gdzie już nie może znajdować się kod wykonywalny.
    extern uint8_t __etext;




