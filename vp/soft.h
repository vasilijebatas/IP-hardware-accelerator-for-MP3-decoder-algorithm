#ifndef _SOFT_H_
#define _SOFT_H_

#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include <tlm>
#include <sysc/datatypes/fx/sc_fixed.h>
#include <iostream>
#include <string>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string.h>
#include <stdio.h>
#include <alsa/asoundlib.h> /* dnf install alsa-lib-devel */ /* apt install libasound2-dev */
#include <vector>
#include "id3.h"
#include "xing.h"
#include "util.h"
#include "tables.h"
#include "vp_addr.h"


#define ALSA_PCM_NEW_HW_PARAMS_API

#define PI    3.141592653589793
#define SQRT2 1.414213562373095

const sc_dt::uint64 READY = 0;
const sc_dt::uint64 START = 1;

using namespace sc_core;
using namespace sc_dt;
using namespace std;
using namespace tlm;

class Soft : public sc_core::sc_module
{
public:
	Soft(sc_core::sc_module_name, char** argv);

	tlm_utils::simple_initiator_socket<Soft> isoc_s;
	tlm_utils::simple_target_socket<Soft> tsoc;

	unsigned char out[2*2*576*sizeof(sc_fixed<32,16>)];

	

	enum ChannelMode {
		Stereo = 0,
		JointStereo = 1,
		DualChannel = 2,
		Mono = 3
	};
	enum Emphasis {
		None = 0,
		MS5015 = 1,
		Reserved = 2,
		CCITJ17 = 3
	};

 	void init_header_params(unsigned char *buffer);

	bool is_valid();

	float get_mpeg_version();
	unsigned get_layer();
	bool get_crc();
	unsigned get_bit_rate();
	unsigned get_sampling_rate();
	bool get_padding();
	ChannelMode get_channel_mode();
	unsigned *get_mode_extension();
	Emphasis get_emphasis();
	bool *get_info();

	float *get_samples();
	unsigned get_frame_size();
	unsigned get_header_size();


	

protected:
	sc_uint<2> ready;
	sc_uint<2> start;

	void software();
	vector<unsigned char> get_file(const char *dir);
	vector<id3> get_id3_tags(std::vector<unsigned char> &buffer, unsigned &offset);

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	void b_transport(pl_t&, sc_core::sc_time&);
	void msg(const pl_t&);

	char **input;
	vector<unsigned char> buf;
	unsigned offset;
	unsigned char *buffer;
	vector<id3> tags;

	bool valid;

	float mpeg_version;
	unsigned layer;
	bool crc;
	unsigned bit_rate;
	unsigned sampling_rate;
	bool padding;
	ChannelMode channel_mode;
	int channels;
	unsigned mode_extension[2];
	Emphasis emphasis;
	bool info[3];
	struct {
		const unsigned *long_win;
		const unsigned *short_win;
	} band_index;
	struct {
		const unsigned *long_win;
		const unsigned *short_win;
	} band_width;

	void set_mpeg_version();
	void set_layer(unsigned char byte);
	void set_crc();
	void set_bit_rate(unsigned char *buffer);
	void set_sampling_rate();
	void set_padding();
	void set_channel_mode(unsigned char *buffer);
	void set_mode_extension(unsigned char *buffer);
	void set_emphasis(unsigned char *buffer);
	void set_info();
	void set_tables();

	static const int num_prev_frames = 9;
	int prev_frame_size[9];
	int frame_size;

	int main_data_begin;
	bool scfsi[2][4];

	/* Allocate space for two granules and two channels. */
	int part2_3_length[2][2];
	int part2_length[2][2];
	int big_value[2][2];
	int global_gain[2][2];
	int scalefac_compress[2][2];
	int slen1[2][2];
	int slen2[2][2];
	bool window_switching[2][2];
	int block_type[2][2];
	bool mixed_block_flag[2][2];
	int switch_point_l[2][2];
	int switch_point_s[2][2];
	int table_select[2][2][3];
	int subblock_gain[2][2][3];
	int region0_count[2][2];
	int region1_count[2][2];
	int preflag[2][2];
	int scalefac_scale[2][2];
	int count1table_select[2][2];

	int scalefac_l[2][2][22];
	int scalefac_s[2][2][3][13];

	float fifo[2][1024];

	std::vector<unsigned char> main_data;
	sc_fixed<32,16> samples[2][2][576];
	float samples2[2][2][576];
	float pcm[576 * 4];

	void set_frame_size();
	void set_side_info(unsigned char *buffer);
	void set_main_data(unsigned char *buffer);
	void unpack_scalefac(unsigned char *bit_stream, int gr, int ch, int &bit);
	void unpack_samples(unsigned char *bit_stream, int gr, int ch, int bit, int max_bit);
	void requantize(int gr, int ch);
	void ms_stereo(int gr);
	void reorder(int gr, int ch);
	void alias_reduction(int gr, int ch);
	void imdct(int gr, int ch);
	void frequency_inversion(int gr, int ch);
	void synth_filterbank(int gr, int ch);
	void interleave();

};


#endif