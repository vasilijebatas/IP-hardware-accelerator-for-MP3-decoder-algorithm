
#include <sysc/datatypes/fx/sc_fixed.h>
#include <systemc>
#include <iomanip>
#include <fstream>
#include <stdio.h>
#include <alsa/asoundlib.h> /* dnf install alsa-lib-devel */ /* apt install libasound2-dev */
#include <vector>
#include "id3.h"
#include "mp3.h"
#include "xing.h"

#define ALSA_PCM_NEW_HW_PARAMS_API

using namespace std;
using namespace sc_dt;




std::vector<unsigned char> get_file(const char *dir)
{
	std::ifstream file(dir, std::ios::in | std::ios::binary | std::ios::ate);
	std::vector<unsigned char> buffer(file.tellg());
	file.seekg(0, std::ios::beg);
	file.read((char *)buffer.data(), buffer.size());
	file.close();
	return std::move(buffer);
}

std::vector<id3> get_id3_tags(std::vector<unsigned char> &buffer, unsigned &offset)
{
	std::vector<id3> tags;
	int i = 0;
	bool valid = true;

	while (valid) {
		id3 tag(&buffer[offset]);
		if (valid = tag.is_valid()) {
			tags.push_back(tag);
			offset += tags[i++].get_id3_offset() + 10;
		}
	}

	return tags;
}

int sc_main(int argc, char **argv)
{


		std::vector<unsigned char> buffer = get_file(argv[1]);
		unsigned offset = 0;
		std::vector<id3> tags = get_id3_tags(buffer, offset);
		mp3 decoder(&buffer[offset]);
		decoder.stream(buffer, offset);
		


	return 0;
}
