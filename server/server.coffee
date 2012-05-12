Arenas = new Meteor.Collection "arenas"
Contenders = new Meteor.Collection "contenders"
Assignments = new Meteor.Collection "assignments"

Meteor.publish 'arenas', ->
  Arenas.find()

Meteor.publish 'contenders', (arena_id) ->
  Contenders.find
    arena_id: arena_id

Meteor.publish 'assignments', (client_id) ->
  Assignments.find
    client_id: client_id

populateAssignments = (client_id, arena_id) ->
  getRandomContender = (exception_id) ->
    rand = Math.random()
    fetch = (rand_crit) ->
      Contenders.findOne
        arena_id: arena_id
        _id: 
          $ne: exception_id
        random: rand_crit
    fetch({ $gte: rand}) || fetch({ $lte: rand})
  
  if Assignments.find({client_id: client_id}).count() < 1
    first = getRandomContender()
    second = getRandomContender(first._id)
    Assignments.insert
      client_id: client_id
      arena_id: arena_id
      contenders: [first, second]
      winner: null
      loser: null

Meteor.methods
  startChoosing: (client_id, arena_id) ->
    populateAssignments(client_id, arena_id)
    
  getAssignment: (arena_id) ->
    # console.log "getPair here", arena_id
    # getRandomContender = (exception_id) ->
    #   rand = Math.random()
    #   fetch = (rand_crit) ->
    #     Contenders.findOne
    #       arena_id: arena_id
    #       _id: 
    #         $ne: exception_id
    #       random: rand_crit
    #   fetch({ $gte: rand}) || fetch({ $lte: rand})
    # 
    # first = getRandomContender()
    # second = getRandomContender(first._id)
    # res = [first, second]
    # console.log res
    # res
    return "hi"
  # choose: (winner, loser) ->
Assignments.find().observe
  changed: (new_document, at_index, old_document) ->
    console.log new_document, "changed"

Meteor.startup ->
  unless Arenas.findOne()
    console.log "Bootstrapping Arenas"
    Arenas.insert
      prompt: "Which name is better for an app which you use to recommend iPhone apps?"

  unless Contenders.findOne()
    console.log "Bootstrapping Contenders"
    arena = Arenas.findOne()
    ideas = [
      "AppHappy",
      "AppSlaughter",
      "Apptastic",
      "Appster",
      "App Friends"
    ]
    for idea in ideas
      Contenders.insert
        arena_id: arena._id
        text: idea
        score: 1500
        wins: 0
        losses: 0
        random: Math.random()
