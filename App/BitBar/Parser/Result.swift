public enum Result<T> {
  case failure([String])
  case success(T, String)
}
