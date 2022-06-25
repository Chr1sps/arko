#include <stdio.h>
#include <float.h>

typedef struct
{
    int x, y;
} point;

int determinant(point *p, point *a, point *b)
{
    return (
        (p->x - b->x) * (a->y - b->y) -
        (a->x - b->x) * (p->y - b->y));
}

int eq_point(point *a, point *b)
{
    return (a->x == b->x && a->y == b->y);
}

float get_slope(point *a, point *b)
{
    int len_x = a->x - b->x, len_y = a->y - b->y;
    if (len_x == 0)
        return FLT_MAX;
    else if (len_y == 0)
        return 0;
    else
        return (float)len_x / (float)len_y;
}

int test_points(point *a, point *b, point *c)
{
    float slope_ab = get_slope(a, b), slope_bc = get_slope(b, c), slope_ca = get_slope(c, a);
    return !((eq_point(a, b) ||
              eq_point(b, c) ||
              eq_point(c, a)) ||
             (slope_ab == slope_bc ||
              slope_bc == slope_ca ||
              slope_ca == slope_ab));
}

void print_triangle(point *a, point *b, point *c)
{
    if (test_points(a, b, c))
    {
        for (int i = 0; i < 30; ++i)
        {
            for (int j = 0; j < 30; ++j)
            {
                point k = {j, i};
                int det_1 = determinant(&k, a, b), det_2 = determinant(&k, b, c), det_3 = determinant(&k, c, a), det_12 = det_1 * det_2, det_23 = det_2 * det_3, det_31 = det_3 * det_1;
                if (det_12 >= 0 && det_23 >= 0 && det_31 >= 0)
                    putchar('O');
                else
                    putchar('.');
            }
            putchar('\n');
        }
    }
}

void print_determinants(point *a, point *b, point *c, point *k)
{
    int det_1 = determinant(k, a, b), det_2 = determinant(k, b, c), det_3 = determinant(k, c, a);
    printf("%i = %X, %i = %X, %i = %X\n", det_1, det_1, det_2, det_2, det_3, det_3);
}

int main()
{
    point a = {50, 0}, b = {0, 200}, c = {200, 220};
    for (int i = 0; i < 4; ++i)
    {
        point k = {0, i};
        print_determinants(&a, &b, &c, &k);
    }
    // print_triangle(&a, &b, &c);
    getchar();
    return 0;
}