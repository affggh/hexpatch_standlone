//#include <sys/mman.h>
#include <iostream>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <iostream>
#include <sys/stat.h>
#include <sys/fcntl.h>
#if defined(__CYGWIN__)
#include <cygwin/fs.h>
#elif defined(__linux__)
#include <linux/fs.h>
#endif
#include <sys/ioctl.h>
#include "hexpatch.hpp"

using namespace std;
// From magisk/src/base/file.cpp
mmap_data::mmap_data(const char *name, bool rw) {
    int fd = open(name, (rw ? O_RDWR : O_RDONLY) | O_CLOEXEC);
    if (fd < 0)
        return;
    struct stat st;
    if (fstat(fd, &st))
        return;
    if (S_ISBLK(st.st_mode)) {
        uint64_t size;
        ioctl(fd, BLKGETSIZE64, &size);
        sz = size;
    } else {
        sz = st.st_size;
    }
    void *b = sz > 0
            ? mmap(nullptr, sz, PROT_READ | PROT_WRITE, rw ? MAP_SHARED : MAP_PRIVATE, fd, 0)
            : nullptr;
    close(fd);
    buf = static_cast<uint8_t *>(b);
}

static void hex2byte(const char *hex, uint8_t *buf) {
    char high, low;
    for (int i = 0, length = strlen(hex); i < length; i += 2) {
        high = toupper(hex[i]) - '0';
        low = toupper(hex[i + 1]) - '0';
        buf[i / 2] = ((high > 9 ? high - 7 : high) << 4) + (low > 9 ? low - 7 : low);
    }
}

int hexpatch(const char *file, const char *from, const char *to) {
    int patched = 1;

    auto m = mmap_data(file, true);

    vector<uint8_t> pattern(strlen(from) / 2);
    vector<uint8_t> patch(strlen(to) / 2);

    hex2byte(from, pattern.data());
    hex2byte(to, patch.data());

    uint8_t * const end = m.buf + m.sz;
    for (uint8_t *curr = m.buf; curr < end; curr += pattern.size()) {
        curr = static_cast<uint8_t*>(memmem(curr, end - curr, pattern.data(), pattern.size()));
        if (curr == nullptr)
            return patched;
        fprintf(stderr, "Patch @ %08X [%s] -> [%s]\n", (unsigned)(curr - m.buf), from, to);
        memset(curr, 0, pattern.size());
        memcpy(curr, patch.data(), patch.size());
        patched = 0;
    }

    return patched;
}

int main(int argc, char **argv) {
    const char *infile = argv[1];
    const char *from = argv[2];
    const char *to = argv[3];
    if (argc < 3) {
        fprintf(stderr, "Usage:\n\t./hexpatch [file] [from_x] [to_X]\n");
        return 1;
    }

    if (access(infile, F_OK) !=0) {
        fprintf(stderr, "Error : File does not exist !\n");
        return 1;
    }
    int ret = hexpatch(infile, from, to);
    return ret;
}