#include <iostream>
int main(int argv, char* argc[])
{
    for ( int i = 0; i < argv; i++ )
        std::cout << argc[i] << std::endl;
}
