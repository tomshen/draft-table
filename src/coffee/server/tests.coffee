models = require './models'

models.School.create {name: 'name', email_domain: 'domain', plans: []}, (_id) ->
    models.School.addPlan _id, {title: 'title', image_thumbnail: 'thumb', supporters: [], proposals: [], elements: []}, (plan_id)->
      models.Plan.addProposal plan_id, {this_is: 'a proposal'}, (prop_id)->
        console.log "proposal ID is #{prop_id}"
      models.Plan.addSupporter plan_id, {name: "Sammy Supporter", email: "sam@supportmemaybe.net"}
    models.School.update _id, {name: 'Penn', email_domain: 'upenn.edu'}