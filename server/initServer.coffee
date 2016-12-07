cl = console.log
future = require 'fibers/future'
fiber = require 'fibers'
fs = require 'fs'
Meteor.startup ->
#  dms = DDP.connect mSettings.DMS_URL
#
#  while true    #ddp stream error에 대한 while 문의 timeout 반복 체크 테스트가 안됨.
#    cl 'while??'
#    #  dms에서 agent mSettings.setting 부터 받아온다
#    fut = new future()
#    dms.call 'getAgentSetting', mSettings.AGENT_URL, (err, rslt) ->
#      if err then cl err
#      fut.return rslt
#    mSettings.setting = fut.wait()
#    if mSettings.setting? then break
#    else Meteor._sleepForMs 5000
#  cl 'end'

  # setting이 있어야 구동
  @mSettings = do ->
    return obj =
      DMS_URL: process?.env?._mSettings_DMS_URL
      AGENT_URL: process?.env?._mSettings_AGENT_URL
      setting: null
  cl mSettings
  while !mSettings.setting
    fut = new future()
    HTTP.post "#{mSettings.DMS_URL}/getAgentSetting",
      data: AGENT_URL: mSettings.AGENT_URL
    , (err, rslt) ->
      if err
        cl err
        fut.return null
      else
        cl mSettings.setting = (JSON.parse rslt.content)
        fut.return mSettings.setting
    mSettings.setting = fut.wait()
    unless mSettings.setting then Meteor._sleepForMs 10000
#    if mSettings.setting? then break;
#    else Meteor._sleepForMs 1000

  path = mSettings.setting.소멸정보절대경로
  checkDir = ->
    files = fs.readdirSync(path)
    files = files.filter (file) ->
      if file.substring(file.length - 3, file.length) is 'das' then true else false
    files.forEach (file) ->
      try
        dasInfo = fs.readFileSync "#{path}/#{file}", 'utf-8'#, (err, str) ->
#        cl dasInfo
        HTTP.post "#{mSettings.DMS_URL}/insertDAS",
          data:
            dasInfo: dasInfo
            AGENT_URL: mSettings.AGENT_URL
        , (err, rslt) ->
          if err  # file move to err dir
            cl err
            # err dir create
            try
              fs.access "#{path}/err", fs.F_OK, (err) ->
                if (errno = err?.errno)? and errno is -2  #no such file or directory
                  fs.mkdirSync "#{path}/err"
                fs.rename "#{path}/#{file}", "#{path}/err/#{file}"
            catch err
              cl err
          else   # file remove
            fs.unlinkSync "#{path}/#{file}"
      catch err
        if err    # file move to err dir
          cl err
          # err dir create
          try
            fs.access "#{path}/err", fs.F_OK, (err) ->
              if (errno = err?.errno)? and errno is -2  #no such file or directory
                fs.mkdirSync "#{path}/err"
              fs.rename "#{path}/#{file}", "#{path}/err/#{file}"
          catch err
            cl err

  checkDir()
  setInterval ->
    fiber ->
      checkDir()
    .run()
  , 1000 * 1      #수정 시 동일 파일이 저장되려고 하는 것 방지



  #dms.call 'insertDAS',
  #  Agent명: mSettings.setting.agent.Agent명
  #  AGENT_URL: mSettings.AGENT_URL
  #  서비스_ID: 'SVC00001'    #파일에서 꺼냄
  #  게시판_ID: 'BRD00001'    #파일에서 꺼냄
  #  REQ_DATE: new Date('2016-08-15') #'201608151231000'
  #  CUR_IP: '10.0.0.24'
  #  DEL_FILE_LIST: [
  #    '/data/images/1.jpg'
  #    '/data/files/2.doc'
  #  ]
  #  UP_FSIZE: 3038920   #num type
  #  DEL_DATE: new Date('2016-08-20') #'201608201231000'
  #  KEEP_PERIOD: 10   #date 계산해서 넣어줌.
  #  STATUS: 'success'   # success or err_msg / delete error, sql error

  #dms.call 'insertDAS',
  #  Agent명: mSettings.setting.agent.Agent명
  #  AGENT_URL: mSettings.AGENT_URL
  #  서비스_id: mSettings.setting.service._id
  #  서비스명: mSettings.setting.service.서비스명
  #  REQ_DATE: new Date('2016-08-15') #'201608151231000'
  #  CUR_IP: '10.0.0.24'
  #  DEL_FILE_LIST: [
  #    '/data/images/1.jpg'
  #    '/data/files/2.doc'
  #  ]
  #  UP_FSIZE: 3038920   #num type
  #  DEL_DATE: new Date('2016-08-20') #'201608201231000'
  #  KEEP_PERIOD: 10   #date
  #  STATUS: 'success'   # success or err_msg / delete error, sql error



  #setInterval ->
  #  path = mSettings.setting.agent.소멸정보절대경로
  #  files = fs.readdirSync(path)
  #  if files.length > 0
  #    file = files[0]
  #
  #, 3000



  #for file in files

  #, 3000




  #lineReader = require('readline').createInterface
  #  input: require('fs').createReadStream('/Users/jwjin/data/DasReqInfo_201601021327567.das')
  #
  #lineReader.on 'line', (line) ->
  #  console.log(line)
