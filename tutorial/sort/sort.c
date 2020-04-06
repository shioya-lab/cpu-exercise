#include <stdio.h>

short array[ 4096 ];

void sort( int size )
{
	int i;
	for( i = 0; i < size; i++ ){
	}
}

int main( int argc, char* argv[] )
{
	int i;
	int size = 8;
	
	array[ 0 ] = 5;
	array[ 1 ] = 9;
	array[ 2 ] = 1;
	array[ 3 ] = 4;
	array[ 4 ] = 3;
	array[ 5 ] = 2;
	array[ 6 ] = 0;
	array[ 7 ] = 8;
	
	sort( size );
	
	for( i = 0; i < size; i++ ){
		printf( "%d\n", array[ i ] );
	}
	
	return 0;	
}


