
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

class PC
  attr_accessor :hostname, :mac_addr # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname, mac_addr) # インスタンス毎にホスト名とmacを持つ。
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    @mac_addr = mac_addr
  end
  def send(mac_addr, message)
  end
  def recv(mac_addr, message)
  end
  def rjct(mac_addr, message)
  end
end

class Hub
  attr_accessor :hostname, :mac_addr1, :mac_addr2 # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname) # インスタンス毎にホスト名を持つ。macは？→macも必要なはず。それも2枚。
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    @mac_addr1= hostname + 1.to_s # macはホスト名で取り敢えず作成。ホスト名被らないようにとか、制御もそのうち必要になる。
    @mac_addr2= hostname + 2.to_s
  end
  def send(mac_addr, message)
  end
  def recv(mac_addr, message)
  end
  def rjct(mac_addr, message)
  end
end

class Cable
  def initialize
  end
  def self.connect(to, from)
  end
end

# obj setting -----------------------------

pc1 = PC.new("pc1", "A")
pc2 = PC.new("pc2", "B")
hub = Hub.new("hub")

Cable.connect pc1,hub
Cable.connect pc2,hub

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


