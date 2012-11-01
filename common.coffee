# Collections to match server
Contenders = new Meteor.Collection "contenders"


if Meteor.is_client    
  Session.set('contenders', undefined)
  getRandomContender = (exception_id) ->
    rand = Math.random()
    console.log rand
    fetch = (rand_crit) ->
      Contenders.findOne
        _id: 
          $ne: exception_id
        random: rand_crit
    fetch({ $gte: rand}) || fetch({ $lte: rand})


  Meteor.autosubscribe ->    
    Meteor.subscribe 'contenders'    
    
    if Session.equals('contenders', undefined) and Contenders.find().count() >= 2
      console.log "Setting new contenders"
      new_contenders = [getRandomContender(), null]
      new_contenders[1] = getRandomContender(new_contenders[0]._id)
      Session.set('contenders', new_contenders)      
      console.log "New contenders are", Session.get('contenders')

  
  eloExpectedScore = (contender, opponent) ->
    1.0 / (1 + Math.pow(10, (opponent.rating - contender.rating) / 400))
  
  choose = (target) ->
    $(target).addClass('winner').siblings(".choice").addClass('loser').parent().addClass('chosen')
    winner_id = $(target).data('choice')
    cs = Session.get('contenders')
    [winner, loser] = if cs[0]._id == winner_id
      cs
    else
      cs.reverse()
    console.log "Winner is ", winner, ", Loser is ", loser
    setTimeout ->
      winner_delta = Math.round(16 * (1 - eloExpectedScore(winner, loser)))
      loser_delta = Math.round(16 * (0 - eloExpectedScore(loser, winner)))
      
      Contenders.update winner._id,
        $inc:
          wins: 1
          rating: winner_delta
      Contenders.update loser._id,
        $inc:
          losses: 1
          rating: loser_delta
      Session.set('contenders', undefined)
    , 1300
    
  Template.choices.has_contenders = ->
    !Session.equals('contenders', undefined)
  Template.choices.contender0 = ->
    Session.get('contenders')[0]
  Template.choices.contender1 = ->
    Session.get('contenders')[1]
  Template.ranks.contenders = ->
    Contenders.find {},
      sort: 
        rating: -1

  Template.choices.events =
    'click .choice' : (evt) ->
      target = $(evt.target).closest("[data-choice]")
      choose(target)

  Template.connection.state = ->
    Meteor.status().status
  Template.connection.label = ->
    switch Meteor.status().status
      when "waiting" then "Disconnected; waiting for connection."
      when "connecting" then "Connecting &hellip;"
      else "Connected"

if Meteor.is_server
  Meteor.startup ->
    Meteor.publish 'contenders', ->
      Contenders.find()

    unless Contenders.findOne()
      console.log "Bootstrapping Contenders"
      ideas = ["Corpsefire", "Bishibosh", "Bonebreaker", "Blood Raven", "Coldcrow", "Rakanishu", "Treehead Woodfist", "Griswold", "The Countess", "Pitspawn Fouldog", "Bone Ash", "Andariel", "Radament", "Creeping Feature", "Blood Witch the Wild", "Beetleburst", "Coldworm the Burrower", "Dark Elder", "Fangskin", "Fire Eye", "The Summoner", "Ancient Kaa the Soulless", "Duriel"]
      for idea, index in ideas
        Contenders.insert
          text: idea
          rating: 1500
          wins: 0
          losses: 0
          random: index / ideas.length
