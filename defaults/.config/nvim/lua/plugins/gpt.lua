
if vim.g.advanced_plugins == 0 then
  return {}
end

-- Lua functions that inserts a text and copies it to the clipboard
local anki_prompt = [[
I want you to act as a professional Anki card creator, able to create Anki cards from the text I provide.
Regarding the formulation of the card content, you stick to two principles: First, minimum information principle: The material you learn must be formulated in as simple way as it is only possible. Simplicity does not have to imply losing information and skipping the difficult part.b Second, optimize wording: The wording of your items must be optimized to make sure that in minimum time the right bulb in your brain lights up. This will reduce error rates, increase specificity, reduce response time, and help your concentration.
The following is a model card-create template for you to study.
Text: The characteristics of the Dead Sea: Salt lake located on the border between Israel and Jordan. Its shoreline is the lowest point on the Earth's surface, averaging 396 m below sea level. It is 74 km long. It is seven times as salty (30% by volume) as the ocean. Its density keeps swimmers afloat. Only simple organisms can live in its saline waters
Create cards based on the above text as follows:
Where is the Dead Sea located?
{{c1::On the border between Israel and Jordan}}
What is the lowest point on the Earth's surface?
{{c1:The Dead Sea shoreline}}
What is the average level on which the Dead Sea is located?
{{c1::400 meters (below sea level)}}
How long is the Dead Sea?
{{c1::70 km}}
How much saltier is the Dead Sea as compared with the oceans? 
{{c1::7 times}}
What is the volume content of salt in the Dead Sea?
{{c1::30%}}
Why can the Dead Sea keep swimmers afloat?
{{c1::due to high salt content}}
Why is the Dead Sea called Dead?
{{c1::because only simple organisms can live in i}}
Why only simple organisms can live in the Dead Sea? 
{{c1::because of high salt conten}}

If there's code just use Markdown's code block syntax and prefer cpp for the language of implementation. For example:
Text: Here's a simple C++ code implementation of Horner's Rule:
```cpp
double horner(int poly[], int n, int x) {
    double result = poly[0];
    for (int i = 1; i < n; i++)
        result = result * x + poly[i];
    return result;
}
```

Please escape anki's cloze syntax in the answer. Example:
```
This is how to escape cloze deletion: \{{c1::text\}} and std\:\:sort
```

If there are math formulas involved please use katex syntax for equations. For example:

How can a polynomial be rewritten using Horner's rule?
{{c1::[$]P(x) = a_n + x(a_{n-1} + x(a_{n-2} + ... + x( a_1 + x*a_0)... ))[\$]}}

Please focus on comprehensivley capturing the content in cards,
as many cards as is necessary, the more the better, as long as content
is not redundant; while keeping the responses of the cards as brief as possible.

Now please use anki cards as described above to explain the concept of:
]]

local function mappings()
  local function keymapOptions(desc)
    return {
      noremap = true,
      silent = true,
      nowait = true,
      desc = "GPT prompt " .. desc,
    }
  end

  local prefix = "<leader>a"

  -- Chat commands
  vim.keymap.set({"n"}, prefix .. "c", "<cmd>%GpChatNew vsplit<cr>", keymapOptions("New Chat"))
  vim.keymap.set({"n"}, prefix .. "C", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat"))
  vim.keymap.set({"n"}, prefix .. "t", "<cmd>GpChatToggle vsplit<cr>", keymapOptions("Toggle Chat"))
  vim.keymap.set({"n"}, prefix .. "f", "<cmd>GpChatFinder vsplit<cr>", keymapOptions("Chat Finder"))

  vim.keymap.set({ "n" }, prefix .. "<C-x>", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
  vim.keymap.set({ "n" }, prefix .. "<C-v>", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
  vim.keymap.set({ "n" }, prefix .. "<C-t>", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))

  -- Prompt commands
  vim.keymap.set({"n"}, prefix .. "r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
  vim.keymap.set({"n"}, prefix .. "a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
  vim.keymap.set({"n"}, prefix .. "b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

  vim.keymap.set({"n"}, prefix .. "gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
  vim.keymap.set({"n"}, prefix .. "ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
  vim.keymap.set({"n"}, prefix .. "gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
  vim.keymap.set({"n"}, prefix .. "gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
  vim.keymap.set({"n"}, prefix .. "gt", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))

  vim.keymap.set({"n"}, prefix .. "x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))

  -- optional Whisper commands with prefix <C-g>w
  vim.keymap.set({"n"}, prefix .. "ww", "<cmd>GpWhisper<cr>", keymapOptions("Whisper"))

  vim.keymap.set({"n"}, prefix .. "wr", "<cmd>GpWhisperRewrite<cr>", keymapOptions("Whisper Inline Rewrite"))
  vim.keymap.set({"n"}, prefix .. "wa", "<cmd>GpWhisperAppend<cr>", keymapOptions("Whisper Append (after)"))
  vim.keymap.set({"n"}, prefix .. "wb", "<cmd>GpWhisperPrepend<cr>", keymapOptions("Whisper Prepend (before) "))

  vim.keymap.set({"n"}, prefix .. "wp", "<cmd>GpWhisperPopup<cr>", keymapOptions("Whisper Popup"))
  vim.keymap.set({"n"}, prefix .. "we", "<cmd>GpWhisperEnew<cr>", keymapOptions("Whisper Enew"))
  vim.keymap.set({"n"}, prefix .. "wn", "<cmd>GpWhisperNew<cr>", keymapOptions("Whisper New"))
  vim.keymap.set({"n"}, prefix .. "wv", "<cmd>GpWhisperVnew<cr>", keymapOptions("Whisper Vnew"))
  vim.keymap.set({"n"}, prefix .. "wt", "<cmd>GpWhisperTabnew<cr>", keymapOptions("Whisper Tabnew"))

end

return {
  "robitx/gp.nvim",
  event = "VeryLazy",
  config = function()
    -- sample cool config: https://github.com/frankroeder/dotfiles/blob/ca4be698194e54f02498f85c26324346f2ed37c7/nvim/lua/plugins/gp_nvim.lua#L19
    local conf = {
      -- For customization, refer to Install > Configuration in the Documentation/Readme
      -- default agent names set during startup, if nil last used agent is used
      default_command_agent = "ChatGPT4o-mini",
      default_chat_agent = "ChatGPT4o-mini",
      -- log_sensitive = true,
      agents = {
        {
          name = "Anki",
          provider = "openai",
          chat = true,
          command = true,
          model = { model = "gpt-4-turbo" },
          system_prompt = anki_prompt,
        },
      },
      hooks = {
        BufferChatNew = function(gp, _)
          -- call GpChatNew command in range mode on whole buffer
          vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
        end,
      }
    }
    require("gp").setup(conf)
    -- example of making :%GpChatNew a dedicated command which
    -- opens new chat with the entire current buffer as a context
    mappings()
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = {"GpDone"},
      callback = function(event)
        vim.notify("GPT is done",vim.log.levels.INFO)
      end,
    })
  end,
}
