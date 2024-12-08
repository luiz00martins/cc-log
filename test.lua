local Ut = require("/cc-ut")
local Log = require("/evo-log")

local ut = Ut()
local describe = ut.describe

describe("Log Module", function(test)
	local log

	test.beforeEach(function()
		log = Log.print()
	end)

	test("should create a logger with default settings", function(expect)
		expect(log.usecolor).toBe(false)
		expect(log.level).toBe("trace")
		expect(type(log.trace)).toBe("function")
		expect(type(log.debug)).toBe("function")
		expect(type(log.info)).toBe("function")
		expect(type(log.warning)).toBe("function")
		expect(type(log.error)).toBe("function")
		expect(type(log.fatal)).toBe("function")
	end)

	test("should respect log level", function(expect)
		local printed = {}
		local oldPrint = _G.print
		_G.print = function(msg)
			table.insert(printed, msg)
			return 1
		end

		log.level = "warning"

		log.trace("test message")
		log.debug("test message")
		log.info("test message")

		log.warning("test message")
		log.error("test message")
		log.fatal("test message")

		expect(#printed).toBe(3)

		_G.print = oldPrint
	end)

	test("should format messages correctly", function(expect)
		local printed
		local oldPrint = _G.print
		_G.print = function(msg)
			printed = msg
			return 1
		end

		log.info("test message")

		expect(printed:match("%[INFO%s+%d%d/%d%d/%d%d%d%d%s+%d%d:%d%d:%d%d%]")).toBeTruthy()
		expect(printed:match("test message")).toBeTruthy()
		expect(printed:match("test.lua:%d+")).toBeTruthy()

		_G.print = oldPrint
	end)

	test("should handle color settings", function(expect)
		local oldPrint = _G.print
		_G.print = function(msg) return 1 end

		local oldColor = term.getTextColor()
		local colorChanges = {}
		local oldSetTextColor = term.setTextColor
		term.setTextColor = function(color) table.insert(colorChanges, color) end

		log.error("test message")

		expect(colorChanges[1]).toBe(colors.red)
		expect(colorChanges[2]).toBe(oldColor)

		term.setTextColor = oldSetTextColor

		_G.print = oldPrint
	end)
end)
