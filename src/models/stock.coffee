neo4j = require 'neo4j'
db = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')

INDEX_NAME = 'nodes'
INDEX_KEY = 'type'
INDEX_VAL = 'stock'

Stock = module.exports = (_node) ->

proxyProperty = (prop, isData) ->
  Object.defineProperty Stock.prototype, prop,
    get: ->
      if isData
        this._node.data[prop]
      else
        this._node[prop]
    set: (value) ->
      if isData
        this._node.data[prop] = value
      else
        this._node[prop] = value

proxyProperty 'id'
proxyProperty 'exists'
proxyProperty 'code', true
proxyProperty 'name', true
proxyProperty 'base_value', true

Stock.get_all = (callback) ->
  callback(null, "good")

Stock.create = (data, callback) ->
  node = db.createNode data
  stock = new Stock node
  node.save (err) ->
    return callback err if err
    
    node.index INDEX_NAME, INDEX_KEY, INDEX_VAL, (err) ->
      return callback err if err
      callback null, stock

Stock.create_from_csv = (csv_content, callback) ->
  if csv_content.length == 4
    data = 
      code: csv_content[1].trim()
      name: csv_content[2].trim()
      base_value: csv_content[3].trim()

    Stock.create data, callback
  else
    callback('bad data', null)