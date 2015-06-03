#include <iostream>
#include <fstream>
#include <string>

int main(int argv, char* argc[])
{
    std::string objective_good(argc[1]);

    std::string value_shop;
    std::string value_good;
    int key_number;
    while( 
               std::cin >> value_good 
            && std::cin >> value_shop 
            && std::cin >> key_number
    )
    {
        if( objective_good == value_good )
        {
            std::cout << key_number << '\t' << value_shop << '\t' << value_good << std::endl;
        }
    }
    
}
