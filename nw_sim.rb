
# coding: utf-8

# 取り敢えず問題文の内容を記載。
# 次に、正解の状況を先ず作ってみる。
# 正解の状況は、存在するmacへのmessageは受け入れられる。
# 存在しない場合は、破棄される。
# NWキャプチャでそれを見ているような状況。
# 表示は完了。
# これだと、送るメッセージの変数内容をアウトプット部分が参照出来ている。
# 詰まり、実際を考えると最初は参照出来ない情報を、
# ケーブル繋いで、macで宛先指定して、ブロードキャストして、
# hubは中継して、受け取り側は自分宛か確認して、
# 自分宛なら受信、違ったら破棄の処理を行う。
# ということがあって、宛先側で情報が参照可能になる。
# 詰まり基本は変数受け渡し。見れる見れないとかをしっかり管理というか
# 実際を考えて書いていかないとおかしなことになるはず。
# あとそもそも相手のmacを先ず知ってることがおかしい。
# それも問い合わせなきゃとかあるけどそこはまた後で。
# 
# 以下今後の予定？
# class化？ packet, ip, message, nic,,,,でも「必要になるまで作るな」ということで、まだ考えなし

# class -----------------------------------

class Port
  attr_accessor :mac_table, :nextportnum
  def initialize
    @nextportnum = 1
  end
  def connected(next_to) # 実装はそれぞれの継承先で。
  end
end

class PC < Port
  attr_accessor :hostname, :mac_addr # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname, mac_addr) # インスタンス毎にホスト名とmacを持つ。
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    @mac_addr = mac_addr
    super() # 括弧なしで書いてて暫く嵌った。省略するとこのスコープの引数も投げてしまうということです。
  end
  def send(mac_addr, message)
  end
  def recv(mac_addr, message)
  end
  def rjct(mac_addr, message)
  end
  def connected(next_to) # PCの方のポートでは特に管理することなし。
    @nextportnum += 1 # 今のところポート数無制限
  end
end

class Hub < Port
  attr_accessor :hostname # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname) # インスタンス毎にホスト名を持つ。macは？→macも必要なはず。それも2枚。→調べたらないらしい。そーなのかー
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    #@mac_addr1= hostname + 1.to_s # macはホスト名で取り敢えず作成。ホスト名被らないようにとか、制御もそのうち必要になる。
    #@mac_addr2= hostname + 2.to_s # macではなく、ポートと繋がっている先のmacの対照表を管理するということでした。
    super()
    @mac_table = []
  end
  def send(mac_addr, message)
  end
  def recv(mac_addr, message)
  end
  def rjct(mac_addr, message)
  end
  def connected(next_to) # 自分のportとリンク先との対照表
      @mac_table << @nextportnum << next_to.mac_addr # ポートとマックの、、ハッシュの方が良いのかちょっと分からず取り敢えず配列
    @nextportnum += 1 # 今のところポート数無制限
  end
end

class Cable
  def initialize
  end
  def self.connect(to, from) # ケーブルを繋いだ場合、起こることとしては、、mac同士で疎通開始とか？→hubにmacはなかった
    to.connected(from) # それぞれのポートのメソッドでリンク先を管理。
    from.connected(to)
  end
end

# obj setting -----------------------------

pc1 = PC.new("pc1", "A")
pc2 = PC.new("pc2", "B")
hub = Hub.new("hub")

Cable.connect(pc1, hub)
Cable.connect(pc2, hub)

# main ------------------------------------

packet1 = ["B", "hello"]
packet2 = ["C", "hello"]
pc1.send(packet1[0],packet1[1])
pc1.send(packet2[0],packet2[1])

# output ----------------------------------

puts "pc1: send packet#{packet1}"
puts "hub: recv packet#{packet1}"
puts "hub: send packet#{packet1}"
puts "pc2: recv packet#{packet1}"
puts "\n"
puts "pc1: send packet#{packet2}"
puts "hub: recv packet#{packet2}"
puts "hub: send packet#{packet2}"
puts "pc2: rjct packet#{packet2}"

# debug -----------------------------------

p pc1.nextportnum
p pc2.nextportnum
p hub.nextportnum

p hub.mac_table

p hub.mac_table.size



