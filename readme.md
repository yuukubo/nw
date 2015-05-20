study for nw specialist

*************************************************

Q1. Implement "PC", "Hub", "Cable".

pc1 - hub -pc2

pc1 = PC.new name: "pc1", mac_addr: "A"
pc2 = PC.new name: "pc2", mac_addr: "B"
hub = Hub.new name: "hub"

Cable.connect pc1, hub
Cable.connect pc2, hub

pc1.send ["B", "hello"]
pc1.send ["C", "hello"]

pc1: send packet ["B", "hello"]
hub: recv packet ["B", "hello"]
hub: send packet ["B", "hello"]
pc2: recv packet ["B", "hello"]

pc1: send packet ["C", "hello"]
hub: recv packet ["C", "hello"]
hub: send packet ["C", "hello"]
pc2: reject packet ["C", "hello"]

*************************************************



