--- Main class of the citations submodule used to manage Better BibTex citations in Lua.
---@class M
local M = {}

--- Default configuration for the citations submodule.
M.default_config = {
	fields = { "author", "title", "year", "url" },
}

--- Get the content of the references file specified in the $BIB environment variable.
---@return any
function M.get_references_file()
	-- Retrieve the bibliography file path from env.
	local bib_path = os.getenv("BIB")
	if not bib_path or bib_path == "" or vim.fn.filereadable(bib_path) == 0 then
		vim.notify("Bibliography file not found: " .. bib_path, vim.log.levels.ERROR)
		return
	end
	local f = io.open(bib_path, "r")
	if not f then
		vim.notify("Error reading bibliography file: " .. bib_path, vim.log.levels.ERROR)
		return
	end
	-- Open the file and read all.
	local content = f:read("*a")
	f:close()
	return content
end

--- Create a reference-style markdown link from a bibliography reference.
--- Notifies and returns empty strings if the reference has no URL.
---@param reference table
---@return string ref_text Inline reference, e.g. `[key]`
---@return string link_text Link definition, e.g. `[key]: url "title"`
---@return string title the human readable title of the reference.
function M.create_md_link_from_reference(reference)
	-- Build markdown reference-style link.
	if not reference.url or reference.url == "" then
		vim.notify("Selected entry does not have an URL", vim.log.levels.WARN)
		return "", "", ""
	end

	if not reference.key or reference.key == "" then
		vim.notify("Selected entry does not have a citation key", vim.log.levels.WARN)
		return "", "", ""
	end

	local ref_text = string.format("[%s]", reference.key)
	local link_text = string.format('[%s]: %s "%s"', reference.key, reference.url, reference.title)
	return ref_text, link_text, reference.title
end

--- Parse the content into separate Better BibTex references.
---@param content any
---@return table
function M.parse_references(content)
	-- Parse .bib entries. Each entry starts with @type{key, ... }
	local entries = {} -- citation key to reference entry map
	local summary = {} -- lines to display in fzf
	local summary_to_citekey = {} -- map a display line with a citaiton key

	-- @[%w]+ matches the first part: @misc
	-- the %b{} is Lua balanced operator which allow to select everything
	-- inside the first { bracked till the associaed }, even if other {} are present
	-- inside the content.
	for entry in content:gmatch("@[%w]+%b{}") do
		local type = entry:match("^%s*@(%w+)%s*{"):lower()
		local citekey = entry:match("@[%w]+{([^,]+),")
		if citekey then
			local title = M.parse_better_bibtex_field(entry, "title") or ""
			local author = M.parse_better_bibtex_field(entry, "author") or ""
			local year = M.parse_better_bibtex_field(entry, "year") or ""
			local url = M.parse_better_bibtex_field(entry, "url") or ""

			-- TODO: make it a class
			entries[citekey] = {
				type = type,
				key = citekey,
				title = title,
				author = author,
				year = year,
				url = url,
			}

			local ref_summary = string.format("%s │ %s (%s) │ %s", citekey, author, year, title)

			summary_to_citekey[ref_summary] = entries[citekey]

			table.insert(summary, ref_summary)
		end
	end

	return {
		summary = summary,
		entries = entries,
		summary_to_citekey = summary_to_citekey,
	}
end

--- Convert a Better BibText entry represented in a table into a multiline string.
---@param entry table
---@return string
function M.bib_to_text(entry)
	-- If the reference type is not present, fallback to misc.
	local out = { ("@%s{%s,"):format(entry.type or "misc", entry.key or "") }
	for _, field in ipairs(M.default_config.fields) do
		if entry[field] and entry[field] ~= "" then
			out[#out + 1] = ("  %s = %s,"):format(field, entry[field])
		end
	end
	out[#out + 1] = "}"

	return table.concat(out, "\n")
end

--- Parse a BibTex entry to extract the value associated with the provided field name.
---@param entry table
---@param name string
---@return string
function M.parse_better_bibtex_field(entry, name)
	-- Match `name = {value}` or `name = "value"` or bare number.
	-- The match is sequential so precendence is given to the text inside {}.
	local v = entry:match(name .. "%s*=%s*{(.-)}%s*[,\n]")
		or entry:match(name .. '%s*=%s*"(.-)"%s*[,\n]')
		or entry:match(name .. "%s*=%s*([^,\n}]+)") -- [^,\n}] matches anything that is not a comma, newline, or closing brace
	if v then
		v = v
			:gsub("[{}]", "") -- remove all the { } braces
			:gsub("^%s+", "") -- remove leading whitespaces
			:gsub("%s+$", "") -- remove trailing whitespaces
	end
	return v
end

return M
