#include <stdio.h>

void print_cell(unsigned int row, unsigned int col)
{
    unsigned int product = row * col;
    unsigned int padding;
    printf("%u*%u=%u", row, col, product);
    if (col < row) {
        padding = product < 10 ? 4U : 3U;
        while (padding > 0) {
            putchar(' ');
            --padding;
        }
    }
}

void print_table(void)
{
    unsigned int row;
    unsigned int col;
    puts("The 9mul9 table:");
    for (row = 9; row >= 1; --row) {
        for (col = 1; col <= row; ++col) {
            print_cell(row, col);
        }
        putchar('\n');
    }
}

int main(void)
{
    print_table();
    return 0;
}
