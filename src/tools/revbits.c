/*
 * revbits.c - reverse order of bits in all bytes.
 *
 * Public domain.
 */

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define VERSION "0.0.1"

#define BUFSIZE 1024

#define NL "\n"

char *fni, *fno;
bool fio, foo;
FILE *fi, *fo;
char buf[BUFSIZE];

bool app_open (void)
{
    fio = false;
    foo = false;

    if (fni)
    {
        fi = fopen (fni, "r");
        fio = true;
    }
    else
    {
        fi = stdin;
        fio = false;
    }

    if (!fi)
    {
        perror ("open input");
        return false;
    }

    if (fno)
    {
        fo = fopen (fno, "w");
        foo = true;
    }
    else
    {
        fo = stdout;
        foo = false;
    }

    if (!fo)
    {
        perror ("open output");
        return false;
    }

    return true;
}

bool app_run (void)
{
    int n, i;
    char a, b, *p;

    while (!feof (fi))
    {
         n = fread (buf, 1, BUFSIZE, fi);
         if (n == 0)
         {
             perror ("read input");
             return false;
         }
         p = buf;
         i = n;
         while (i)
         {
             a = *p;
             b  = (a & 0b00000001) << 7;
             b |= (a & 0b00000010) << 5;
             b |= (a & 0b00000100) << 3;
             b |= (a & 0b00001000) << 1;
             b |= (a & 0b00010000) >> 1;
             b |= (a & 0b00100000) >> 3;
             b |= (a & 0b01000000) >> 5;
             b |= (a & 0b10000000) >> 7;
             *p = b;
             p++;
             i--;
         }
         if (!fwrite (buf, n, 1, fo))
         {
             perror ("write output");
             return false;
         }
    }

    return true;
}

void app_close (void)
{
    if (fio)
        fclose (fi);

    if (foo)
        fclose (fo);
}

void help (const char *s)
{
    fprintf (stderr,
        "Usage:" NL
        "    %s  [<infile> [<outfile>]]" NL
        NL
        "To use stdin and/or stdout as a file specify a '-' as a filename." NL
        "No filename has the same meaning." NL, s);
}

int main (int argc, char **argv)
{
    if (argc < 1 || argc > 3)
    {
        help (argv [0]);
        return 1;
    }

    if (2 <= argc)
    {
        fni = argv [1];
        if (strcmp (fni, "-") == 0)
            fni = NULL;
    }
    else
        fni = NULL;

    if (3 == argc)
    {
        fno = argv[2];
        if (strcmp (fno, "-") == 0)
            fno = NULL;
    }
    else
        fno = NULL;

    if (!app_open ())
    {
        app_close ();
        return 1;
    }

    if (!app_run ())
    {
        app_close ();
        return 1;
    }

    app_close ();
    return 0;
}
