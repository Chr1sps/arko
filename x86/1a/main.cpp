#include <stdio.h>

extern "C" int modify_string(char *nts_buffer);

int main(void)
{
    char text[] = "Wind On The fill";
    int result;

    printf("Input string      > %s\n", text);
    result = modify_string(text);
    printf("Return value      > %d\n", result);
    printf("Conversion results> %s\n", text);
    return 0;
}
