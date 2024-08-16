{ pkgs, ... }:

{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.10.11.7/32" "2a0f:85c1:31:beef:7::/80" ];
      privateKeyFile = "/home/ezri/wg/privatekey";
      
      peers = [
        {
          publicKey = "KpGpQoBzM6Q6LNTryFXAvdPGJGrZnBdzD6XWDeieB1Q=";
          allowedIPs = [ "10.0.0.0/8" ];
          endpoint = "198.8.59.1:7777";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
