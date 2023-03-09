#include <cstdio>
#include <iostream>
#include <regex>
#include <string>
#include <vector>

// Compile with: clang++ i3-workspace-output -std=c++20 -Ofast -o i3-workspace-output && ./i3-workspace-output

/**
 * @brief Get the last word after space from the given text.
 *
 * This function takes a string as input and searches for the last word after space in the string
 * using regular expressions. The function returns the last word after space if it is found, otherwise
 * an empty string is returned.
 *
 * @param text The string to search for the last word after space. The expected
 * input is a line from the `xrandr --listmonitors` command
 *
 * @return std::string The last word after space if found, otherwise an empty string.
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

int main() {
  std::string command = "xrandr --listmonitors";
  std::vector<std::string> lines;

  // Open a pipe to the command and read its output line by line
  FILE *pipe = popen(command.c_str(), "r");
  if (!pipe) {
    std::cerr << "Error: failed to run command \"" << command << "\""
              << std::endl;
    return 1;
  }
  char buffer[256];
  while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
    lines.push_back(buffer);
  }
  pclose(pipe);

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
  if (num_mons == 3)
    reserve = true;
  auto const pm = get_mon_name(lines[1]);
  if (pm.empty()) {
    std::cerr << "Error: failed to parse primary monitor" << std::endl;
    return 3;
  }

  auto const sm = get_mon_name(lines[num_mons]);
  if (sm.empty()) {
    std::cerr << "Error: failed to parse secondary monitor" << std::endl;
    return 4;
  }

  // Print the results
  std::cout << "Secondary monitor: '" << sm << "'\n";
  for (size_t i = 1; i < 10; ++i) {
    if (i == 3 && reserve) {
      std::system("i3-msg 'workspace 3, move workspace to output eDP-1-1'");
      continue;
    }
    sprintf(buffer, "i3-msg 'workspace %zu, move workspace to output %s'", i,
            i % 2 == 0 ? sm.c_str() : pm.c_str());
    std::cout << buffer << "\n";
    std::system(buffer);
  }

  return 0;
}
