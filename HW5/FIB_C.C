#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define LIMIT 100
#define WORDS 5

static uint16_t memo[LIMIT + 1][WORDS] = {{0}, {1}};
static unsigned char known[LIMIT + 1] = {1, 1};

static void fib(unsigned n)
{
    unsigned i;
    uint32_t carry = 0;
    if (known[n]) {
        return;
    }
    fib(n - 1);
    fib(n - 2);
    for (i = 0; i < WORDS; ++i) {
        uint32_t sum = (uint32_t)memo[n - 1][i] + memo[n - 2][i] + carry;
        memo[n][i] = (uint16_t)sum;
        carry = sum >> 16;
    }
    known[n] = 1;
}

static void print_decimal(const uint16_t value[WORDS])
{
    uint16_t work[WORDS];
    char digits[25];
    unsigned count = 0;
    unsigned nonzero;
    memcpy(work, value, sizeof work);
    do {
        uint32_t remainder = 0;
        int i;
        nonzero = 0;
        for (i = WORDS - 1; i >= 0; --i) {
            uint32_t word = (remainder << 16) | work[i];
            work[i] = (uint16_t)(word / 10);
            remainder = word % 10;
            nonzero |= work[i];
        }
        digits[count++] = (char)('0' + remainder);
    } while (nonzero);
    while (count) {
        putchar(digits[--count]);
    }
    putchar('\n');
}

static unsigned read_n(void)
{
    char line[128];
    for (;;) {
        size_t i, len;
        unsigned n = 0;
        fputs("Enter n (1-100): ", stdout);
        fflush(stdout);
        if (!fgets(line, sizeof line, stdin)) {
            return 0;
        }
        len = strcspn(line, "\n");
        if (line[len] == '\0' && !feof(stdin)) {
            int ch;
            do { ch = getchar(); } while (ch != '\n' && ch != EOF);
        } else if (len >= 1 && len <= 3) {
            for (i = 0; i < len; ++i) {
                if (line[i] < '0' || line[i] > '9') {
                    break;
                }
                n = n * 10 + (unsigned)(line[i] - '0');
            }
            if (i == len && n >= 1 && n <= LIMIT) {
                return n;
            }
        }
        puts("Invalid input. Enter an integer from 1 to 100.");
    }
}

int main(void)
{
    unsigned n = read_n();
    if (!n) {
        return 1;
    }
    fib(n);
    fputs("Result: ", stdout);
    print_decimal(memo[n]);
    return 0;
}
