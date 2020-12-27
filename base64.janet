(def- base64-chars (map string/from-bytes (string/bytes "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")))
(def- base64-invchars (table ;(mapcat (fn [i] [((base64-chars i) 0) i]) (range (length base64-chars))))) 

(defn encode [str]
  "Encode a string/bytes with base64 encoding."
  (var s str)
  (var r "")
  (var p "")
  (var c (mod (length s) 3))

  # add a right zero pad to make this string a multiple of 3 characters)
  (when (> c 0)
    (while (< c 3)
      (++ c)
      (set p (string p "="))
      (set s (string s "\0"))))

  # increment over the length of the string, three characters at a time
  (each i (range 0 (length s) 3) 
    # we add newlines after every 76 output characters, according to the MIME specs
    # (when (and (> c 0) (= (mod (/ (* c 4) 3) 76) 0)) (set r (string "\r\n")))

    # these three 8-bit (ASCII) characters become one 24-bit number
    (def tpl (string/bytes (string/slice s i (+ i 3))))
    (def n (+ (blshift (tpl 0) 16) (blshift (tpl 1) 8) (tpl 2))) 
    # this 24-bit number gets separated into four 6-bit numbers
    (def [n1 n2 n3 n4] [(band (brshift n 18) 63) (band (brshift n 12) 63) (band (brshift n 6) 63) (band n 63)])
    # those four 6-bit numbers are used as indices into the base64 character list
    (set r (string r (base64-chars n1) (base64-chars n2) (base64-chars n3) (base64-chars n4))))
    # r += base64chars[n[0]] + base64chars[n[1]] + base64chars[n[2]] + base64chars[n[3]];

    # add the actual padding string, after removing the zero pad)
  (string (string/slice r 0 (- (length r) (length p))) p))


(defn decode [str]
  "Decode a base64 encoded payload."
  (var s str)

  # TODO: remove/ignore any characters not in the base64 characters list
  # or the pad character -- particularly newlines

  # replace any incoming padding with a zero pad (the 'A' character is zero)
  (def p (if (= (last s) (chr "="))
           (if (= (s (- (length s) 2)) (chr "=")) "AA" "A")
           ""))

  (var r "")
  (set s (string (string/slice s 0 (- (length s) (length p))) p))

  # increment over the length of this encoded string, four characters at a time)
  (each i (range 0 (length s) 4) 
      (def [c1 c2 c3 c4] (string/slice s i (+ i 4)))
        # each of these four characters represents a 6-bit index in the base64 characters list
        # which, when concatenated, will give the 24-bit number for the original 3 characters
      (def n (+
               (blshift (base64-invchars c1) 18)
               (blshift (base64-invchars c2) 12)
               (blshift (base64-invchars c3) 6)
               (base64-invchars c4))) 
      # split the 24-bit number into the original three 8-bit (ASCII) characters
      (set r (string r (string/from-bytes 
                         (band (brshift n 16) 255)
                         (band (brshift n 8) 255)
                         (band n 255)))))
  
  # remove any zero pad that was added to make this a multiple of 24 bits
  (string/slice r 0 (- (length r) (length p))))

(comment
  (unmarshal (decode (encode (marshal {:test 1 :foo "hello"}))))
  (encode "foobarzy") 
  (decode "Zm9vYmFyenk="))
