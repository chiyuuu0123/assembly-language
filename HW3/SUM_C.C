#include <stdio.h>
#include <string.h>

unsigned int sum_to_n(unsigned int n)
{
    unsigned int total = 0;
    unsigned int i;
    for (i = 1; i <= n; ++i) {
        total += i;
    }
    return total;
}

int parse_n(const char *text, unsigned int *value)
{
    unsigned int n = 0;
    unsigned int count = 0;
    while (text[count] != '\0' && text[count] != '\r' && text[count] != '\n') {
        if (count == 3 || text[count] < '0' || text[count] > '9') {
            return 0;
        }
        n = n * 10 + (unsigned int)(text[count] - '0');
        ++count;
    }
    if (count == 0 || n < 1 || n > 100) {
        return 0;
    }
    if (text[count] == '\r') {
        ++count;
    }
    if (text[count] == '\n') {
        ++count;
    }
    if (text[count] != '\0') {
        return 0;
    }
    *value = n;
    return 1;
}

int main(void)
{
    char line[128];
    unsigned int n;
    int ch;

    printf("1 + ... + 100 = %u\n", sum_to_n(100));
    for (;;) {
        fputs("Enter n (1-100): ", stdout);
        if (fgets(line, sizeof line, stdin) == NULL) {
            return 1;
        }
        if (strchr(line, '\n') == NULL && !feof(stdin)) {
            while ((ch = getchar()) != '\n' && ch != EOF) {
                /* Discard the rest of an overlong line. */
            }
            puts("Invalid input. Enter an integer from 1 to 100.");
            continue;
        }
        if (parse_n(line, &n)) {
            break;
        }
        puts("Invalid input. Enter an integer from 1 to 100.");
    }
    printf("Result: %u\n", sum_to_n(n));
    return 0;
}
