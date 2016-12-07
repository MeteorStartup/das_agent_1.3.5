cl = console.log
fs = require 'fs'
request = require 'sync-request'
#sleep = require 'sleep'
express = require 'express'



# setting이 있어야 구동
cl process?.env?._mSettings_DMS_URL
cl process?.env?._mSettings_AGENT_URL
mSettings = do ->
  return obj =
    DMS_URL: process?.env?._mSettings_DMS_URL
    AGENT_URL: process?.env?._mSettings_AGENT_URL
    setting: null
#cl mSettings
while !mSettings.setting
  try
    res = request "POST", "#{mSettings.DMS_URL}/getAgentSetting", json: AGENT_URL: mSettings.AGENT_URL
    mSettings.setting = JSON.parse res.getBody('utf8')
  catch err
    cl err
#    sleep.sleep 1
#cl mSettings

path = mSettings.setting.소멸정보절대경로

#pre config
fs.access "#{path}/err", fs.F_OK, (err) ->
  if (errno = err?.errno)? and errno is -2  #no such file or directory
    fs.mkdirSync "#{path}/err"

checkDir = =>
  files = fs.readdirSync(path)
  files = files.filter (file) ->
    if file.substring(file.length - 3, file.length) is 'das' then true else false
  files.forEach (file) =>
    try
      dasInfo = fs.readFileSync "#{path}/#{file}", 'utf-8'#, (err, str) ->
      #        cl dasInfo
      try
        res = request "POST", "#{mSettings.DMS_URL}/insertDAS",
          json:
            dasInfo: dasInfo
            AGENT_URL: mSettings.AGENT_URL
        if res.getBody('utf8') isnt 'success'
          fs.rename "#{path}/#{file}", "#{path}/err/#{file}"
        fs.unlinkSync "#{path}/#{file}"
      catch err
        cl err
        try
          fs.rename "#{path}/#{file}", "#{path}/err/#{file}"
        catch err
          cl err
    catch err
      if err    # file move to err dir
        cl err
        try
          fs.rename "#{path}/#{file}", "#{path}/err/#{file}"
        catch err
          cl err

checkDir()
setInterval ->
  checkDir()
, 1000 * 1      #수정 시 동일 파일이 저장되려고 하는 것 방지


# jwjin/1609240919 methods

app = express()
app.use express.bodyParser()
app.post '/removeFiles', (req, res) ->
  data = req.body
  res.type 'text/plain'
  try
    ## jwjin/1609240956 파일처리옵션 제거 (삭제온리)
    data.DEL_FILE_LIST.forEach (path) ->
      fs.unlinkSync path
    res.send 'success'
  catch err
    cl err.message
    res.send err.message

app.listen process?.env?.PORT || 3000





