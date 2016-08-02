//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// 0.0.4
// Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
#include <fcntl.h>
#include <list>
#include <set>
#include <stdint.h>
#include <stdio.h>
#include <string>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "sha3_224.hpp"
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// global namespace
namespace global
{
	struct hash_item_t
	{
		std::string line;
		std::string hash;

		hash_item_t(const std::string &line, const std::string &hash)
		{
			this->line.reserve(line.size());
			this->hash.reserve(sizeof(sha3_224_t::sha3_224_item_t));

			this->line = line;
			this->hash = hash;
		}
	};
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// search line and create hash
int buffer2hash_list(const uint8_t *p, uint64_t size, std::list<global::hash_item_t> &hash_list)
{
	sha3_224_t sha3_224;
	sha3_224_t::sha3_224_item_t sha3_224_item;
	std::string line;
	std::string hash;
	const uint8_t *pstart = NULL;
	bool flag_open = false;


	for (uint64_t i=0; i < size; i++, p++)
	{
		uint8_t ch = *p;

		if (ch == '\n')
		{
			if (flag_open == true)
			{
				flag_open = false;

				line.append((const char *)pstart, p - pstart);
				sha3_224.update(pstart, p - pstart);
				sha3_224.close();
				hash = std::string((const char *)sha3_224_item, sizeof(sha3_224_item));
				hash_list.push_back(global::hash_item_t(line, hash));
			}
			continue;
		}

		if (flag_open == false)
		{
			pstart = p;
			line.clear();
			hash.clear();
			sha3_224.open(&sha3_224_item);
			flag_open = true;
		}
	}


	if (flag_open == true)
	{
		line.append((const char *)pstart, p - pstart);
		sha3_224.update(pstart, p - pstart);
		sha3_224.close();
		hash = std::string((const char *)sha3_224_item, sizeof(sha3_224_item));
		hash_list.push_back(global::hash_item_t(line, hash));
	}


	return 0;
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// read file and search line and create hash
int file2hash_list(const char *pfilename, std::list<global::hash_item_t> &hash_list)
{
	int rc;


// open file
	rc = open(pfilename, O_LARGEFILE | O_RDONLY);
	if (rc == -1)
	{
		printf("ERROR[open()]: %s\n", strerror(errno));
		return -1;
	}
	int fd = rc;


// get file size
	struct stat stat_buf;
	rc = fstat(fd, &stat_buf);
	if (rc == -1)
	{
		printf("ERROR[fstat()]: %s\n", strerror(errno));
		close(fd);
		return -1;
	}
	uint64_t size = stat_buf.st_size;


// mmap file
	void *pmmap_void = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (pmmap_void == MAP_FAILED)
	{
		printf("ERROR[mmap()]: %s\n", strerror(errno));
		close(fd);
		return -1;
	}


// search line and create hash
	rc = buffer2hash_list((uint8_t *)pmmap_void, size, hash_list);
	if (rc == -1)
	{
		munmap(pmmap_void, size);
		close(fd);
		return -1;
	}


// munmap file
	rc = munmap(pmmap_void, size);
	if (rc == -1)
	{
		printf("ERROR[munmap()]: %s\n", strerror(errno));
		close(fd);
		return -1;
	}


// close file
	rc = close(fd);
	if (rc == -1)
	{
		printf("ERROR[close()]: %s\n", strerror(errno));
		return -1;
	}


	return 0;
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// open sql stat
int do_it(const char *pfilename1, const char *pfilename2, bool flag_equal, bool flag_diff)
{
	int rc;
	std::list<global::hash_item_t> hash_list1;
	std::list<global::hash_item_t> hash_list2;
	std::set<std::string> hash_set1;
	std::set<std::string> hash_set2;


	if (flag_diff == false)
	{
// get hash_set2
		rc = file2hash_list(pfilename2, hash_list2);
		if (rc == -1) return 1;

		for (std::list<global::hash_item_t>::const_iterator i=hash_list2.begin(); i != hash_list2.end(); ++i)
		{
			hash_set2.insert((*i).hash);
		}
		hash_list2.clear();


// get hash_list1 and compare with hash_set2
		rc = file2hash_list(pfilename1, hash_list1);
		if (rc == -1) return 1;

		for (std::list<global::hash_item_t>::const_iterator i=hash_list1.begin(); i != hash_list1.end(); ++i)
		{
			if (hash_set2.find((*i).hash) != hash_set2.end())
			{
				if (flag_equal != false)
				{
					printf("%s\n", (*i).line.c_str());
				}
			}
			else
			{
				if (flag_equal == false)
				{
					printf("%s\n", (*i).line.c_str());
				}
			}
		}

		hash_set2.clear();
		hash_list1.clear();

		return 0;
	}


	rc = file2hash_list(pfilename1, hash_list1);
	if (rc == -1) return 1;
	for (std::list<global::hash_item_t>::const_iterator i=hash_list1.begin(); i != hash_list1.end(); ++i)
	{
		hash_set1.insert((*i).hash);
	}


	rc = file2hash_list(pfilename2, hash_list2);
	if (rc == -1) return 1;
	for (std::list<global::hash_item_t>::const_iterator i=hash_list2.begin(); i != hash_list2.end(); ++i)
	{
		hash_set2.insert((*i).hash);
	}


	for (std::list<global::hash_item_t>::const_iterator i=hash_list1.begin(); i != hash_list1.end(); ++i)
	{
		if (hash_set2.find((*i).hash) == hash_set2.end())
		{
			printf("-%s\n", (*i).line.c_str());
		}
	}


	for (std::list<global::hash_item_t>::const_iterator i=hash_list2.begin(); i != hash_list2.end(); ++i)
	{
		if (hash_set1.find((*i).hash) == hash_set1.end())
		{
			printf("+%s\n", (*i).line.c_str());
		}
	}


	hash_list1.clear();
	hash_list2.clear();
	hash_set1.clear();
	hash_set2.clear();


	return 0;
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// view help
void help()
{
	printf("%s    %s\n", PROG_FULL_NAME, PROG_URL);
	printf("example: %s [ == | != | diff ] TEXT_FILE1 TEXT_FILE2\n", PROG_NAME);
	printf("\n");

	printf("hash join of two text files\n");
	printf("\n");

	printf("  -h, -help, --help this message\n");
	printf("  ==                line from TEXT_FILE1 exist in TEXT_FILE2\n");
	printf("  !=                line from TEXT_FILE1 not exist in TEXT_FILE2\n");
	printf("  diff              show TEXT_FILE1 != TEXT_FILE2 and TEXT_FILE2 != TEXT_FILE1\n");
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
// general function
int main(int argc, char *argv[])
{
	int rc;
	const char *pfilename1 = NULL;
	const char *pfilename2 = NULL;
	bool flag_equal = true;
	bool flag_diff  = false;


	if (argc != 4)
	{
		help();
		return 1;
	}


// parse command line args
	for (int i=1; i < argc; i++)
	{
		if ((strcmp(argv[i], "--help") == 0) || (strcmp(argv[i], "-help") == 0) || (strcmp(argv[i], "-h") == 0))
		{
			help();
			return 0;
		}

		if (strcmp(argv[i], "==") == 0)
		{
			flag_equal = true;
			continue;
		}

		if (strcmp(argv[i], "!=") == 0)
		{
			flag_equal = false;
			continue;
		}

		if (strcmp(argv[i], "=!") == 0)
		{
			flag_equal = false;
			continue;
		}

		if (strcmp(argv[i], "diff") == 0)
		{
			flag_diff = true;
			continue;
		}

		if (pfilename1 == NULL)
		{
			pfilename1 = argv[i];
			continue;
		}
		else
		{
			pfilename2 = argv[i];
			continue;
		}
	}
	if ((pfilename1 == NULL) || (pfilename2 == NULL))
	{
		help();
		return 1;
	}


	rc = do_it(pfilename1, pfilename2, flag_equal, flag_diff);
	if (rc == -1) return 1;
	fflush(stdout);


	return 0;
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
