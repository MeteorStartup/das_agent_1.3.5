##both
#@mSettings =
#  isTest: true
#  setting: null
#
#if Meteor.isServer
#  _.extend mSettings,
#    DMS_URL: 'http://localhost:4000'     #target dms server url . 나머지 세팅은 dms에서 받아온다
#    AGENT_URL: 'http://localhost:3000'      #dms에서 식별될 호스트명
#
#
#if Meteor.isClient
#  _.extend mSettings,
#    clientSetting: 'clientValue'