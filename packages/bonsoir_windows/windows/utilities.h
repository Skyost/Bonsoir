#include <string>
#include <vector>

namespace bonsoir_windows {
  std::wstring toUtf16(const std::string string);

  std::string toUtf8(const std::wstring wide_string);

  std::tuple<std::string, std::string> parseBonjourFqdn(const std::string fqdn);

  std::wstring getComputerName();
}  // namespace bonsoir_windows