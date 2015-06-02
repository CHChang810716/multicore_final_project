#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <cstdlib>
typedef std::pair<std::string, std::string> StrPair;
int main(int argv, char** argc)
{
    const int first_n_result(3);
    std::map<int, StrPair> result;
    std::string key;
    std::string value1;
    std::string value2;
    while(std::cin >> key >> value1 >> value2)
    {
        result[atoi(key.c_str())] = StrPair(value1, value2);
    }
    int count (0);
    for(std::map<int, StrPair>::reverse_iterator rit (result.rbegin()); rit != result.rend() && count < 3; ++rit, ++count)
    {
        std::cout 
            << rit->first 
            << '\t'
            << rit->second.first 
            << '\t'
            << rit->second.second 
            << std::endl;
        //count ++;
    }
}
    
