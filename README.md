## What is it?
Hash join of two text files

## Which is hash used here?
It is uses SHA3-224

## How is it get?

	git clone https://github.com/progman/hashjoin.git

## How is it make?

	git submodule update --init && make x64 && ./test.sh

## How is it use?

	$ cat TEXT_FILE1
	1
	2
	2
	3

	$ cat TEXT_FILE2
	5
	6
	2

	$ hashjoin == TEXT_FILE1 TEXT_FILE2
	2
	2

	$ hashjoin == TEXT_FILE2 TEXT_FILE1
	2

	$ hashjoin != TEXT_FILE1 TEXT_FILE2
	1
	3

	$ hashjoin != TEXT_FILE2 TEXT_FILE1
	5
	6

	$ hashjoin diff TEXT_FILE1 TEXT_FILE2
	-1
	-3
	+5
	+6

	$ hashjoin diff TEXT_FILE2 TEXT_FILE1
	-5
	-6
	+1
	+3
