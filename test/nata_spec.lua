local nata = require 'nata'

describe('nata.new', function()
	it('returns a pool', function()
		assert.is.table(nata.new())
	end)

	it('only accepts tables as the first argument', function()
		assert.has_error(function()
			nata.new(2)
		end, "bad argument #1 to 'new' (expected table, got number)")
		assert.has_error(function()
			nata.new 'asdf'
		end, "bad argument #1 to 'new' (expected table, got string)")
	end)
end)

describe('nata.oop', function()
	it('returns an OOP system', function()
		assert.is_table(nata.oop())
	end)

	it('only accepts tables as the first argument', function()
		assert.has_error(function()
			nata.oop(2)
		end, "bad argument #1 to 'oop' (expected table, got number)")
		assert.has_error(function()
			nata.oop 'asdf'
		end, "bad argument #1 to 'oop' (expected table, got string)")
	end)
end)
