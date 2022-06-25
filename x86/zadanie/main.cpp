#include <stdio.h>

extern "C" int modify_string(char *nts_buffer);

int main(void)
{
    char text[] = "CCCComppuuuter Arrrrrchitecturrrrre Labbbbbb"; // result = 19
    char text2[] = "Unique signs.";                               // result = 0
    char text3[] = "";                                            // result = 0
    char text4[] = "AAAAA";                                       // result = 4
    char *texts[] = {text, text2, text3, text4};
    int result;

    for (int i = 0; i < 4; ++i)
    {
        printf("Input string      > %s\n", texts[i]);
        result = modify_string(texts[i]);
        printf("Return value      > %d\n", result);
        printf("Conversion results> %s\n\n", texts[i]);
    }
    return 0;
}
