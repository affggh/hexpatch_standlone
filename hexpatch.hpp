#pragma once

#include <vector>

#ifdef __cplusplus
extern "C" {
#endif // extern "C" {

struct byte_data {
    using str_pairs = std::initializer_list<std::pair<std::string_view, std::string_view>>;

    uint8_t *buf = nullptr;
    size_t sz = 0;

    int patch(str_pairs list) { return patch(true, list); }
    int patch(bool log, str_pairs list);
    bool contains(std::string_view pattern, bool log = true) const;
protected:
    void swap(byte_data &o);
};

struct mmap_data : public byte_data {
    mmap_data() = default;
    mmap_data(const mmap_data&) = delete;
    mmap_data(mmap_data &&o) { swap(o); }
    mmap_data(const char *name, bool rw = false);
    ~mmap_data() { if (buf) munmap(buf, sz); }
    mmap_data& operator=(mmap_data &&other) { swap(other); return *this; }
};

int hexpatch(const char *file, const char *from, const char *to);

#ifdef __cplusplus
}
#endif // extern "C" {