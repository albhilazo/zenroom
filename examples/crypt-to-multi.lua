-- encrypt a secret to multiple recipients

-- run with arguments:
--  -a crypto-to-multi.data -k crypt-to-multi.keys 

-- inside KEYS is a list of names and public keys encoded with b58; it
-- returns a list of recipients and encrypted secrets for each and the
-- sender's public key
keyring = ECDH.new()

secret = str(DATA)

keys = JSON.decode(KEYS)

-- this is our own secret key, combined with the recipient's public
-- key to obtain a session key
seckey = base64(keys.keyring.secret)
keyring:private(seckey)

res = {}

-- loop through all recipients
for name,pubkey in pairs(keys.recipients) do
   -- calculate the session key
   pub = base64(pubkey)
   k = keyring:session(pub)
   if not k then
	  print( "Error: not a valid public key for recipient " .. name)
	  return
   end

   -- encrypt the message with the session key
   enc = keyring:encrypt_weak_aes_cbc(k,secret)
   -- insert results in final json array
   res[name]= enc:base64()
end

-- return the json array
print(JSON.encode(res))
