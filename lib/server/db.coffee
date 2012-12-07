mongoose = require 'mongoose'

db = mongoose.createConnection 'localhost', 'logs'

interviewerSchema = mongoose.Schema {}, 
  collection: 'interviewer'

interviewerSchema.index {timestamp: -1}

Interviewer = db.model 'interviewer', interviewerSchema

module.exports =
  Interviewer: Interviewer