
# coding: utf-8

# commit 8:send recv進行。受け取り後案コメント記述。取り敢えずhubがメッセージ受け取るところまで
# 問題把握：オブジェクトを渡しているが、中身がループしている様だ。

# class -----------------------------------

class Port
  attr_accessor :link_table, :nextportnum, :obj_next_to, :packet, :from_port_host
  def initialize
    @nextportnum = 1
    @link_table = []
    @isnextto = false
  end
  def connected(next_to) # 実装はそれぞれの継承先で。
    @nextportnum += 1 # 今のところポート数無制限
    @obj_next_to = next_to # リンク先のオブジェクトを取得これで疎通に入れる。相手のrecvを呼べる。
  end # c8:バグ把握。obj_next_to、これ配列管理とかにしないと、今だと上書きになっちゃってる。
  def send(packet) # 同じく実装はそれぞれの継承先で。→と思ったら共通あったのでここで実装へ。
    puts "\n"
    p "send debug"
    p self
    p "####"
    packet << self # リンク先で、送り元を特定出来る情報を取得出来るように配列に要素を追加。
    p packet
    obj_next_to.recv(packet)
  end
  def recv(packet) # パケットの内容9回も書いて頭悪いなと思ったので後で直すはず。→c8:直し
    puts "\n"
    p "recv debug"
    p self
    p "####"
    p packet
    @packet = packet
    @from_port_host = @packet.last.hostname # Hubならパケットが来たポートを取得する処理。
    # パケットのfrom_mac_addrを、自身の、、、に書き換えるかと思ったけどそれは要らないか。ってか無理。
    # PCなら受け取り処理。Hubなら来たポート以外へsend処理。
  end
  def rjct(packet) # でもハブはリジェクトはしないかな？
  end
  def linkchk # ポートが一つでもリンクしているか確認。c7：これ必要か分からないな、、
    true if @link_table.size != 0
  end
  def portchk # c9:パケットが来たポートのホスト名が、リンクテーブルにあるか評価する。
    @link_table.each{|element|
      @isnextto = true if element == @from_port_host
    }
    if @isnextto
      @link_table_work = @link_table
      # work c2:来たポートナンバー把握して、それ以外へ投げる、という処理をしたいけど、時間切れでここまで
      # 多分ハッシュなら番号気にせず、取得出来る？
  end
end

class PC < Port
  attr_accessor :hostname, :mac_addr # 参照のみなのでreaderでも良いはずだけど取り敢えず。
  def initialize(hostname, mac_addr) # インスタンス毎にホスト名とmacを持つ。
    @hostname = hostname # インスタンス毎なので、インスタンス変数を使う。
    @mac_addr = mac_addr
    super() # 括弧なしで書いてて暫く嵌った。省略するとこのスコープの引数も投げてしまうということです。
  end
  def send(packet)
    p packet # debug
    super
  end
  def recv(packet)
  # 受け取り処理。パケットのto_mac_addrを取得、自身のmacと評価。
  # trueでメッセージ受付。適当に画面にでも表示とか？
  # falseでrjct。でもこれも折角だから、画面にPC2がパケット～～を破棄したよ。とか表示しますね。
    super
  end
  def rjct(packet)
  end
  def connected(next_to) # PCの方のポートでは特に管理することなし。→これだとどこにも行けないので取り敢えず相手のホスト名を管理？
    @link_table << @nextportnum << next_to.hostname # リンク先ホスト名とポートナンバーを取り敢えず管理。
    super
  end
end

class Hub < Port
  attr_accessor :hostname
  def initialize(hostname)
    @hostname = hostname # c8:DRYに反する。portクラス行き予定。
    super()
  end
  def send(packet)
    p packet # debug
    super
  end
  def recv(packet)
    # パケットが来たポートを取得する処理。
    # PCなら受け取り処理。Hubなら来たポート以外へsend処理。
    super
  end
  def rjct(packet)
  end
  def connected(next_to) # 自分のportとリンク先との対照表。でもこれだとカスケードが考慮されていない。。どうしよう→c8:それなら最初からホスト名管理にする？
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

packet1 = ["A", "B", "hello"] # from_mac_addr, to_mac_addr, message
packet2 = ["A", "C", "hello"] # 冷静に考えたらここでパケット作成してた。ばらす必要なかった。
pc1.send(packet1) # 取り出しはpacket1[0], packet1[1], packet1[2]
pc1.send(packet2) # 存在しない宛先へ送信テスト。宛先なしエラーとか必要？

# output ----------------------------------

puts "\n"
p "#################"
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

puts "\n"
p pc1.nextportnum
p pc2.nextportnum
p hub.nextportnum

puts "\n"
p pc1.link_table
p pc2.link_table
p hub.link_table

puts "\n"
p pc1.link_table.size
p pc2.link_table.size
p hub.link_table.size

puts "\n"
p pc1.packet
p pc2.packet
p hub.packet

puts "\n"
p pc1.from_port_host
p pc2.from_port_host
p hub.from_port_host



