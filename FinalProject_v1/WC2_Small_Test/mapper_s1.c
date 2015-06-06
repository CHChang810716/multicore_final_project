#include <stdio.h>
#include <string.h>

#define BUF_SIZE 1048576
#define DELIMITERS "=,;.()\"'/ \t"

int main(int argc, char ** argv, char ** env){

	char line[BUF_SIZE];
	int i;
	char** temp;
	char shop[6];
	for (temp = env; *temp != 0; temp++){
		char *envline = strtok(*temp, "=/");
		if (strcmp(envline, "map_input_file")) continue;
		while(envline != NULL){
			if (!strncmp(envline, "shop", 4)){
				strncpy(shop, envline, 5);
				shop[5] = '\0';
			}
			envline = strtok(NULL, "=/");
		}
	}
	
	while(fgets(line, BUF_SIZE - 1, stdin) != NULL){
		for(i = strlen(line); i >= 0; i--){
			if(line[i] == '\n' || line[i] == '\r'){
				line[i] = '\0';
			}
		}

		char * token = strtok(line, DELIMITERS);
		
		while(token != NULL){			
			printf("%s\t%s\t1\n", token, shop);
			token = strtok(NULL, DELIMITERS);
		}
	}
	
	return 0;
}

