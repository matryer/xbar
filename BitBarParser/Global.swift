import FootlessParser
typealias P<T> = Parser<Character, T>

func + <K, V> (left: [K: V], right: [K: V]) -> [K: V] {
  var value = left
  for (k, v) in right {
    value[k] = v
  }

  return value
}
