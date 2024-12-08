---@alias VariadicFunction fun(...: any)
---@alias Log {version: string, usecolor: boolean, level: string, outfile?: string, trace: VariadicFunction, debug: VariadicFunction, info: VariadicFunction, warning: VariadicFunction, error: VariadicFunction, fatal: VariadicFunction}

local MODES = {
	{ name = "trace",   pretty_name = "TRACE", color = colors.blue, },
	{ name = "debug",   pretty_name = "DEBUG", color = colors.blue, },
	{ name = "info",    pretty_name = "INFO",  color = colors.white, },
	{ name = "warning", pretty_name = "WARN",  color = colors.orange, },
	{ name = "error",   pretty_name = "ERROR", color = colors.red, },
	{ name = "fatal",   pretty_name = "FATAL", color = colors.red, },
}

local LEVELS = {}
for i, v in ipairs(MODES) do
	LEVELS[v.name] = i
end

local _M = {}

function _M.print()
	---@type Log
	local log = {}

	log.usecolor = false
	log.level = "trace"

	local tostring = require('/evo-logistics/utils/utils').tostring

	for i, x in ipairs(MODES) do
		local name = x.pretty_name or x.name
		log[x.name] = function(...)
			-- Return early if we're below the log level
			if i < LEVELS[log.level] then
				return
			end

			local msg = tostring(...)
			local info = debug.getinfo(2, "Sl")
			local lineinfo = info.short_src .. ":" .. info.currentline

			-- Print
			local str = string.format("[%-6s%s] %s: %s\n",
																name, os.date("%d/%m/%Y %H:%M:%S"), lineinfo, msg)
			local old_color = term.getTextColor()
			term.setTextColor(x.color)
			print(str)
			term.setTextColor(old_color)
		end
	end

	return log
end

function _M.file(outfile)
	---@type Log
	local log = {}

	log.usecolor = false
	log.outfile = outfile
	log.level = "trace"

	local tostring = require('/evo-logistics/utils/utils').tostring

	for i, x in ipairs(MODES) do
		local name = x.pretty_name or x.name
		log[x.name] = function(...)
			-- Return early if we're below the log level
			if i < LEVELS[log.level] then
				return
			end

			local msg = tostring(...)
			local info = debug.getinfo(2, "Sl")
			local lineinfo = info.short_src .. ":" .. info.currentline

			-- Output to log file
			if log.outfile then
				local file = fs.open(log.outfile, "a")
				local str = string.format("[%-6s%s] %s: %s\n",
																	name, os.date("%d/%m/%Y %H:%M:%S"), lineinfo, msg)
				file.write(str)
				file.flush()
				file.close()
			else
				error("log.outfile is nil")
			end
		end
	end

	return log
end

function _M.empty()
	---@type Log
	local log = {}

	for i, x in ipairs(MODES) do
		log[x.name] = function() end
	end

	return log
end

return _M
