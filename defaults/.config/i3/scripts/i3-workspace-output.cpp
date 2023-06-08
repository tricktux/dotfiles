#include <cstdio>
#include <iostream>
#include <memory>
#include <regex>
#include <string>
#include <unordered_map>
#include <vector>

// https://github.com/altdesktop/i3ipc-python/blob/master/examples/app-on-ws-init.py
// https://github.com/Iskustvo/i3-ipcpp/blob/master/include/i3_ipc.hpp

// Compile with: clang++ i3-workspace-output.cpp -std=c++20 -Ofast -o
// i3-workspace-output && ./i3-workspace-output

/**
 * @brief Get the last word after space from the given text.
 *
 * This function takes a string as input and searches for the last word after
 * space in the string using regular expressions. The function returns the last
 * word after space if it is found, otherwise an empty string is returned.
 *
 * @param text The string to search for the last word after space. The expected
 * input is a line from the `xrandr --listmonitors` command
 *
 * @return std::string The last word after space if found, otherwise an empty
 * string.
 */
std::string get_mon_name(const std::string &text) {
  // Define regex pattern to match last word after space
  std::regex pattern(".*\\s+([A-Za-z0-9]+(-[A-Za-z0-9]+)+)");

  // Create a match object and search for the regex pattern in the given text
  std::smatch match;
  if (std::regex_search(text, match, pattern)) {
    // Return the last word after space
    return match[1];
  }

  return std::string();
}

// Function that returns the monitor resolution
std::string get_mon_resolution(const std::string& text) {
  std::regex rgx("\\b\\d{4}\\b");
  std::smatch match;

  if (std::regex_search(text, match, rgx)) {
    return match[0];
  }

  return std::string();
}

int main(int argc, char **argv) {
  std::string command = "xrandr --listmonitors";
  std::vector<std::string> lines;

  // Open a pipe to the command and read its output line by line
  std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(command.c_str(), "r"),
                                                pclose);

  if (!pipe && !pipe.get()) {
    std::cerr << "Error: failed to run command \"" << command << "\""
              << std::endl;
    return 1;
  }
  char buffer[256];
  while (fgets(buffer, sizeof(buffer), pipe.get()) != nullptr) {
    lines.push_back(buffer);
  }
  // Parse the output and find the main and secondary monitors
  size_t num_mons{lines.size() - 1};
  if (num_mons < 2) {
    std::cerr << "Error: not enought monitors: \"" << num_mons << "\""
              << std::endl;
    return 1;
  }

  if (num_mons > 3) {
    std::cerr << "Error: too many monitors: \"" << num_mons << "\""
              << std::endl;
    return 2;
  }

  bool reserve{false};
  std::string tm;
  auto thi_idx = 3;
  auto sec_idx = 2;
  if (num_mons == 3) {
    if (const auto r = get_mon_resolution(lines[2]); r != "3840") {
      sec_idx = 3;
      thi_idx = 2;
    }
    tm = get_mon_name(lines[thi_idx]);
    if (tm.empty()) {
      std::cerr << "Error: failed to parse secondary monitor" << std::endl;
      return 4;
    }
    reserve = true;
  }
  auto const pm = get_mon_name(lines[1]);
  if (pm.empty()) {
    std::cerr << "Error: failed to parse primary monitor" << std::endl;
    return 3;
  }

  auto const sm = get_mon_name(lines[sec_idx]);
  if (sm.empty()) {
    std::cerr << "Error: failed to parse secondary monitor" << std::endl;
    return 5;
  }

  const std::unordered_map<uint8_t, std::string> w{
      {1, pm}, {2, sm}, {3, reserve ? tm : sm},
      {4, pm}, {5, sm}, {6, pm},
      {7, sm}, {8, pm}, {9, sm},
  };

  // Loop through the unordered_map while executing the i3 command
  for (const auto &[key, value] : w) {
    sprintf(buffer, "i3-msg 'workspace number %u; move workspace to output %s'",
            key, value.c_str());
    std::cout << buffer << "\n";
    std::system(buffer);
  }

  return 0;
}
