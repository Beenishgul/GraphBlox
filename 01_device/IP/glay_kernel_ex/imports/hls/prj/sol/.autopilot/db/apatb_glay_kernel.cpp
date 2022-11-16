#include <systemc>
#include <iostream>
#include <cstdlib>
#include <cstddef>
#include <stdint.h>
#include "SysCFileHandler.h"
#include "ap_int.h"
#include "ap_fixed.h"
#include <complex>
#include <stdbool.h>
#include "autopilot_cbe.h"
#include "hls_stream.h"
#include "hls_half.h"
#include "hls_signal_handler.h"

using namespace std;
using namespace sc_core;
using namespace sc_dt;

// wrapc file define:
#define AUTOTB_TVIN_graph_csr_struct "../tv/cdatafile/c.glay_kernel.autotvin_graph_csr_struct.dat"
#define AUTOTB_TVOUT_graph_csr_struct "../tv/cdatafile/c.glay_kernel.autotvout_graph_csr_struct.dat"
#define AUTOTB_TVIN_vertex_out_degree "../tv/cdatafile/c.glay_kernel.autotvin_vertex_out_degree.dat"
#define AUTOTB_TVOUT_vertex_out_degree "../tv/cdatafile/c.glay_kernel.autotvout_vertex_out_degree.dat"
#define AUTOTB_TVIN_vertex_in_degree "../tv/cdatafile/c.glay_kernel.autotvin_vertex_in_degree.dat"
#define AUTOTB_TVOUT_vertex_in_degree "../tv/cdatafile/c.glay_kernel.autotvout_vertex_in_degree.dat"
#define AUTOTB_TVIN_vertex_edges_idx "../tv/cdatafile/c.glay_kernel.autotvin_vertex_edges_idx.dat"
#define AUTOTB_TVOUT_vertex_edges_idx "../tv/cdatafile/c.glay_kernel.autotvout_vertex_edges_idx.dat"
#define AUTOTB_TVIN_edges_array_weight "../tv/cdatafile/c.glay_kernel.autotvin_edges_array_weight.dat"
#define AUTOTB_TVOUT_edges_array_weight "../tv/cdatafile/c.glay_kernel.autotvout_edges_array_weight.dat"
#define AUTOTB_TVIN_edges_array_src "../tv/cdatafile/c.glay_kernel.autotvin_edges_array_src.dat"
#define AUTOTB_TVOUT_edges_array_src "../tv/cdatafile/c.glay_kernel.autotvout_edges_array_src.dat"
#define AUTOTB_TVIN_edges_array_dest "../tv/cdatafile/c.glay_kernel.autotvin_edges_array_dest.dat"
#define AUTOTB_TVOUT_edges_array_dest "../tv/cdatafile/c.glay_kernel.autotvout_edges_array_dest.dat"
#define AUTOTB_TVIN_auxiliary_1 "../tv/cdatafile/c.glay_kernel.autotvin_auxiliary_1.dat"
#define AUTOTB_TVOUT_auxiliary_1 "../tv/cdatafile/c.glay_kernel.autotvout_auxiliary_1.dat"
#define AUTOTB_TVIN_auxiliary_2 "../tv/cdatafile/c.glay_kernel.autotvin_auxiliary_2.dat"
#define AUTOTB_TVOUT_auxiliary_2 "../tv/cdatafile/c.glay_kernel.autotvout_auxiliary_2.dat"
#define AUTOTB_TVIN_m00_axi "../tv/cdatafile/c.glay_kernel.autotvin_m00_axi.dat"
#define AUTOTB_TVOUT_m00_axi "../tv/cdatafile/c.glay_kernel.autotvout_m00_axi.dat"

#define INTER_TCL "../tv/cdatafile/ref.tcl"

// tvout file define:
#define AUTOTB_TVOUT_PC_graph_csr_struct "../tv/rtldatafile/rtl.glay_kernel.autotvout_graph_csr_struct.dat"
#define AUTOTB_TVOUT_PC_vertex_out_degree "../tv/rtldatafile/rtl.glay_kernel.autotvout_vertex_out_degree.dat"
#define AUTOTB_TVOUT_PC_vertex_in_degree "../tv/rtldatafile/rtl.glay_kernel.autotvout_vertex_in_degree.dat"
#define AUTOTB_TVOUT_PC_vertex_edges_idx "../tv/rtldatafile/rtl.glay_kernel.autotvout_vertex_edges_idx.dat"
#define AUTOTB_TVOUT_PC_edges_array_weight "../tv/rtldatafile/rtl.glay_kernel.autotvout_edges_array_weight.dat"
#define AUTOTB_TVOUT_PC_edges_array_src "../tv/rtldatafile/rtl.glay_kernel.autotvout_edges_array_src.dat"
#define AUTOTB_TVOUT_PC_edges_array_dest "../tv/rtldatafile/rtl.glay_kernel.autotvout_edges_array_dest.dat"
#define AUTOTB_TVOUT_PC_auxiliary_1 "../tv/rtldatafile/rtl.glay_kernel.autotvout_auxiliary_1.dat"
#define AUTOTB_TVOUT_PC_auxiliary_2 "../tv/rtldatafile/rtl.glay_kernel.autotvout_auxiliary_2.dat"
#define AUTOTB_TVOUT_PC_m00_axi "../tv/rtldatafile/rtl.glay_kernel.autotvout_m00_axi.dat"


static const bool little_endian()
{
  int a = 1;
  return *(char*)&a == 1;
}

inline static void rev_endian(char* p, size_t nbytes)
{
  std::reverse(p, p+nbytes);
}

template<size_t bit_width>
struct transaction {
  typedef uint64_t depth_t;
  static const size_t wbytes = (bit_width+7)>>3;
  static const size_t dbytes = sizeof(depth_t);
  const depth_t depth;
  const size_t vbytes;
  const size_t tbytes;
  char * const p;
  typedef char (*p_dat)[wbytes];
  p_dat vp;

  transaction(depth_t depth)
    : depth(depth), vbytes(wbytes*depth), tbytes(dbytes+vbytes),
      p(new char[tbytes]) {
    *(depth_t*)p = depth;
    rev_endian(p, dbytes);
    vp = (p_dat) (p+dbytes);
  }

  void reorder() {
    rev_endian(p, dbytes);
    p_dat vp = (p_dat) (p+dbytes);
    for (depth_t i = 0; i < depth; ++i) {
      rev_endian(vp[i], wbytes);
    }
  }

  template<size_t psize>
  void import(char* param, depth_t num, int64_t offset) {
    param -= offset*psize;
    for (depth_t i = 0; i < num; ++i) {
      memcpy(vp[i], param, wbytes);
      param += psize;
      if (little_endian()) {
        rev_endian(vp[i], wbytes);
      }
    }
    vp += num;
  }

  template<size_t psize>
  void send(char* param, depth_t num) {
    for (depth_t i = 0; i < num; ++i) {
      memcpy(param, vp[i], wbytes);
      param += psize;
    }
    vp += num;
  }

  template<size_t psize>
  void send(char* param, depth_t num, int64_t skip) {
    for (depth_t i = 0; i < num; ++i) {
      memcpy(param, vp[skip+i], wbytes);
      param += psize;
    }
  }

  ~transaction() { if (p) { delete[] p; } }
};


inline static const std::string begin_str(int num)
{
  return std::string("[[transaction]]           ")
         .append(std::to_string(num))
         .append("\n");
}

inline static const std::string end_str()
{
  return std::string("[[/transaction]]\n");
}

const std::string formatData(unsigned char *pos, size_t wbits)
{
  bool LE = little_endian();
  size_t wbytes = (wbits+7)>>3;
  size_t i = LE ? wbytes-1 : 0;
  auto next = [&] () {
    auto c = pos[i];
    LE ? --i : ++i;
    return c;
  };
  std::ostringstream ss;
  ss << "0x";
  if (int t = (wbits & 0x7)) {
    if (t <= 4) {
      unsigned char mask = (1<<t)-1;
      ss << std::hex << std::setfill('0') << std::setw(1)
         << (int) (next() & mask);
      wbytes -= 1;
    }
  }
  for (size_t i = 0; i < wbytes; ++i) {
    ss << std::hex << std::setfill('0') << std::setw(2) << (int)next();
  }
  ss.put('\n');
  return ss.str();
}

static bool RTLOutputCheckAndReplacement(std::string &data)
{
  bool changed = false;
  for (size_t i = 2; i < data.size(); ++i) {
    if (data[i] == 'X' || data[i] == 'x') {
      data[i] = '0';
      changed = true;
    }
  }
  return changed;
}

struct SimException : public std::exception {
  const char *msg;
  const size_t line;
  SimException(const char *msg, const size_t line)
    : msg(msg), line(line)
  {
  }
};

template<size_t bit_width>
class PostCheck
{
  static const char *bad;
  static const char *err;
  std::fstream stream;
  std::string s;

  void send(char *p, ap_uint<bit_width> &data, size_t l, size_t rest)
  {
    if (rest == 0) {
      if (!little_endian()) {
        const size_t wbytes = (bit_width+7)>>3;
        rev_endian(p-wbytes, wbytes);
      }
    } else if (rest < 8) {
      *p = data.range(l+rest-1, l).to_uint();
      send(p+1, data, l+rest, 0);
    } else {
      *p = data.range(l+8-1, l).to_uint();
      send(p+1, data, l+8, rest-8);
    }
  }

  void readline()
  {
    std::getline(stream, s);
    if (stream.eof()) {
      throw SimException(bad, __LINE__);
    }
  }

public:
  char *param;
  size_t psize;
  size_t depth;

  PostCheck(const char *file)
  {
    stream.open(file);
    if (stream.fail()) {
      throw SimException(err, __LINE__);
    } else {
      readline();
      if (s != "[[[runtime]]]") {
        throw SimException(bad, __LINE__);
      }
    }
  }

  ~PostCheck() noexcept(false)
  {
    stream.close();
  }

  void run(size_t AESL_transaction_pc, size_t skip)
  {
    if (stream.peek() == '[') {
      readline();
    }

    for (size_t i = 0; i < skip; ++i) {
      readline();
    }

    bool foundX = false;
    for (size_t i = 0; i < depth; ++i) {
      readline();
      foundX |= RTLOutputCheckAndReplacement(s);
      ap_uint<bit_width> data(s.c_str(), 16);
      send(param+i*psize, data, 0, bit_width);
    }
    if (foundX) {
      std::cerr << "WARNING: [SIM 212-201] RTL produces unknown value "
                << "'x' or 'X' on some port, possible cause: "
                << "There are uninitialized variables in the design.\n";
    }

    if (stream.peek() == '[') {
      readline();
    }
  }
};

template<size_t bit_width>
const char* PostCheck<bit_width>::bad = "Bad TV file";

template<size_t bit_width>
const char* PostCheck<bit_width>::err = "Error on TV file";
      
class INTER_TCL_FILE {
  public:
INTER_TCL_FILE(const char* name) {
  mName = name; 
  graph_csr_struct_depth = 0;
  vertex_out_degree_depth = 0;
  vertex_in_degree_depth = 0;
  vertex_edges_idx_depth = 0;
  edges_array_weight_depth = 0;
  edges_array_src_depth = 0;
  edges_array_dest_depth = 0;
  auxiliary_1_depth = 0;
  auxiliary_2_depth = 0;
  m00_axi_depth = 0;
  trans_num =0;
}
~INTER_TCL_FILE() {
  mFile.open(mName);
  if (!mFile.good()) {
    cout << "Failed to open file ref.tcl" << endl;
    exit (1); 
  }
  string total_list = get_depth_list();
  mFile << "set depth_list {\n";
  mFile << total_list;
  mFile << "}\n";
  mFile << "set trans_num "<<trans_num<<endl;
  mFile.close();
}
string get_depth_list () {
  stringstream total_list;
  total_list << "{graph_csr_struct " << graph_csr_struct_depth << "}\n";
  total_list << "{vertex_out_degree " << vertex_out_degree_depth << "}\n";
  total_list << "{vertex_in_degree " << vertex_in_degree_depth << "}\n";
  total_list << "{vertex_edges_idx " << vertex_edges_idx_depth << "}\n";
  total_list << "{edges_array_weight " << edges_array_weight_depth << "}\n";
  total_list << "{edges_array_src " << edges_array_src_depth << "}\n";
  total_list << "{edges_array_dest " << edges_array_dest_depth << "}\n";
  total_list << "{auxiliary_1 " << auxiliary_1_depth << "}\n";
  total_list << "{auxiliary_2 " << auxiliary_2_depth << "}\n";
  total_list << "{m00_axi " << m00_axi_depth << "}\n";
  return total_list.str();
}
void set_num (int num , int* class_num) {
  (*class_num) = (*class_num) > num ? (*class_num) : num;
}
void set_string(std::string list, std::string* class_list) {
  (*class_list) = list;
}
  public:
    int graph_csr_struct_depth;
    int vertex_out_degree_depth;
    int vertex_in_degree_depth;
    int vertex_edges_idx_depth;
    int edges_array_weight_depth;
    int edges_array_src_depth;
    int edges_array_dest_depth;
    int auxiliary_1_depth;
    int auxiliary_2_depth;
    int m00_axi_depth;
    int trans_num;
  private:
    ofstream mFile;
    const char* mName;
};


struct __cosim_s64__ { char data[64]; };
extern "C" void glay_kernel_hw_stub_wrapper(volatile void *, volatile void *, volatile void *, volatile void *, volatile void *, volatile void *, volatile void *, volatile void *, volatile void *);

extern "C" void apatb_glay_kernel_hw(volatile void * __xlx_apatb_param_graph_csr_struct, volatile void * __xlx_apatb_param_vertex_out_degree, volatile void * __xlx_apatb_param_vertex_in_degree, volatile void * __xlx_apatb_param_vertex_edges_idx, volatile void * __xlx_apatb_param_edges_array_weight, volatile void * __xlx_apatb_param_edges_array_src, volatile void * __xlx_apatb_param_edges_array_dest, volatile void * __xlx_apatb_param_auxiliary_1, volatile void * __xlx_apatb_param_auxiliary_2) {
  refine_signal_handler();
  fstream wrapc_switch_file_token;
  wrapc_switch_file_token.open(".hls_cosim_wrapc_switch.log");
static AESL_FILE_HANDLER aesl_fh;
  int AESL_i;
  if (wrapc_switch_file_token.good())
  {

    CodeState = ENTER_WRAPC_PC;
    static unsigned AESL_transaction_pc = 0;
    string AESL_token;
    string AESL_num;
#ifdef USE_BINARY_TV_FILE
{
transaction<512> tr(9);
aesl_fh.read(AUTOTB_TVOUT_PC_m00_axi, tr.p, tr.tbytes);
if (little_endian()) { tr.reorder(); }
tr.send<64>((char*)__xlx_apatb_param_graph_csr_struct, 1, 0);
tr.send<64>((char*)__xlx_apatb_param_vertex_out_degree, 1, 1);
tr.send<64>((char*)__xlx_apatb_param_vertex_in_degree, 1, 2);
tr.send<64>((char*)__xlx_apatb_param_vertex_edges_idx, 1, 3);
tr.send<64>((char*)__xlx_apatb_param_edges_array_weight, 1, 4);
tr.send<64>((char*)__xlx_apatb_param_edges_array_src, 1, 5);
tr.send<64>((char*)__xlx_apatb_param_edges_array_dest, 1, 6);
tr.send<64>((char*)__xlx_apatb_param_auxiliary_1, 1, 7);
tr.send<64>((char*)__xlx_apatb_param_auxiliary_2, 1, 8);
}
#else
try {
static PostCheck<512> pc(AUTOTB_TVOUT_PC_m00_axi);
pc.psize = 64;
pc.param = (char*)__xlx_apatb_param_graph_csr_struct;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);pc.param = (char*)__xlx_apatb_param_vertex_out_degree;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_vertex_in_degree;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_vertex_edges_idx;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_edges_array_weight;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_edges_array_src;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_edges_array_dest;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_auxiliary_1;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);
pc.param = (char*)__xlx_apatb_param_auxiliary_2;
pc.depth = 1;
pc.run(AESL_transaction_pc, 0);

} catch (SimException &e) {
  std::cout << "at line " << e.line << " occurred exception, " << e.msg << "\n";
}
#endif

    AESL_transaction_pc++;
    return ;
  }
static unsigned AESL_transaction;
static INTER_TCL_FILE tcl_file(INTER_TCL);
std::vector<char> __xlx_sprintf_buffer(1024);
CodeState = ENTER_WRAPC;
CodeState = DUMP_INPUTS;
unsigned __xlx_offset_byte_param_graph_csr_struct = 0;
unsigned __xlx_offset_byte_param_vertex_out_degree = 0;
unsigned __xlx_offset_byte_param_vertex_in_degree = 0;
unsigned __xlx_offset_byte_param_vertex_edges_idx = 0;
unsigned __xlx_offset_byte_param_edges_array_weight = 0;
unsigned __xlx_offset_byte_param_edges_array_src = 0;
unsigned __xlx_offset_byte_param_edges_array_dest = 0;
unsigned __xlx_offset_byte_param_auxiliary_1 = 0;
unsigned __xlx_offset_byte_param_auxiliary_2 = 0;
#ifdef USE_BINARY_TV_FILE
{
aesl_fh.touch(AUTOTB_TVIN_m00_axi, 'b');
transaction<512> tr(9);
__xlx_offset_byte_param_graph_csr_struct = 0*64;
if (__xlx_apatb_param_graph_csr_struct) {
  tr.import<64>((char*)__xlx_apatb_param_graph_csr_struct, 1, 0);
}
__xlx_offset_byte_param_vertex_out_degree = 1*64;
if (__xlx_apatb_param_vertex_out_degree) {
  tr.import<64>((char*)__xlx_apatb_param_vertex_out_degree, 1, 0);
}
__xlx_offset_byte_param_vertex_in_degree = 2*64;
if (__xlx_apatb_param_vertex_in_degree) {
  tr.import<64>((char*)__xlx_apatb_param_vertex_in_degree, 1, 0);
}
__xlx_offset_byte_param_vertex_edges_idx = 3*64;
if (__xlx_apatb_param_vertex_edges_idx) {
  tr.import<64>((char*)__xlx_apatb_param_vertex_edges_idx, 1, 0);
}
__xlx_offset_byte_param_edges_array_weight = 4*64;
if (__xlx_apatb_param_edges_array_weight) {
  tr.import<64>((char*)__xlx_apatb_param_edges_array_weight, 1, 0);
}
__xlx_offset_byte_param_edges_array_src = 5*64;
if (__xlx_apatb_param_edges_array_src) {
  tr.import<64>((char*)__xlx_apatb_param_edges_array_src, 1, 0);
}
__xlx_offset_byte_param_edges_array_dest = 6*64;
if (__xlx_apatb_param_edges_array_dest) {
  tr.import<64>((char*)__xlx_apatb_param_edges_array_dest, 1, 0);
}
__xlx_offset_byte_param_auxiliary_1 = 7*64;
if (__xlx_apatb_param_auxiliary_1) {
  tr.import<64>((char*)__xlx_apatb_param_auxiliary_1, 1, 0);
}
__xlx_offset_byte_param_auxiliary_2 = 8*64;
if (__xlx_apatb_param_auxiliary_2) {
  tr.import<64>((char*)__xlx_apatb_param_auxiliary_2, 1, 0);
}
aesl_fh.write(AUTOTB_TVIN_m00_axi, tr.p, tr.tbytes);
tcl_file.set_num(9, &tcl_file.m00_axi_depth);
}
#else
aesl_fh.touch(AUTOTB_TVIN_m00_axi);
{
aesl_fh.write(AUTOTB_TVIN_m00_axi, begin_str(AESL_transaction));
__xlx_offset_byte_param_graph_csr_struct = 0*64;
if (__xlx_apatb_param_graph_csr_struct) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_graph_csr_struct + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_vertex_out_degree = 1*64;
if (__xlx_apatb_param_vertex_out_degree) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_vertex_out_degree + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_vertex_in_degree = 2*64;
if (__xlx_apatb_param_vertex_in_degree) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_vertex_in_degree + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_vertex_edges_idx = 3*64;
if (__xlx_apatb_param_vertex_edges_idx) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_vertex_edges_idx + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_edges_array_weight = 4*64;
if (__xlx_apatb_param_edges_array_weight) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_edges_array_weight + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_edges_array_src = 5*64;
if (__xlx_apatb_param_edges_array_src) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_edges_array_src + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_edges_array_dest = 6*64;
if (__xlx_apatb_param_edges_array_dest) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_edges_array_dest + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_auxiliary_1 = 7*64;
if (__xlx_apatb_param_auxiliary_1) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_auxiliary_1 + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
__xlx_offset_byte_param_auxiliary_2 = 8*64;
if (__xlx_apatb_param_auxiliary_2) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_auxiliary_2 + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVIN_m00_axi, s);
}
}
tcl_file.set_num(9, &tcl_file.m00_axi_depth);
aesl_fh.write(AUTOTB_TVIN_m00_axi, end_str());
}
#endif
// print graph_csr_struct Transactions
{
aesl_fh.write(AUTOTB_TVIN_graph_csr_struct, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_graph_csr_struct;
aesl_fh.write(AUTOTB_TVIN_graph_csr_struct, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.graph_csr_struct_depth);
aesl_fh.write(AUTOTB_TVIN_graph_csr_struct, end_str());
}

// print vertex_out_degree Transactions
{
aesl_fh.write(AUTOTB_TVIN_vertex_out_degree, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_vertex_out_degree;
aesl_fh.write(AUTOTB_TVIN_vertex_out_degree, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.vertex_out_degree_depth);
aesl_fh.write(AUTOTB_TVIN_vertex_out_degree, end_str());
}

// print vertex_in_degree Transactions
{
aesl_fh.write(AUTOTB_TVIN_vertex_in_degree, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_vertex_in_degree;
aesl_fh.write(AUTOTB_TVIN_vertex_in_degree, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.vertex_in_degree_depth);
aesl_fh.write(AUTOTB_TVIN_vertex_in_degree, end_str());
}

// print vertex_edges_idx Transactions
{
aesl_fh.write(AUTOTB_TVIN_vertex_edges_idx, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_vertex_edges_idx;
aesl_fh.write(AUTOTB_TVIN_vertex_edges_idx, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.vertex_edges_idx_depth);
aesl_fh.write(AUTOTB_TVIN_vertex_edges_idx, end_str());
}

// print edges_array_weight Transactions
{
aesl_fh.write(AUTOTB_TVIN_edges_array_weight, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_edges_array_weight;
aesl_fh.write(AUTOTB_TVIN_edges_array_weight, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.edges_array_weight_depth);
aesl_fh.write(AUTOTB_TVIN_edges_array_weight, end_str());
}

// print edges_array_src Transactions
{
aesl_fh.write(AUTOTB_TVIN_edges_array_src, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_edges_array_src;
aesl_fh.write(AUTOTB_TVIN_edges_array_src, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.edges_array_src_depth);
aesl_fh.write(AUTOTB_TVIN_edges_array_src, end_str());
}

// print edges_array_dest Transactions
{
aesl_fh.write(AUTOTB_TVIN_edges_array_dest, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_edges_array_dest;
aesl_fh.write(AUTOTB_TVIN_edges_array_dest, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.edges_array_dest_depth);
aesl_fh.write(AUTOTB_TVIN_edges_array_dest, end_str());
}

// print auxiliary_1 Transactions
{
aesl_fh.write(AUTOTB_TVIN_auxiliary_1, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_auxiliary_1;
aesl_fh.write(AUTOTB_TVIN_auxiliary_1, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.auxiliary_1_depth);
aesl_fh.write(AUTOTB_TVIN_auxiliary_1, end_str());
}

// print auxiliary_2 Transactions
{
aesl_fh.write(AUTOTB_TVIN_auxiliary_2, begin_str(AESL_transaction));
{
auto *pos = (unsigned char*)&__xlx_offset_byte_param_auxiliary_2;
aesl_fh.write(AUTOTB_TVIN_auxiliary_2, formatData(pos, 32));
}
  tcl_file.set_num(1, &tcl_file.auxiliary_2_depth);
aesl_fh.write(AUTOTB_TVIN_auxiliary_2, end_str());
}

CodeState = CALL_C_DUT;
glay_kernel_hw_stub_wrapper(__xlx_apatb_param_graph_csr_struct, __xlx_apatb_param_vertex_out_degree, __xlx_apatb_param_vertex_in_degree, __xlx_apatb_param_vertex_edges_idx, __xlx_apatb_param_edges_array_weight, __xlx_apatb_param_edges_array_src, __xlx_apatb_param_edges_array_dest, __xlx_apatb_param_auxiliary_1, __xlx_apatb_param_auxiliary_2);
CodeState = DUMP_OUTPUTS;
#ifdef USE_BINARY_TV_FILE
{
aesl_fh.touch(AUTOTB_TVOUT_m00_axi, 'b');
transaction<512> tr(9);
__xlx_offset_byte_param_graph_csr_struct = 0*64;
if (__xlx_apatb_param_graph_csr_struct) {
  tr.import<64>((char*)__xlx_apatb_param_graph_csr_struct, 1, 0);
}
__xlx_offset_byte_param_vertex_out_degree = 1*64;
if (__xlx_apatb_param_vertex_out_degree) {
  tr.import<64>((char*)__xlx_apatb_param_vertex_out_degree, 1, 0);
}
__xlx_offset_byte_param_vertex_in_degree = 2*64;
if (__xlx_apatb_param_vertex_in_degree) {
  tr.import<64>((char*)__xlx_apatb_param_vertex_in_degree, 1, 0);
}
__xlx_offset_byte_param_vertex_edges_idx = 3*64;
if (__xlx_apatb_param_vertex_edges_idx) {
  tr.import<64>((char*)__xlx_apatb_param_vertex_edges_idx, 1, 0);
}
__xlx_offset_byte_param_edges_array_weight = 4*64;
if (__xlx_apatb_param_edges_array_weight) {
  tr.import<64>((char*)__xlx_apatb_param_edges_array_weight, 1, 0);
}
__xlx_offset_byte_param_edges_array_src = 5*64;
if (__xlx_apatb_param_edges_array_src) {
  tr.import<64>((char*)__xlx_apatb_param_edges_array_src, 1, 0);
}
__xlx_offset_byte_param_edges_array_dest = 6*64;
if (__xlx_apatb_param_edges_array_dest) {
  tr.import<64>((char*)__xlx_apatb_param_edges_array_dest, 1, 0);
}
__xlx_offset_byte_param_auxiliary_1 = 7*64;
if (__xlx_apatb_param_auxiliary_1) {
  tr.import<64>((char*)__xlx_apatb_param_auxiliary_1, 1, 0);
}
__xlx_offset_byte_param_auxiliary_2 = 8*64;
if (__xlx_apatb_param_auxiliary_2) {
  tr.import<64>((char*)__xlx_apatb_param_auxiliary_2, 1, 0);
}
aesl_fh.write(AUTOTB_TVOUT_m00_axi, tr.p, tr.tbytes);
tcl_file.set_num(9, &tcl_file.m00_axi_depth);
}
#else
aesl_fh.touch(AUTOTB_TVOUT_m00_axi);
{
aesl_fh.write(AUTOTB_TVOUT_m00_axi, begin_str(AESL_transaction));
__xlx_offset_byte_param_graph_csr_struct = 0*64;
if (__xlx_apatb_param_graph_csr_struct) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_graph_csr_struct + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_vertex_out_degree = 1*64;
if (__xlx_apatb_param_vertex_out_degree) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_vertex_out_degree + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_vertex_in_degree = 2*64;
if (__xlx_apatb_param_vertex_in_degree) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_vertex_in_degree + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_vertex_edges_idx = 3*64;
if (__xlx_apatb_param_vertex_edges_idx) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_vertex_edges_idx + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_edges_array_weight = 4*64;
if (__xlx_apatb_param_edges_array_weight) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_edges_array_weight + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_edges_array_src = 5*64;
if (__xlx_apatb_param_edges_array_src) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_edges_array_src + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_edges_array_dest = 6*64;
if (__xlx_apatb_param_edges_array_dest) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_edges_array_dest + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_auxiliary_1 = 7*64;
if (__xlx_apatb_param_auxiliary_1) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_auxiliary_1 + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
__xlx_offset_byte_param_auxiliary_2 = 8*64;
if (__xlx_apatb_param_auxiliary_2) {
for (size_t i = 0; i < 1; ++i) {
unsigned char *pos = (unsigned char*)__xlx_apatb_param_auxiliary_2 + i * 64;
std::string s = formatData(pos, 512);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, s);
}
}
tcl_file.set_num(9, &tcl_file.m00_axi_depth);
aesl_fh.write(AUTOTB_TVOUT_m00_axi, end_str());
}
#endif
CodeState = DELETE_CHAR_BUFFERS;
AESL_transaction++;
tcl_file.set_num(AESL_transaction , &tcl_file.trans_num);
}
