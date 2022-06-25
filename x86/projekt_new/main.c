#include <stdio.h>
#include <stdlib.h>
#include "image.h"
#define DEBUG 1
#define TRUE 1
#define FALSE 0
#define MAX_INTENSITY 255
#define WIDTH 320
#define HEIGHT 240

typedef struct
{
    uint32_t rgb;
    uint16_t x, y; // +4, +6
} vertex;

extern void draw_triangle(ImageInfo *info, vertex *a, vertex *b, vertex *c);

int scan_check_shift(uint32_t *rgb, int shift)
{
    uint32_t temp;
    scanf("%u", &temp);
    if (temp > MAX_INTENSITY)
        return FALSE;
    *rgb |= temp;
    if (shift)
        *rgb <<= 8;
    return TRUE;
}

int determinant(vertex a, vertex b, vertex c)
{
    return (a.x - c.x) * (b.y - c.y) - (b.x - c.x) * (a.y - c.y);
}

int main()
{
    vertex va, vb, vc;                     // vertices
    vertex *vertices[3] = {&va, &vb, &vc}; // pointers made into a table
    uint32_t rgb = 0;                      // temporary rgb variable integer
    ImageInfo *info = malloc(3 * sizeof(int));
    *info = (ImageInfo){
        320,                                    // info.width
        240,                                    // info.height
        (unsigned char *)malloc(320 * 240 * 3), // info.pImg
    };
    if (DEBUG)
    {
        va = (vertex){0x00FFFF00, 159, 0};
        vb = (vertex){0x00FF00FF, 319, 239};
        vc = (vertex){0x0000FFFF, 0, 239};
    }
    else
    {
        printf("Input coords.\n");
        for (int i = 0; i < 3; ++i)
        {
            printf("%c\nx: ", (char)('A' + i));
            scanf("%hu", &(vertices[i]->x));
            if (vertices[i]->x > WIDTH - 1)
                return -1;

            printf("y: ");
            scanf("%hu", &(vertices[i]->y));
            if (vertices[i]->y > HEIGHT - 1)
                return -1;
        }

        if (!determinant(va, vb, vc))
        {
            return -1;
        }

        printf("Input RGB values.\n");
        for (int i = 0; i < 3; ++i)
        {
            rgb = 0;

            printf("%c\nr: ", (char)('A' + i));
            if (scan_check_shift(&rgb, TRUE) == FALSE)
                return -1;

            printf("g: ");
            if (scan_check_shift(&rgb, TRUE) == FALSE)
                return -1;

            printf("b: ");
            if (scan_check_shift(&rgb, FALSE) == FALSE)
                return -1;

            vertices[i]->rgb = rgb;
        }
    }
    draw_triangle(info, vertices[0], vertices[1], vertices[2]);
    saveBmp("shading.bmp", info);
    if (DEBUG)
    {
        for (int i = 0; i < 3; ++i)
        {
            printf("%c -> rgb: %06X  x: %3u  y: %3u\n", (char)('A' + i), vertices[i]->rgb, (unsigned int)(vertices[i]->x), (unsigned int)(vertices[i]->y));
        }
    }
    freeImage(info);
    return 0;
}
