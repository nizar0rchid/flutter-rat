// Minimal Windows native stub that reads an appended config block.
// Build with MSVC: cl /O2 /MT stub.c /Fe:client_stub.exe
// Or with MinGW: gcc -O2 -static -o client_stub.exe stub.c
#include <windows.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static const char MARKER[] = "AXESSCFGv1"; // must match generator
static const size_t MARKER_LEN = sizeof(MARKER) - 1;
static const size_t MAX_TAIL_READ = 4 * 1024 * 1024; // 4 MiB max search window

// simple search for needle in haystack, returns offset or -1
static long find_subbuffer(const unsigned char *hay, size_t hay_len,
                           const unsigned char *needle, size_t needle_len) {
    if (needle_len == 0 || hay_len < needle_len) return -1;
    for (size_t i = 0; i <= hay_len - needle_len; ++i) {
        if (memcmp(hay + i, needle, needle_len) == 0) return (long)i;
    }
    return -1;
}

int main(void) {
    char pathBuf[MAX_PATH];
    DWORD len = GetModuleFileNameA(NULL, pathBuf, MAX_PATH);
    if (len == 0 || len == MAX_PATH) {
        fprintf(stderr, "Failed to get module path\n");
        return 1;
    }

    FILE *f = fopen(pathBuf, "rb");
    if (!f) {
        fprintf(stderr, "Failed to open own exe: %s\n", pathBuf);
        return 1;
    }

    // Determine file size using 64-bit API
#if defined(_MSC_VER)
    _fseeki64(f, 0, SEEK_END);
    long long file_size = _ftelli64(f);
#else
    fseeko(f, 0, SEEK_END);
    long long file_size = ftello(f);
#endif
    if (file_size <= 0) {
        fclose(f);
        fprintf(stderr, "Invalid file size\n");
        return 1;
    }

    // Decide how much of the tail to read
    size_t tail_read = (size_t)file_size;
    if (tail_read > MAX_TAIL_READ) tail_read = MAX_TAIL_READ;

#if defined(_MSC_VER)
    _fseeki64(f, file_size - tail_read, SEEK_SET);
#else
    fseeko(f, file_size - tail_read, SEEK_SET);
#endif

    unsigned char *buf = (unsigned char*)malloc(tail_read);
    if (!buf) {
        fclose(f);
        fprintf(stderr, "Out of memory\n");
        return 1;
    }

    size_t read = fread(buf, 1, tail_read, f);
    if (read != tail_read) {
        // it's okay if fewer bytes read, adjust read length
        tail_read = read;
    }

    long pos = find_subbuffer(buf, tail_read, (const unsigned char*)MARKER, MARKER_LEN);
    if (pos < 0) {
        free(buf);
        fclose(f);
        fprintf(stderr, "Config marker not found\n");
        return 2;
    }

    // Marker found at file offset:
    long long marker_file_offset = (file_size - tail_read) + pos;
    // Read 8 bytes after marker -> little-endian uint64 length
    long long length_pos = marker_file_offset + (long long)MARKER_LEN;
    // Seek and read length
#if defined(_MSC_VER)
    _fseeki64(f, length_pos, SEEK_SET);
#else
    fseeko(f, length_pos, SEEK_SET);
#endif

    unsigned char lenbuf[8];
    if (fread(lenbuf, 1, 8, f) != 8) {
        free(buf);
        fclose(f);
        fprintf(stderr, "Failed to read config length\n");
        return 3;
    }
    uint64_t cfg_len = ((uint64_t)lenbuf[0]) |
                       ((uint64_t)lenbuf[1] << 8) |
                       ((uint64_t)lenbuf[2] << 16) |
                       ((uint64_t)lenbuf[3] << 24) |
                       ((uint64_t)lenbuf[4] << 32) |
                       ((uint64_t)lenbuf[5] << 40) |
                       ((uint64_t)lenbuf[6] << 48) |
                       ((uint64_t)lenbuf[7] << 56);

    if (cfg_len == 0 || cfg_len > (1024u * 1024u * 50u)) { // guard: max 50MiB
        free(buf);
        fclose(f);
        fprintf(stderr, "Config length invalid: %llu\n", (unsigned long long)cfg_len);
        return 4;
    }

    // Read JSON config
    long long cfg_pos = length_pos + 8;
#if defined(_MSC_VER)
    _fseeki64(f, cfg_pos, SEEK_SET);
#else
    fseeko(f, cfg_pos, SEEK_SET);
#endif

    char *cfg_buf = (char*)malloc(cfg_len + 1);
    if (!cfg_buf) {
        free(buf);
        fclose(f);
        fprintf(stderr, "Out of memory for config\n");
        return 5;
    }
    size_t got = fread(cfg_buf, 1, (size_t)cfg_len, f);
    fclose(f);
    free(buf);

    if (got != cfg_len) {
        free(cfg_buf);
        fprintf(stderr, "Failed to read full config (got %zu expected %llu)\n", got, (unsigned long long)cfg_len);
        return 6;
    }
    cfg_buf[cfg_len] = '\0'; // null-terminate

    // For this minimal stub: print config and exit.
    // A real client would parse JSON and act (connect to server, start monitoring, etc.)
    printf("Embedded config JSON:\n%s\n", cfg_buf);

    // TODO: parse the JSON and act on fields (serverAddress, port, clientId)
    // Example: parse naively to extract serverAddress and port (not robust)
    // ... implement your runtime behavior here ...

    free(cfg_buf);
    return 0;
}