#include "utilities.h"

#include <windows.h>

#include <regex>

namespace bonsoir_windows {
  std::wstring toUtf16(const std::string string) {
    // see https://stackoverflow.com/a/69410299/8707976

    if (string.empty()) {
      return L"";
    }

    auto sizeNeeded = MultiByteToWideChar(CP_UTF8, 0, &string.at(0), (int)string.size(), nullptr, 0);
    if (sizeNeeded <= 0) {
      throw std::runtime_error("MultiByteToWideChar() failed: " + std::to_string(sizeNeeded));
      // see
      // https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
      // for error codes
    }

    std::wstring result(sizeNeeded, 0);
    MultiByteToWideChar(CP_UTF8, 0, &string.at(0), (int)string.size(), &result.at(0), sizeNeeded);
    return result;
  }

  std::string toUtf8(const std::wstring wide_string) {
    // see https://stackoverflow.com/a/69410299/8707976

    if (wide_string.empty()) {
      return "";
    }

    auto sizeNeeded = WideCharToMultiByte(CP_UTF8, 0, &wide_string.at(0), (int)wide_string.size(), nullptr, 0, nullptr, nullptr);
    if (sizeNeeded <= 0) {
      throw std::runtime_error("WideCharToMultiByte() failed: " + std::to_string(sizeNeeded));
      // see
      // https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
      // for error codes
    }

    std::string result(sizeNeeded, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wide_string.at(0), (int)wide_string.size(), &result.at(0), sizeNeeded, nullptr, nullptr);
    return result;
  }

  std::tuple<std::string, std::string> parseBonjourFqdn(const std::string fqdn) {
    std::regex regexPattern("^(.*?)\\._(.*?)\\.?(?:local)?\\.?$");
    std::smatch match;

    if (std::regex_search(fqdn, match, regexPattern)) {
      std::string serviceName = match[1].str();
      size_t pos = serviceName.find_last_not_of(" \t\r\n");
      if (pos != std::string::npos) {
        serviceName.erase(pos + 1);
      }

      std::string serviceType = "_" + match[2].str();

      return {serviceName, serviceType};
    }

    return {"", ""};
  }

  std::wstring getComputerName() {
    DWORD size = 0;
    GetComputerNameEx(ComputerNameDnsHostname, nullptr, &size);
    std::vector<wchar_t> computerName(size);
    if (!GetComputerNameEx(ComputerNameDnsHostname, &computerName[0], &size)) {
      throw std::runtime_error("Could not determine computer name");
    }
    return &computerName[0];
  }

  bool isValidIPv4(const std::string &ipAddress) {
    const std::regex ipv4Regex(R"(\b(?:\d{1,3}\.){3}\d{1,3}\b)");
    return std::regex_match(ipAddress, ipv4Regex);
  }
}  // namespace bonsoir_windows