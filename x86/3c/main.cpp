#include <stdio.h>

extern "C" void modify_string(char *nts_buffer);

int main(void)
{
    char text[] = "W1nd 0n 7h3 f1ll";
    int result;

    printf("Input string      > %s\n", text);
    modify_string(text);
    printf("Conversion results> %s\n", text);
    return 0;
}
