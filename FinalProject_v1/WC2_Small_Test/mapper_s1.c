#include <iostream>

int main(int argv, char** argc, char** env)
{
	for(int i = 0; env[i] != NULL; i ++)
	{
		std::cout << env[i] <<std::endl;
	}
}

