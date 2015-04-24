module.exports =

  verbose: true

  log: (text) ->
    if @verbose
      console.log text
