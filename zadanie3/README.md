# Własny bootloader

Zadanie polega na przygotowaniu obrazu dysku z systemem MINIX 3.3 (minix.img), za pomocą którego będzie możliwe odtworzenie poniższego scenariusza.

### Opis wymagań - scenariusz

Uruchamiamy program qemu z przygotowanym obrazem:

$ qemu-system-x86_64 -curses -drive file=minix.img -enable-kvm -localtime -net user -net nic,model=virtio -m 1024M

Zanim zostanie uruchomiony bootloader:

1. Na ekranie maszyny wyświetla się napis "Enter your name\r\n".
2. Użytkownik wpisuje imię ($name).
  * Zakładamy, że klawiatura użytkownika jest ograniczona do symboli alfabetu łacińskiego ([a-z]), symbolu backspace (0x08) oraz enter (0x0d).
  * Wartością $name powinien być ciąg znaków alfabetu łacińskiego ([a-z]).
  * Użytkownik zatwierdza wpisane imię za pomocą entera.
  * Symbol backspace w przypadku $name o niezerowej długości oznacza usunięcie ostatniego znaku (kursor zostaje przesunięty w lewo).
  * Użytkownik nie może wpisać imienia o długości większej niż 12 znaków.
  * Dopóki imię wprowadzone przez użytkownika ma mniej niż 3 znaki, nie może zostać zaakceptowane.
  * Na ekranie wyświetlana jest aktualna wersja imienia, którą wpisuje użytkownik.
3. Po zaakceptowaniu imienia na ekranie maszyny wyświetla się napis "Hello $name\r\n".
4. Po upływie 2 sekund zostaje uruchomiony oryginalny bootloader (z oryginalnego obrazu MINIX-a).

Tuż po zalogowaniu się jako użytkownik root:

5. Automatycznie tworzony jest użytkownik o nazwie $name w grupie 'users'.
6. Automatycznie użytkownik root zostaje zalogowany na konto użytkownika $name.
