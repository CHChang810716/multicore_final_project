#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <map>
#include <cstdlib>
typedef std::pair<std::string, std::string> StrPair;
int main(int argv, char** argc)
{
    const int first_n_result(3);
    std::map<int, std::vector<StrPair> > result;
    std::string key;
    std::string value1;
    std::string value2;
    while(std::cin >> key >> value1 >> value2)
    {
        result[atoi(key.c_str())].push_back( StrPair(value1, value2));
    }
    int count (0);
    for(std::map<int, std::vector<StrPair> >::reverse_iterator rit (result.rbegin()); rit != result.rend() && count < 3; ++rit)
    {
	for(std::vector<StrPair>::iterator vit(rit->second.begin()); vit != rit->second.end() && count < 3; ++vit, ++count)
		std::cout 
			<< rit->first 
			<< '\t'
			<< vit->first 
			<< '\t'
			<< vit->second 
			<< std::endl;
        //count ++;
    }
}
    
