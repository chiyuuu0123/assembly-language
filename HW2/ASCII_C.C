#include <stdio.h>

void print_ascii(void)
{
    int row;
    int col;
    int ch = 'a';

    for (row = 0; row < 2; ++row) {
        for (col = 0; col < 13; ++col) {
            putchar(ch);
            ++ch;
            if (col < 12) {
                putchar(' ');
            }
        }
        putchar('\n');
    }
}

int main(void)
{
    print_ascii();
    return 0;
}
