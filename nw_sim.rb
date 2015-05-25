
# coding: utf-8

# commit 7:パケット内容変更。ケーブルコネクトで双方に相手のインスタンス連携。

# class -----------------------------------

class Port
  attr_accessor :link_table, :nextportnum
  def initialize
    @nextportnum = 1
    @link_table = []
  end
  def connected(next_to) # 実装はそれぞれの継承先で。
    @nextportnum += 1 # 今のところポート数無制限
    @obj_next_to = next_to
  end
  def send(to_mac_addr, from_mac_addr, message) # 同じく実装はそれぞれの継承先で。
    next_to.recv(to_mac_addr, from_mac_addr, message)
  end
  def recv(to_mac_addr, from_mac_addr, message) # パケットの内容9回も書いて頭悪いなと思ったので後で直すはず。
    @packet = [to_mac_addr, from_mac_addr, message]
  end
  def rjct(to_mac_addr, from_mac_addr, message) # でもハブはリジェクトはしないかな？
  end
  def portchk # ポートが一つでもリンクしているか確認。c7：これ必要か分からないな、、
    true if @link_table.size != 0
  end
end

class PC < Port
  attr_accessor :hostname, :mac_addr # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname, mac_addr) # インスタンス毎にホスト名とmacを持つ。
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    @mac_addr = mac_addr
    super() # 括弧なしで書いてて暫く嵌った。省略するとこのスコープの引数も投げてしまうということです。
  end
  def send(to_mac_addr, from_mac_addr, message)
  end
  def recv(to_mac_addr, from_mac_addr, message)
  end
  def rjct(to_mac_addr, from_mac_addr, message)
  end
  def connected(next_to) # PCの方のポートでは特に管理することなし。→これだとどこにも行けないので取り敢えず相手のホスト名を管理？
    @link_table << @nextportnum << next_to.hostname # リンク先ホスト名とポートナンバーを取り敢えず管理。
    super
  end
end

class Hub < Port
  attr_accessor :hostname # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname) # インスタンス毎にホスト名を持つ。macは？→macも必要なはず。それも2枚。→調べたらないらしい。そーなのかー
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    #@mac_addr1= hostname + 1.to_s # macはホスト名で取り敢えず作成。ホスト名被らないようにとか、制御もそのうち必要になる。
    #@mac_addr2= hostname + 2.to_s # macではなく、ポートと繋がっている先のmacの対照表を管理するということでした。
    super()
  end
  def send(to_mac_addr, from_mac_addr, message)
  end
  def recv(to_mac_addr, from_mac_addr, message)
  end
  def rjct(to_mac_addr, from_mac_addr, message)
  end
  def connected(next_to) # 自分のportとリンク先との対照表。でもこれだとカスケードが考慮されていない。。どうしよう
    @link_table << @nextportnum << next_to.mac_addr # ポートとマックの、、ハッシュの方が良いのかちょっと分からず取り敢えず配列
    super
  end
end

class Cable
  def initialize
  end
  def self.connect(to, from) # ケーブルを繋いだ場合、起こることとしては、、mac同士で疎通開始とか？→hubにmacはなかった
    to.connected(from) # それぞれのポートのメソッドでリンク先を管理。
    from.connected(to) # PC側ポートでは相手のホスト名。ハブは相手のmacを管理
  end # ケーブル繋ぐところで、繋ぐ先がPCかハブか、場合分けをしたくなくて、継承に至りました。
end

# obj setting -----------------------------

pc1 = PC.new("pc1", "A")
pc2 = PC.new("pc2", "B")
hub = Hub.new("hub")

Cable.connect(pc1, hub)
Cable.connect(pc2, hub)

# main ------------------------------------

packet1 = ["A", "B", "hello"]
packet2 = ["A", "C", "hello"]
pc1.send(packet1[0], packet1[1], packet1[2])
pc1.send(packet2[0], packet2[1], packet1[2])

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

p pc1.link_table
p pc2.link_table
p hub.link_table

p pc1.link_table.size
p pc2.link_table.size
p hub.link_table.size



