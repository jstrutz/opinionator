# Collections to match server
Arenas = new Meteor.Collection "arenas"
Contenders = new Meteor.Collection "contenders"
Assignments = new Meteor.Collection "assignments"

# Current arena
Session.set 'current_arena_id',  null

Session.set 'client_id', Meteor.uuid()

console.log "Client id is ", Session.get 'client_id' if Session.get('client_id')
Meteor.subscribe 'arenas', ->
  if Session.equals 'current_arena_id', null
    arena = Arenas.findOne()
    Session.set 'current_arena_id', arena._id

Meteor.autosubscribe ->
  Meteor.subscribe 'contenders', Session.get('current_arena_id') if Session.get('current_arena_id')?
  Meteor.subscribe 'assignments', Session.get('client_id')

  unless Session.equals('client_id', null) or Session.equals('current_arena_id', null)
    Meteor.call 'startChoosing', Session.get('client_id'), Session.get('current_arena_id')
  

assignment_query = Assignments.find
  client_id: Session.get('client_id')
assignment_query.observe
  changed: (assignment, at_index, old_document) ->
    # Get a new assignment which doesn't have a winner yet
    console.log "Reacting to changed assignment"
    new_assignment = Assignments.findOne
      client_id: Session.get('client_id')
      winner: null
    console.log "Old assignment was ", assignment, "new assignment is ", new_assignment
    Session.set('current_assignment', new_assignment)
  added: (assignment) ->
    console.log "Receved new assignment ", assignment._id, assignment.contenders[0].text + " versus " + assignment.contenders[1].text
    unless Session.get('current_assignment')?    
      Session.set 'current_assignment', assignment 
    
        
choose = (target) ->
  $(target).addClass('winner').siblings(".choice").addClass('loser')
  winner_id = $(target).data('winner')
  loser_id = $(target).data('loser')

  Assignments.update Session.get('current_assignment'._id),
    $set:
      winner: winner_id
      loser: loser_id
      

  

Template.question.prompt = ->
  arena_id = Session.get('current_arena_id')
  if arena_id?
    Arenas.findOne(arena_id)?.prompt

Template.choices.has_assignment = ->
  !Session.equals('current_assignment', undefined)

Template.choices.assignment_id = ->
  Session.get('current_assignment')?._id
Template.choices.contender1_value = ->
  Session.get('current_assignment').contenders[0].text
Template.choices.contender1_id = ->
  Session.get('current_assignment').contenders[0]._id
Template.choices.contender2_value = ->
  Session.get('current_assignment').contenders[1].text
Template.choices.contender2_id = ->
  Session.get('current_assignment').contenders[1]._id

Template.choices.events =
  'click .choice' : (evt) ->
    # template data, if any, is available in 'this'
    choose(evt.currentTarget)

# Setup 


Template.connection.state = ->
  Meteor.status().status
Template.connection.label = ->
  switch Meteor.status().status
    when "waiting" then "Disconnected; waiting for connection."
    when "connectiong" then "Connecting &hellip;"
    else "Connected"
