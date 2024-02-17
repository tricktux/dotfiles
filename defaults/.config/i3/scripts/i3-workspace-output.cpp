#include <cstdio>
#include <iostream>
#include <memory>
#include <optional>
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
std::optional<std::string> get_mon_name(const std::string &text) {
  // Define regex pattern to match last word after space
  std::regex pattern(".*\\s+([A-Za-z0-9]+(.*[A-Za-z0-9]+)+)");

  // Create a match object and search for the regex pattern in the given text
  std::smatch match;
  if (std::regex_search(text, match, pattern)) {
    // Return the last word after space
    return match[1];
  }

  return std::nullopt;
}

struct monitor {
  std::string name;
  size_t resolution;
};

struct monitors {
  std::vector<monitor> m_mon;

  void sort() {
    std::sort(m_mon.begin(), m_mon.end(), [](const auto &lhs, const auto &rhs) {
      return lhs.resolution > rhs.resolution;
    });
  }

  const std::string &main() const { return m_mon[0].name; }
  const std::string &secondary() const {
    return m_mon.size() > 1 ? m_mon[1].name : m_mon[0].name;
  }
  const std::string &tertiary() const {
    const auto nm = m_mon.size();
    return nm > 2 ? m_mon[2].name : (nm > 1 ? m_mon[1].name : m_mon[0].name);
  }
};

std::ostream &operator<<(std::ostream &os, const monitors &m) {
  os << "monitor: size(" << m.m_mon.size() << ")\n";
  for (const auto &mon : m.m_mon) {
    os << "\t" << mon.name << " " << mon.resolution << "\n";
  }
  return os;
}

// Function that returns the monitor resolution
std::string get_mon_resolution(const std::string &text) {
  std::regex rgx("\\b\\d{4}\\b");
  std::smatch match;

  if (std::regex_search(text, match, rgx)) {
    return match[0];
  }

  return std::string();
}

std::optional<monitor> builder(const std::string &text) {
  if (const auto name = get_mon_name(text); name) {
    if (const auto resolution = get_mon_resolution(text); !resolution.empty()) {
      return monitor{*name, std::stoul(resolution)};
    }
  }
  return std::nullopt;
}

int main(int argc, char **argv) {
  constexpr auto command = "xrandr --listmonitors";

  // Open a pipe to the command and read its output line by line
  std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(command, "r"), pclose);
  if (!pipe && !pipe.get()) {
    std::cerr << "Error: failed to run command \"" << command << "\""
              << std::endl;
    return 1;
  }

  char buffer[256];
  std::vector<std::string> lines{};
  while (fgets(buffer, sizeof(buffer), pipe.get()) != nullptr) {
    lines.push_back(buffer);
  }

  // Parse the output and find the main and secondary monitors
  monitors monitors{};
  std::cout << "lines: size(" << lines.size() << ")\n";
  for (const auto &line : lines) {
    if (const auto mon = builder(line); mon) {
      std::cout << "\t" << mon->name << " " << mon->resolution << ". orig: '"
                << line << "'";
      monitors.m_mon.push_back(std::move(*mon));
    } else
      std::cout << "\tNOT A MONITOR: " << line;
  }

  monitors.sort();
  std::cout << monitors;

  const auto &pm{monitors.main()};
  const auto &sm{monitors.secondary()};
  const auto &tm{monitors.tertiary()};

  const std::unordered_map<uint8_t, std::string> w{
      {1, pm}, {2, sm}, {3, tm}, {4, pm}, {5, sm},
      {6, pm}, {7, sm}, {8, pm}, {9, sm},
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
