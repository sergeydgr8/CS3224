// Created by Dylan Perera and Sergey Smirnov.

#include "types.h"
#include "user.h"
#include "stat.h"

char buffer[512];

void head(int file, char *name, int numlines)
{
    int i, j; // iterators
    int file_read;
    int currentpos = 0;
    int line_count = 0;

    while ((file_read = read(file, buffer, sizeof(buffer))) > 0)
    {
        for (i = 0; i <= file_read; i++)
        {
            if (buffer[i] == '\n')
            {
                line_count++;
                if (line_count > numlines)
                    break;
                else
                {
                	for (j = currentpos; j < i; j++)
                    	printf(1, "%c", buffer[j]);
                	currentpos = i;
            	}
            }
        }
    }
    printf (1, "\n");
    exit();
}

int main(int argc, char *argv[])
{
    int file_directory;

    if (argc <= 1)
    {
        head(0, "", 10);
        exit();
    }

    else if (argc == 3)
    {
        if ((file_directory = open(argv[2], 0)) < 0)
        {
            printf (1, "head: cannot open %s\n", argv[2]);
            exit();
        }

        int value = atoi(argv[1] + 1);
        head(file_directory, argv[3], value);
        close(file_directory);
    }

    else if (argc == 2)
    {
        if ((file_directory = open(argv[1], 0)) < 0)
        {
            printf (1, "head: cannot open %s\n", argv[1]);
            exit();
        }

        head(file_directory, argv[1], 10);
        close(file_directory);
    }

    else // for now...
    {
        printf (1, "head: Too many arguments! You entered %d of them.\n", argc);
        exit();
    }

    exit();
}
        


