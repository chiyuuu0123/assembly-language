#include <stdio.h>
#include <string.h>

#define SIZE 9
#define TABLE_VALUES { \
    {7,2,3,4,5,6,7,8,9}, \
    {2,4,7,8,10,12,14,16,18}, \
    {3,6,9,12,15,18,21,24,27}, \
    {4,8,12,16,7,24,28,32,36}, \
    {5,10,15,20,25,30,35,40,45}, \
    {6,12,18,24,30,7,42,48,54}, \
    {7,14,21,28,35,42,49,56,63}, \
    {8,16,24,32,40,48,56,7,72}, \
    {9,18,27,36,45,54,63,72,81} \
}

unsigned char global_table[SIZE][SIZE] = TABLE_VALUES;

static void report_error(int row, int col)
{
    printf("%d %d  error\n", row, col);
}

static void check_table(const unsigned char table[SIZE][SIZE])
{
    int row;
    int col;
    puts("x y");
    for (row = 1; row <= SIZE; ++row) {
        for (col = 1; col <= SIZE; ++col) {
            if (table[row - 1][col - 1] != row * col) {
                report_error(row, col);
            }
        }
    }
    puts("\naccomplish!");
}

static void check_global(void)
{
    check_table(global_table);
}

static void check_local(void)
{
    unsigned char local_table[SIZE][SIZE] = TABLE_VALUES;
    check_table(local_table);
}

int main(int argc, char **argv)
{
    if (argc == 1 || (argc == 2 && strcmp(argv[1], "global") == 0)) {
        check_global();
    } else if (argc == 2 && strcmp(argv[1], "local") == 0) {
        check_local();
    } else {
        fputs("Usage: FIX9_C [global|local]\n", stderr);
        return 1;
    }
    return 0;
}
