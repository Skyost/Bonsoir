#include <string>
#include <windows.h>
#include <stdexcept>
#include <vector>
#include <map>

namespace bonsoir_windows {
    std::wstring toUtf16(const std::string string);

    std::string toUtf8(const std::wstring wide_string);

    std::vector <std::string> split(const std::string text, const char delimiter);

    std::wstring getComputerName();

    bool isValidIPv4(const std::string &ipAddress);
}  // namespace bonsoir_windows