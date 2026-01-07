#include "stdio.h"

#include "math.h"

int main()
{
	double number1, number2;
    double result;
    int counter;

    number1 = 1.0;
    number2 = 1.0;
    counter = 0;

    while(number1 + number2 != number1)
    {
        counter++;
        number2 = number2 /10.0;
    }
    printf("%2d digits accuracy in calculations\n", counter);

    number2 = 1.0;
    counter = 0;

    while(1)
    {
        result = number1 + number2;
        if(result == number1)
            break;
        counter++;
        number2 = number2/10.0;
        printf("number2  = %.16f\n",  number2);
    }
    printf("%2d digits accuracy in storage\n", counter);

    return 0;

}

