#-----
# robotオブジェクト
#   hear //i: hubotに問いかけなくても拾ってくれる。
#   respond : hubotに問いかけないと拾わない版(HipChatの場合はmention nameで問いかける)
#             ともに//内の正規表現にマッチしたときに処理を行う分岐。
#             iは正規表現の大文字小文字を問わないの意味。
#   topic   : ルームのトピックが変更された時に処理を行う分岐(HipChatでは反応なし)
#-----
# msg(responsクラス)オブジェクト:
#   send     : 発言があったチャンネルに対してhubotがオープンに発言
#   reply    : 上記のユーザ指定あり版(hipChatでは未実装。対象が@undefinedになる)
#   emote    : 感情表示(hipchatではjoinとかleftの時の表示と同様)
#   play     : 音を鳴らす(campfire用らしい)
#   locked   : ログに残らないようにする(campfire用らしい)
#   random   : リストの中からランダムに選択
#   http     : scoped-httpd-clientでHTTPリクエストを作成
#   match[1] : robot.hear/respondで拾った文字列の内、任意とした部分[(.*)など]
#
# process.env.<任意の環境変数>：
#   環境変数の文字列を取得できる
# =========================================
#

module.exports = (robot) ->
  # 固定文字列に反応して固定のオープンな発言を行う
   robot.hear /アルファベット/i, (msg) ->
     msg.send "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  
  # Hubotに対して hubot の<任意文字列> と発言すると
  # <任意文字列>が"バカ"という文字列だった場合とそれ以外とで違う反応を発言者に返す
   robot.respond /の(.*)/i, (msg) ->
     doorType = msg.match[1]
     if doorType is "バカ"
       msg.reply "バカはテメーだ！！！"
     else
       msg.reply "何言ってるかよくわかんないです^^;"
  
  # 固定文字列に反応して固定の反応を返す
   robot.hear /android/i, (msg) ->
     msg.emote "makes a freshly baked pie"
  
  # 笑いを表現する英語ネットスラング
  #   lulz : 嘲笑で使われることが多い
  #   lol  : 大笑いする
  #   rofl : 笑い転げる
  #   lmao : ケツがもげるほど笑う
  #-----------
  # "hubot lulz"に対して"lol", "rofl", "lmao"のいずれかを返す
   lulz = ['lol', 'rofl', 'lmao']
   robot.respond /lulz/i, (msg) ->
     msg.send msg.random lulz
  
  # ルームのトピックが変わった時に反応？(よくわかんない)
   robot.topic (msg) ->
     msg.send "#{msg.message.text}? That's a Paddlin'" 
  
  # Hubotがルームに入った時、出た時にランダムに挨拶？
   enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
   leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  
   robot.enter (msg) ->
     msg.send msg.random enterReplies
   robot.leave (msg) ->
     msg.send msg.random leaveReplies
  
  # 環境変数を取ってくる
   answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  
  # 人生の究極の質問への答えは何？という問いかけに対して、上記環境変数を表示＆なんだその質問ｗ
  # と返す。未定義なら未定義と表示。
   robot.respond /what is the answer to the ultimate question of life/, (msg) ->
     unless answer?
       msg.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
       return
     msg.send "#{answer}, but what is the question?"
  
  # ちょっと遅くね？に対し、60秒後に誰が遅いって？と返す。
   robot.respond /you are a little slow/, (msg) ->
     setTimeout () ->
       msg.send "Who you calling 'slow'?"
     , 3 * 1000
  
   annoyIntervalId = null
  
   # (annoy me)俺をイラッとさせろ
   # -> Hubotが奇声を発する。
   # -> あ？セカイで最もイラッとする声を聞きたいんだろ？ｗと煽ってくる
   # -> 1秒毎に奇声を発し続ける
   robot.respond /annoy me/, (msg) ->
     if annoyIntervalId
       msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
       return
     msg.send "Hey, want to hear the most annoying sound in the world?"
     annoyIntervalId = setInterval () ->
       msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
     , 1000

  # (unannoy me)俺をイラだたせんなよ
  # ->HubotがGUYS, GUYS GUYSとぴたりと止む
  # 上記の奇声を発し続けていない時はHubotが"今、俺はいらだたせてない・・・よね？"と言ってくる
   robot.respond /unannoy me/, (msg) ->
     if annoyIntervalId
       msg.send "GUYS, GUYS, GUYS!"
       clearInterval(annoyIntervalId)
       annoyIntervalId = null
     else
       msg.send "Not annoying you right now, am I?"
  
  # 
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, msg) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if msg?
  #     msg.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (msg) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     msg.reply "I'm too fizzy.."
  #
  #   else
  #     msg.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (msg) ->
  #   robot.brain.set 'totalSodas', 0
  #   robot.respond 'zzzzz'
