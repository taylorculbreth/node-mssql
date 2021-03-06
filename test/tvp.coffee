sql = require '../'
assert = require 'assert'
config = require('./_connection') 'tedious'

class MSSQLTestType extends sql.Table
	constructor: ->
		super 'dbo.MSSQLTestType'
		
		@columns.add 'a', sql.VarChar(50)
		@columns.add 'b', sql.Int

describe 'tedious tvp', ->
	before (done) ->
		global.DRIVER = 'tedious'
		
		sql.connect config(), done
		
	it 'new Table', (done) ->
		tvp = new MSSQLTestType
		tvp.rows.add 'asdf', 15

		r = new sql.Request
		r.input 'tvp', tvp
		r.execute '__test7', (err, recordsets) ->
			if err then return done err
			
			assert.equal recordsets[0].length, 1
			assert.equal recordsets[0][0].a, 'asdf'
			assert.equal recordsets[0][0].b, 15
			
			done()
		
	it 'Recordset.toTable()', (done) ->
		r = new sql.Request
		r.query 'select \'asdf\' as a, 15 as b', (err, recordset) ->
			if err then return done err

			tvp = recordset.toTable()

			r2 = new sql.Request
			r2.input 'tvp', tvp
			r2.execute '__test7', (err, recordsets) ->
				assert.equal recordsets[0].length, 1
				assert.equal recordsets[0][0].a, 'asdf'
				assert.equal recordsets[0][0].b, 15
				
				done err
	
	it.skip 'query (todo)', (done) ->
		tvp = new MSSQLTestType
		tvp.rows.add 'asdf', 15
		
		r = new sql.Request
		r.input 'tvp', tvp
		r.verbose = true
		r.query 'select * from @tvp', (err, recordsets) ->
			if err then return done err
			
			assert.equal recordsets[0].length, 1
			assert.equal recordsets[0][0].a, 'asdf'
			assert.equal recordsets[0][0].b, 15
			
			done()
	
	it.skip 'prepared statement (todo)', (done) ->
		tvp = new MSSQLTestType
		tvp.rows.add 'asdf', 15
		
		ps = new sql.PreparedStatement
		ps.input 'tvp', sql.TVP('MSSQLTestType')
		ps.prepare 'select * from @tvp', (err) ->
			if err then return done err

			ps.execute {tvp: tvp}, (err, recordset) ->
				if err then return done err
				
				assert.equal recordsets[0].length, 1
				assert.equal recordsets[0][0].a, 'asdf'
				assert.equal recordsets[0][0].b, 15
				
				ps.unprepare done
	
	after ->
		sql.close()