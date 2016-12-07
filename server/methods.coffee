cl = console.log
fs = require 'fs'
HTTP.methods
  'removeFiles': (data) ->
#    cl data.DEL_FILE_LIST
#    cl mSettings.setting
    try
      data.DEL_FILE_LIST.forEach (path) ->
  #      cl path
#        window는 경로 변경
        filename = (tmp = path.split '/')[tmp.length - 1]
        if data.DEL_OPTION is '삭제'
          fs.unlinkSync path
        else if data.DEL_OPTION is '사이즈0'
          fs.openSync(path, 'w')
        else if data.DEL_OPTION is '백업'
          try
            fs.access "#{data.BACKUP_PATH}", fs.F_OK, (err) ->
              if (errno = err?.errno)? and errno is -2  #no such file or directory
                fs.mkdirSync "#{data.BACKUP_PATH}"
              try
                fs.rename "#{path}", "#{data.BACKUP_PATH}/#{filename}", (err) ->
                  cl err
              catch err
                cl err
          catch err
            cl err

  #    return throw new Meteor.Error 'test error'
    catch err
      cl err.message
      return err.message
    return 'success'

#Meteor.methods
#  'removeFiles': (DEL_FILE_LIST) ->
#    cl 'remove files'
#    cl DEL_FILE_LIST
#    return 'success'
##    return throw new Meteor.Error 'error 123123'