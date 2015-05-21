
# coding: utf-8

class PC
  def initialize(hostname, mac_addr)
  end
  def send([hostname, message])
  end
  def recv([hostname, message])
  end
  def reject([hostname, message])
  end
end

class Hub
  def send([hostname, message])
  end
  def recv([hostname, message])
  end
  def reject([hostname, message])
  end
end

class Cable
  def connect(to, from)
  end
end

# class化？ packet, ip, message

