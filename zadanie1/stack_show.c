#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

extern void *__libc_stack_end;   // koniec stosu
extern char __executable_start;
extern char __etext;

#define CALL_SIZE 5
#define CALL_OPCODE 0xE8

#define GET_FUNCTION_OFFSET_FROM_INSTRUCTION(opcode) ((opcode >> 8) & 0xFFFFFFFF)

static inline bool is_in_executable_section(uint64_t data, int64_t startOffset)
{
    return data >= (uint64_t)&__executable_start + startOffset && data <= (uint64_t)&__etext;
}

static inline bool data_is_call_instruction(uint64_t instruction)
{
    return (instruction & 0xFF) == CALL_OPCODE;
}

extern void stack_show()
{
    register void* rsp asm ("rsp");
    void* stack_pointer = rsp;

    // gcc wyrównuje stos do 8 bajtów, więc możnaby skakać do 8 bajtów, ale
    // można wstawką assemblerową przesunąć rsp o dowolną ilość bajtów,
    // więc żeby na pewno wszystkie adresy powrotu znaleźć, to skaczemy co 1 bajt
    for (; stack_pointer < __libc_stack_end; stack_pointer += 1)
    {
        uint64_t value_at_memory = *(uint64_t*)stack_pointer; // wartość na stosie

        if (is_in_executable_section(value_at_memory, 5))
        {
            uint64_t* instruction_address = (uint64_t*)(value_at_memory - CALL_SIZE);
            uint64_t content_at_address = *instruction_address;
            if (data_is_call_instruction(content_at_address))
            {
                int32_t function_offset = GET_FUNCTION_OFFSET_FROM_INSTRUCTION(content_at_address);
                uint64_t function_address = value_at_memory + function_offset;
                if (is_in_executable_section(function_address, 0))
                    printf("%016lx\n", function_address);
            }
        }
    }
}
