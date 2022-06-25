#include <stdio.h>

extern int modify_string(char *nts_buffer);

int main(void)
{
    char text[] = "W1nd 0n 7h3 f1ll";
    int result;

    printf("Input string      > %s\n", text);
    result = modify_string(text);
    printf("Return value      > %d\n", result);
    printf("Conversion results> %s\n", text);
    return 0;
}
