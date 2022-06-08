local M = {}

function M.__setup_snippets()
	local org = require("orgmode")
	local ls = require("luasnip")
	local c = ls.choice_node
	local s = ls.s
	local fmt = require("luasnip.extras.fmt").fmt
	local i = ls.insert_node
	local t = ls.text_node
	local f = ls.function_node
	local e = require("luasnip.extras")
	local function get_date_time()
		return os.date("%Y-%m-%d %a %H:%M")
	end
	local function get_date()
		return os.date("%Y-%m-%d %a")
	end
	local function schedule()
		return require("orgmode").action("org_mappings.org_schedule")
	end

	local todo_snips = {}
  for k = 1, 3 do
    table.insert(
      todo_snips,
      s(
        string.rep("d", k),
        fmt(
          [[
    {} TODO {} :{}:
        {}
        {}
    ]],
          {
            t(string.rep("*", k)),
            i(1, "description"),
            i(2, "tags"),
            f(function()
              return "DEADLINE: <" .. get_date() .. ">"
            end, {}),
            f(function()
              return "[" .. get_date_time() .. "]"
            end, {}),
          }
        )
      )
    )
    table.insert(
      todo_snips,
      s(
        string.rep("t", k),
        fmt(
          [[
    {} TODO {} :{}:
        {}
        {}
    ]],
          {
            t(string.rep("*", k)),
            i(1, "description"),
            i(2, "tags"),
            f(function()
              return "SCHEDULED: <" .. get_date() .. ">"
            end, {}),
            f(function()
              return "[" .. get_date_time() .. "]"
            end, {}),
          }
        )
      )
    )
  end

  table.insert(
    todo_snips,
    s(
      "tc",
      fmt(
        [[
  {} TODO {} :{}:
      {}
      {}
  ]],
        {
          c(1, {
            i(nil, "*"),
            i(nil, "**"),
            i(nil, "***"),
          }),
          i(2, "description"),
          i(3, "tags"),
          f(function()
            return "SCHEDULED: <" .. get_date() .. ">"
            end, {}),
          f(function()
            return "[" .. get_date_time() .. "]"
            end, {}),
        }
      )
    )
  )

  ls.add_snippets("org", todo_snips)
end

function M:setup()
	local org = require("orgmode")
	org.setup_ts_grammar()

	self.__setup_snippets()

  vim.cmd[[
    hi link OrgTODO OrgBold
  ]]

	org.setup({
		org_agenda_files = { vim.g.wiki_path .. [[/**/*.org]] },
		org_priority_lowest = "D",
		org_todo_keywords = {
			"TODO",
			"WAITING",
			"BLOCKED",
			"|",
			"DONE",
			"WONT_DO",
			"CANCELED",
		},
		org_default_notes_file = vim.g.wiki_path .. [[/notes.org]],
		mappings = {
			global = { org_agenda = "<leader>ma", org_capture = "<leader>mc" },
			org = {
				org_refile = "<localleader>r",
				org_timestamp_up = "<localleader>A",
				org_timestamp_down = "<localleader>X",
				org_change_date = "<localleader>d",
				org_set_tags_command = "<localleader>t",
				org_toggle_archive_tag = "<localleader>a",
				org_todo = "<localleader>j",
				org_todo_prev = "<localleader>k",
				org_move_subtree_down = "<localleader>J",
				org_move_subtree_up = "<localleader>K",
				org_do_promote = "<localleader>h",
				org_do_demote = "<localleader>l",
				org_demote_subtree = "<localleader>L",
				org_promote_subtree = "<localleader>H",
				org_meta_return = "<localleader><cr>",
				org_open_at_point = "<localleader>f",
				org_toggle_checkbox = "<localleader>d",
			},
			capture = {
				org_capture_finalize = "q",
				org_capture_refile = "R",
				org_capture_kill = "Q",
			},
			agenda = {
				org_agenda_later = "<localleader>l",
				org_agenda_earlier = "<localleader>e",
				org_agenda_goto_today = "<localleader>t",
				org_agenda_week_view = "<localleader>w",
				org_agenda_month_view = "<localleader>m",
				org_agenda_year_view = "<localleader>y",
				org_agenda_goto = "<localleader>f",
			},
		},
	})
end

return M
